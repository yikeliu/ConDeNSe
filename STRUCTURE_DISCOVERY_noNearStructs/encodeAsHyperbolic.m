function [ ] = encodeAsHyperbolic( curind, top_gccind, alpha, hyperbolic, costGain, costGain_notEnc, out_fid, MDLcostHB, MDLcostHB_perf )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print the encoding of the given graph as a hyperbolic community        %
% Output in the model in the format:                                      %
% hb alpha, hyperbolic list                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global model; 
global model_idx;
global AOrig;

fprintf(out_fid, 'hb %d,', alpha);
fprintf(out_fid, ' %d', top_gccind(curind(hyperbolic)));
fprintf(out_fid, '\n');

model_idx = model_idx + 1;
% edges in the model
node_all = sort(curind(hyperbolic));
edge_all = nnz(AOrig(node_all,node_all)); 
% compute quality
qual = MDLcostHB_perf/MDLcostHB;
model(model_idx) = struct('code', 'hb', 'edges', edge_all, 'nodes1', top_gccind(curind(hyperbolic)), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc, 'quality', qual, 'alpha', alpha);

end