function [] = EncodeSubgraph( B, curind, top_gccind, N_tot, out_fid, info, minSize )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Encode the connected component from SlashBurn:                         %
%   find whether it is clique, near-clique, star, chain or bipartite-core %
%   info: true (output the mdl benefit at the model file) /               %
%         false (Jilles' format for model file)                           %
%   minSize: smallest size of reported structures (number of nodes)       %
%  Author: Danai Koutra                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Asmall = B(curind,curind);

n = size(curind, 2);
m = nnz(Asmall);

% If the structure has less than 10 nodes, do not report it in the
% model file
if n < minSize
    return;
end
%fprintf('n=%d, m=%d\n', n, m);


%% First try to find one of the synthetic structures (vocab words):
%   clique, star, chain, bipartite core
% exact_found = ExactStructure( Asmall, curind, top_gccind, N_tot, out_fid, info, minSize );
% remove exact_found, set it to false
exact_found = false;

%% If it is not, try encoding it as near-structure (mispelled word)
%   and compute the MDL cost of each encoding.
%%%%% TO DO: add some heuristics before we try to encode as chain for
%%%%% instance -- check the degree distribution.
% maxint = 2147483647
MDLcosts = ones(1,5) * 2147483647;
if ( exact_found == false )
    [ MDLcostFC, MDLcostNC, MDLcostFC_perf ] = mdlCostAsfANDnClique( Asmall, N_tot );
    [ MDLcostST, MDLcostST_perf, hub, spokes ] = mdlCostAsStar( Asmall, curind, N_tot );
    [ MDLcostBC, MDLcostNB, MDLcostBC_perf, set1, set2 ] = mdlCostAsBCorNB( Asmall, N_tot );
    % add hyperbolic (EDIT LATER)
    [ MDLcostHB, MDLcostHB_perf, alpha, hyperbolic ] = mdlCostAsHB( Asmall, N_tot);
    %MDLcosts = [ MDLcostFC, MDLcostNC, MDLcostST, MDLcostBC, MDLcostNB];
    MDLcosts = [ MDLcostFC, MDLcostNC, MDLcostST, MDLcostBC, MDLcostNB, MDLcostHB ];
    % corresponding encoding cost for perfect structures
    %MDLcosts_perf = [ MDLcostFC_perf, MDLcostFC_perf, MDLcostST_perf, MDLcostBC_perf, MDLcostBC_perf];
    MDLcosts_perf = [ MDLcostFC_perf, MDLcostFC_perf, MDLcostST_perf, MDLcostBC_perf, MDLcostBC_perf, MDLcostHB_perf];
   
    if m < 1.5*n
        [ MDLcostCH, MDLcostCH_perf, chain ] = mdlCostAsChain( Asmall, N_tot );
        MDLcosts = [ MDLcosts, MDLcostCH ];
        % corresponding encoding cost for perfect structures
        MDLcosts_perf = [MDLcosts_perf, MDLcostCH_perf];
    end
%     %% parallize mdlcost
%     % set output to 4 for all structs?
%     structs = ['fc', 'st', 'bc', 'ch'];
%     for i = 1:4
%         s = structs(i);
%         [MDLcost(i)] = mdlCost(s, Asmall, curind, N_tot);
%     end
%     [ MDLcostFC, MDLcostNC, MDLcostFC_perf ] = mdlCostAsfANDnClique( Asmall, N_tot );
%     [ MDLcostST, MDLcostST_perf, hub, spokes ] = mdlCostAsStar( Asmall, curind, N_tot );
%     [ MDLcostBC, MDLcostNB, MDLcostBC_perf, set1, set2 ] = mdlCostAsBCorNB( Asmall, N_tot );
%     MDLcosts = [ MDLcostFC, MDLcostNC, MDLcostST, MDLcostBC, MDLcostNB];
%     % corresponding encoding cost for perfect structures
%     MDLcosts_perf = [ MDLcostFC_perf, MDLcostFC_perf, MDLcostST_perf, MDLcostBC_perf, MDLcostBC_perf];
   
%     if m < 1.5*n
%         [ MDLcostCH, MDLcostCH_perf, chain ] = mdlCostAsChain( Asmall, N_tot );
%         MDLcosts = [ MDLcosts, MDLcostCH ];
%         % corresponding encoding cost for perfect structures
%         MDLcosts_perf = [MDLcosts_perf, MDLcostCH_perf];
%     end

    %% Find which structure best describes the given submatrix: i.e., find the
    %  structure that has the minimum MDL cost. Then output to the model file
    %  this structure and its encoding gain in bits (mdlcostNC -
    %  mdlCostStructure).
    [ ~, idxMin ] = min(MDLcosts);
    
    cost_notEnc = compute_encodingCost( 'err', 0, 0, [nnz(Asmall) n^2-nnz(Asmall)]);
    
    if isinf(MDLcosts(idxMin)) || isinf(MDLcosts(2))
        costGain_notEnc = cost_notEnc - MDLcostNC;
        encodeAsNClique( curind, top_gccind, m, 0, costGain_notEnc, out_fid, info, MDLcostNC, MDLcostFC_perf );% removed for reduced VoG
        %remove structure
        %infidx = isinf(MDLcosts(idxMin)) || isinf(MDLcosts(2));
        %MDLcosts(idxMin(infidx)) = [];
        %idxMin(infidx) = [];
        %fprintf(out_fid, ' nan\n');
    else
        switch idxMin
            case 1
                costGain = MDLcostNC - MDLcostFC;
                costGain_notEnc = cost_notEnc - MDLcostFC;
                encodeAsFClique( curind, top_gccind, costGain, costGain_notEnc, out_fid, info, MDLcostFC, MDLcostFC_perf);
            case 2
                costGain = MDLcostNC - MDLcostNC;
                costGain_notEnc = cost_notEnc - MDLcostNC;
                m = nnz(Asmall);
                encodeAsNClique( curind, top_gccind, m, costGain, costGain_notEnc, out_fid, info, MDLcostNC, MDLcostFC_perf );
            case 3
                costGain = MDLcostNC - MDLcostST;
                costGain_notEnc = cost_notEnc - MDLcostST;
                encodeAsStar( curind, top_gccind, hub, spokes, costGain, costGain_notEnc, out_fid, info, MDLcostST, MDLcostST_perf );
            case 4
                costGain = MDLcostNC - MDLcostBC;
                costGain_notEnc = cost_notEnc - MDLcostBC;
                encodeAsBC( curind, top_gccind, set1, set2, costGain, costGain_notEnc, out_fid, info, MDLcostBC, MDLcostBC_perf );
            case 5
                costGain = MDLcostNC - MDLcostNB;
                costGain_notEnc = cost_notEnc - MDLcostNB;
                encodeAsNB( curind, top_gccind, set1, set2, costGain, costGain_notEnc, out_fid, info, MDLcostNB, MDLcostBC_perf );
            % addd hyperbolic (EDIT LATER)
            case 6
                costGain = MDLcostNC - MDLcostHB;
                costGain_notEnc = cost_notEnc - MDLcostHB;
                encodeASHypberbolic( curind, top_gccind, alpha, hyperbolic, costGain, costGain_notEnc, out_fid, MDLcostHB, MDLcostHB_perf );
            case 7
                costGain = MDLcostNC - MDLcostCH;
                costGain_notEnc = cost_notEnc - MDLcostCH;
                encodeAsChain( curind, top_gccind, chain, costGain, costGain_notEnc, out_fid, info, MDLcostCH, MDLcostCH_perf );
            otherwise
                error_message = 'error: impossible to get this error...\n'
        end
    end
    
end

end

