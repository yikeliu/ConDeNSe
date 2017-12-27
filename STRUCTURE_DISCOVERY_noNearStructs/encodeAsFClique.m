function [ ] = encodeAsFClique( curind, top_gccind, costGain, costGain_notEnc, out_fid, info, MDLcostFC, MDLcostFC_perf )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print the encoding of given graph as a full clique.                    %
%   Output is stored in the model file in the form:                       %
%     fc node_ids_in_clique, costGain                                     % 
%  Author: Danai Koutra                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global model; 
global model_idx;
global AOrig;

%% Printing the encoded structure.
% encode as full clique
fprintf(out_fid, 'fc');
for i=1:size(curind, 2)
    fprintf(out_fid, ' %d', top_gccind( curind(i) ) );
end
if info == false
    fprintf(out_fid, '\n');
else
    fprintf(out_fid, ', %f | %f --- full clique \n', costGain, costGain_notEnc);
end

model_idx = model_idx + 1;
% edges in the model
node_all = sort(curind);
%edge_all = zeros(size(AOrig));
%edge_all(node_all,node_all) = AOrig(node_all,node_all);
%edge_all = sparse(edge_all);
edge_all = nnz(AOrig(node_all,node_all)); 
%edge_all = edge_all(:);
% compute quality
qual = MDLcostFC_perf/MDLcostFC;
model(model_idx) = struct('code', 'fc', 'edges', edge_all, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc, 'quality', qual, 'alpha', 0);
%n = size(model, 2);
%model(n+1) = struct('code', 'fc', 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain);

end
