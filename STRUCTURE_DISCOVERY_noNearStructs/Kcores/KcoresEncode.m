%  Author: Danai Koutra
%  Adaptation and extension of U Kang's code for SlashBurn 
%   (http://www.cs.cmu.edu/~ukang/papers/sb_icdm2011.pdf)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% SlashBurn Encode: encode graph using SlashBurn                            %
%                                                                           %
% Parameter                                                                 %
%   AOrig : adjacency matrix of a graph. We assume symmetric matrix with    %
%           both upper- and lower- diagonal elements are set.               %
%   k : # of nodes to cut in SlashBurn                                      %
%   outfile : file name to output the model                                 %
%   info : true for detailed output (encoding gain reported)                %
%          false for brief output (no encoding gain reported)               %
%   starOption: true for encoding the vicinities of top degree nodes as     %
%                     stars                                                 %
%               false for encoding these vicinities as stars, nc or fc      %
%               (depending on the smallest mdl cost)                        %
%   minSize: minimum size of structure that we want to encode               %
%   graphFile: path to the edge file                                        %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ ] = KcoresEncode(AOrig, k, outFolder, info, starOption, minSize, graphFile )

addpath('../VariablePrecisionIntegers/VariablePrecisionIntegers');
addpath('gaimc/')
%% Definition of global variables:
%  model:
global model;
global model_idx;
global AOrig;

dir=0;
% cost of encoding all the structures
cost_ALLencoded_struct = 0;
% if greedy is selected, all_costs has all the costs by adding one extra
% structure for encoding
all_costs = 0;

%if nargin < 3
%    info = false;
%end
[~, fname, ~] = fileparts(graphFile);
allOutFile = sprintf('%s/%s_ALL.model', outFolder, fname);
outfile_ordered = sprintf('%s/%s_orderedALL.model', outFolder, fname);
% Open 'outfile' for writing
out_fid = fopen(allOutFile, 'w');

% Initialize variables
gccsize = zeros(0,0);
niter=0;
n = max(size(AOrig,1),size(AOrig,2));
AOrig(n,n)=0;
totalind = zeros(1,n);
cur_lpos = 1;
cur_rpos = n;
gccind = [1:n];
cur_gccsize = n;
total_SB_stars = 0;
encoded_SB_stars = 0;
total_cost = 0;

if info == true
    info = false
    changingYourOption = 'Setting info to false, so that we can compute the encoding cost of all the found structures'
end

t = cputime; 

%start kcores
Amod = AOrig;
nnodes = n;
prev_nnodes = -1;
iter = 1;
thresh = 0.05;
%kvalue = 3;%manually select k value

while nnodes > 0
	disp(['iter ' num2str(iter)]);
	iter = iter + 1;
	disp(['nnodes at start ' num2str(nnodes)]);
	%figure out kvalue and compute the remainder and decomp set based on that
	[cn,~] = corenums(Amod);
	kvalue = max(cn); %maximum k value with a nonzero graph
	%kvalue = kvalue-1;
 	%kvalue = 9; %manually select k value
	disp(['kvalue ' num2str(kvalue)]);
	if(kvalue == 2) %destroys stars and chains, so no point getting here
		break;
	end
	kCoreRemainderNodes = find(cn<kvalue)'; %everything with a lower k-coreness value (remainder)
	kCoreDecompNodes = find(cn==kvalue)'; %everything in the actual decomposition
	disp(['nodes in decomp ' num2str(numel(kCoreDecompNodes))]);
	disp(['nodes in remainder ' num2str(numel(kCoreRemainderNodes))]);
	%encode substructures from actual decomposition
	kCoreDecompMatrix = Amod(kCoreDecompNodes, kCoreDecompNodes);
	[nComponents,membership] = graphconncomp(kCoreDecompMatrix);
	for i = 1:nComponents
		compNodes = find(membership == i);
		compSize = numel(compNodes);
	
		trueCompNodes = kCoreDecompNodes(compNodes);
	        
     	   if starOption == true
     	       %fprintf( out_fid, 'st %d,', center);
     	       %fprintf( out_fid, ' %d', satellites );
     	       %encoded_SB_stars = encoded_SB_stars + 1;
     	       disp('setting star option to false');
		starOption = false;
     	       
     	      % if info == false
     	       %    fprintf( out_fid, '\n');
     	       %else
     	       %    fprintf( out_fid, ', %f | %f -- KC \n', costGain, costGain_notEnc);
     	       %end
     	       %model_idx = model_idx + 1;
     	       %model(model_idx) = struct('code', 'st', 'edges', 0, 'nodes1', center, 'nodes2', satellites, 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
     	       % check which of the structures is best for encoding: star, fc, nc
     	   elseif starOption == false
    	       EncodeSubgraph(AOrig(trueCompNodes, trueCompNodes), [1:numel(trueCompNodes)], trueCompNodes, n, out_fid, info, minSize); 
    	    else
    	        wrongMessage = 'starOption should be true or false. Invalid value given.'
    	        return
    	    end
	end	%finished encoding from decomposition
	
	%consider remainder of decomposition
	kCoreRemainderMatrix = Amod(kCoreRemainderNodes, kCoreRemainderNodes);
	[nComponents,membership] = graphconncomp(kCoreRemainderMatrix);
	lcc_size = 0;
	for i = 1:nComponents
		compSize = numel(find(membership == i));
		lcc_size = max(lcc_size,compSize);
	end
	disp(['lcc_size ' num2str(lcc_size)]);
	%if the largest connected component in the remainder is too big (greater than thresh% of total node count), recursively apply kcores on the remainder graph
	if(lcc_size > thresh*n)
		Amod(kCoreDecompNodes, kCoreDecompNodes) = 0; %burn away only relevant connections
		%we're now consider just the number of nodes in the remainder graph
		nnodes = nnodes - numel(kCoreDecompNodes);

		if(nnodes == prev_nnodes)
			break; %break out if we're getting nowhere (decomposition is coming up empty)
		end
		prev_nnodes = nnodes;
	else
		break;
	end
end

%remainder analysis
[nComponents, membership] = graphconncomp(kCoreRemainderMatrix);
disp([num2str(nComponents) ' components']);
for i = 1:nComponents
	disp(num2str(numel(find(membership == i))));
end

%% Selection of structures:
% Method 1: top 10
% Method 2: greedy selection


[~, order] = sort([model(:).benefit_notEnc], 'descend');
model_ordered = model(order);
save('model.mat','model_ordered');
copyfile('model.mat','../../DATA/Kcores');
printModel(model_ordered, outfile_ordered);
all_costs = 0;
all_costs_incStruct = 0;

runtime = cputime-t
time_stored = sprintf('%s/%s_runtime.txt', outFolder, fname);
save(time_stored, 'runtime', '-ascii');

disp('=== Graph decomposition and structure labeling: finished! ===')

fclose(out_fid);

end
