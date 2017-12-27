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


function [ ] = MetisEncode(AOrig, k, outFolder, info, starOption, minSize, graphFile )

addpath('STRUCTURE_DISCOVERY_noNearStructs/VariablePrecisionIntegers/VariablePrecisionIntegers');
addpath('gaimc/')
%% Definition of global variables:
%  model:
global model;
global model_idx;

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

%metis/spectral encoding -- change to .out.metispart for metis
fn = strcat(fname,'.out.spectralpart');
groups = dlmread(fn);
uniqGroups = unique(groups);
disp([num2str(numel(uniqGroups)) ' unique groups']);
for i = 1:length(uniqGroups)
	groupNum = uniqGroups(i);
	trueCompNodes = find(groups == groupNum); 
	disp([num2str(numel(trueCompNodes)) ' nodes in comm']);
	EncodeSubgraph(AOrig(trueCompNodes, trueCompNodes), [1:numel(trueCompNodes)], trueCompNodes, n, out_fid, info, minSize); 
end

%% Selection of structures:
% Method 1: top 10
% Method 2: greedy selection


[~, order] = sort([model(:).benefit_notEnc], 'descend');
model_ordered = model(order);
save('model.mat','model_ordered');
printModel(model_ordered, outfile_ordered);
all_costs = 0;
all_costs_incStruct = 0;

runtime = cputime-t
time_stored = sprintf('%s/%s_runtime.txt', outFolder, fname);
save(time_stored, 'runtime', '-ascii');

disp('=== Graph decomposition and structure labeling: finished! ===')

fclose(out_fid);

end
