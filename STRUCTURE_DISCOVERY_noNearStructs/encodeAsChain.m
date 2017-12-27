function [ ] = encodeAsChain( curind, top_gccind, chain, costGain, costGain_notEnc, out_fid, info, MDLcostCH, MDLcostCH_perf )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print the encoding of the given graph as chain                         %
%   Output is stored in the model file in the form:                       %
%     ch node_ids_in_order, costGain                                      % 
%  Author: Danai Koutra                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global model; 
global model_idx;
global AOrig;

%% Printing the encoded structure.
fprintf(out_fid, 'ch ');
fprintf(out_fid, ' %d', top_gccind( curind(chain) ) );
if info == false
    fprintf(out_fid, '\n');
else
    fprintf(out_fid, ', %f  | %f --- nearChain \n', costGain, costGain_notEnc);
end

model_idx = model_idx + 1;
% edges in the model
node_all = sort(curind(chain));
%edge_all = zeros(size(AOrig));
%edge_all(node_all,node_all) = AOrig(node_all,node_all);
%edge_all = nnz(edge_all);
edge_all = nnz(AOrig(node_all,node_all)); 
%edge_all = edge_all(:);
% compute quality
qual = MDLcostCH_perf/MDLcostCH;
model(model_idx) = struct('code', 'ch', 'edges', edges_all, 'nodes1', top_gccind(curind(chain)), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc, 'quality', qual, 'alpha', 0);
%n = size(model, 2);
%model(n+1) = struct('code', 'ch', 'nodes1', top_gccind(curind(chain)), 'nodes2', [], 'benefit', costGain);

end
