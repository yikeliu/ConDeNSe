function [ ] = encodeAsNClique( curind, top_gccind, m, costGain, costGain_notEnc, out_fid, info, MDLcostNC, MDLcostFC_perf )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print the encoding of given graph as a near-clique.                    %
%   Output is stored in the model file in the form:                       %
%     nc node_ids_in_clique, costGain                                     %
%   Note that the costGain is 0 in the case of near-clique.               %
%  Author: Danai Koutra                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global model; 
global model_idx;
global AOrig;

% encode as near clique
fprintf(out_fid, 'nc %d,', m/2);
for i=1:size(curind, 2)
    fprintf(out_fid, ' %d', top_gccind( curind(i) ) );
end
if info == false
    fprintf(out_fid, '\n');
else
    fprintf(out_fid, ', %f | %f --- near clique \n', costGain, costGain_notEnc);
end

model_idx = model_idx + 1;
% edges in the model
node_all = sort(curind);
%edge_all = zeros(size(AOrig));
%edge_all(node_all,node_all) = AOrig(node_all,node_all);
%edge_all = nnz(edge_all);
edge_all = nnz(AOrig(node_all,node_all)); 
%edge_all = edge_all(:);
% compute quality
qual = MDLcostFC_perf/MDLcostNC;
%model(model_idx) = struct('code', 'nc', 'edges', m/2, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
model(model_idx) = struct('code', 'nc', 'edges', edge_all, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc, 'quality', qual, 'alpha', 0);
%n = size(model, 2);
%model(n+1) = struct('code', 'nc', 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain);

end
