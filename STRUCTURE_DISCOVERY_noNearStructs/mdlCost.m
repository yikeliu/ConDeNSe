function varargout = mdlCost(struct, Asmall, curind, N_tot)
switch struct
    case 'fc'
        curind = [];
        [varargout{1}, varargout{2}, varargout{3}] = mdlCostAsfANDnClique(Asmall, N_tot);
    case 'bc'
        curind = [];
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}] = mdlCostAsBCorNB(Asmall, N_tot);
    case 'st'
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = mdlCostAsStar(Asmall, curind, N_tot );
    case 'ch'
        curind = [];
        [varargout{1}, varargout{2}, varargout{3}] = mdlCostAsChain(Asmall, N_tot);
    case 'hb'
        curind = [];
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = mdlCostAsHB(Asmall, N_tot);
end
    

        