function [ MDLcost, MDLcost_perf, alpha, hyperbolic ] = mdlCostAsHB ( Asmall, N_tot )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Encode given graph as a hyperbolic community                           %
% http://www.cs.cmu.edu/~christos/PUBLICATIONS/pkdd14-HyCom.pdf           %
% Input:                                                                  %
% Asmall: subgraph adjacency matrix                                       %
% N_tot: total number of nodes in the graph                               %
% Output:                                                                 %
% MDLcost: MDL cost of encoding the subgraph as a hyperbolic structure    %
% MDLcost_perf: MDL cost of encoding the subgraph as a perfect structure  %
% alpha: power law exponent of the structure                              %
% hyperbolic: ordered list of nodes                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = size(Asmall, 2);

%% check number of nodes in the struct, if smaller than 10, never encode as HB
%if n < 10
%    MDLcost = intmax;
%else

%% compute alpha
% for Hyperbolic clustering, use that given in the output file

% for other methods, use power law fit to find it
% first, find rank and degree of each node
Adeg = sum(Asmall);
deg_fre = tabulate(Adeg); % this ranks degree by descending order
alpha = plfit(Adeg);
hyperbolic = fliplr(deg_fre(:, 1)');
%disp(alpha);

%% MDL cost of encoding given structure as a hyperbolic community
MDLcost = compute_encodingCost( 'hb', N_tot, n, Asmall, 0, 0, false, alpha );

%% MDL cost of encoding nodes on given structure as a perfect structure
MDLcost_perf = compute_encodingCost( 'hb', N_tot, n, zeros(n, n), 0, 0, false, alpha);
end
