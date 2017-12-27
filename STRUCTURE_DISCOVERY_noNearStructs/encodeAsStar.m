function [ ] = encodeAsStar( curind, top_gccind, hub, spokes, costGain, costGain_notEnc, out_fid, info, MDLcostST, MDLcostST_perf )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print the encoding of the given graph as star                          %
%   Output is stored in the model file in the form:                       %
%     st hub, spokes_ids, costGain                                        %
%  Author: Danai Koutra                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global model; 
global model_idx;
global AOrig;

fprintf(out_fid, 'st %d,', top_gccind( curind(hub) ) );
fprintf(out_fid, ' %d', top_gccind( curind(spokes) ) );

if info == false
    fprintf(out_fid, '\n');
else
    fprintf(out_fid, ', %f | %f --- nearStar \n', costGain, costGain_notEnc);
end

model_idx = model_idx + 1;
% edges in the model
node_all = sort([curind(hub),curind(spokes)]);
%edge_all = zeros(size(AOrig));
%edge_all(node_all,node_all) = AOrig(node_all,node_all);
%edge_all = nnz(edge_all);
edge_all = nnz(AOrig(node_all,node_all)); 
%edge_all = edge_all(:);
% compute quality
qual = MDLcostST_perf/MDLcostST;
model(model_idx) = struct('code', 'st', 'edges', edge_all, 'nodes1', top_gccind(curind(hub)), 'nodes2', top_gccind(curind(spokes)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc, 'quality', qual, 'alpha', 0);
%n = size(model, 2);
%model(n+1) = struct('code', 'st', 'nodes1', top_gccind(curind(hub)), 'nodes2', top_gccind(curind(spokes)), 'benefit', costGain);


end
