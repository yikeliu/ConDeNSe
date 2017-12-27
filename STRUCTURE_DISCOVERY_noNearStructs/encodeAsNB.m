function [ ] = encodeAsNB( curind, top_gccind, set1, set2, costGain, costGain_notEnc, out_fid, info )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print the encoding of the given graph as bipartite core                %
%   Output is stored in the model file in the form:                       %
%     bc node_ids_of_1st_set, node_ids_of_2nd_set, costGain               %
%  Author: Danai Koutra                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global model; 
global model_idx;
global AOrig;

if ~isempty(set1) && ~isempty(set2)
    fprintf(out_fid, 'nb');
    fprintf(out_fid, ' %d', top_gccind( curind(set1) ));
    fprintf(out_fid, ',');
    fprintf(out_fid, ' %d', top_gccind( curind(set2) ) );
    if info == false
            fprintf(out_fid, '\n');
        else
            fprintf(out_fid, ', %f | %f ------ NB \n', costGain, costGain_notEnc);
    end
end

model_idx = model_idx + 1;
% edges in the model
node_all = sort([curind(set1),curind(set2)]);
%edge_all = zeros(size(AOrig));
%edge_all(node_all,node_all) = AOrig(node_all,node_all);
%edge_all = nnz(edge_all);
edge_all = nnz(AOrig(node_all,node_all)); 			
%edge_all = edge_all(:);
% compute quality
qual = MDLcostBC_perf/MDLcostNB;
model(model_idx) = struct('code', 'nb', 'edges', edge_all, 'nodes1', top_gccind(curind(set1)), 'nodes2', top_gccind(curind(set2)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc, 'quality', qual, 'alpha', 0);
%n = size(model, 2);
%model(n+1) = struct('code', 'bc', 'nodes1', top_gccind(curind(set1)), 'nodes2', top_gccind(curind(set2)), 'benefit', costGain);
    
end
