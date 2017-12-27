function [] = printStructureToModelFile( structure, fid )
%% Print a structure to the final model file.

switch structure.code
    case 'nc'
        %num_edge = nnz(structure.edges);
        fprintf(fid, 'nc %d,', structure.edges);
        fprintf(fid, 'nc %d,', num_edge);
        fprintf(fid, ' %d', structure.nodes1 );
        fprintf(fid, '\n');
    case {'fc', 'ch'}
        fprintf(fid, '%s', structure.code);
        fprintf(fid, ' %d', structure.nodes1 );
        fprintf(fid, '\n');
    case {'bc', 'nb', 'st'}
        fprintf(fid, '%s', structure.code);
        fprintf(fid, ' %d', structure.nodes1 );
        fprintf(fid, ',');
        fprintf(fid, ' %d', structure.nodes2 );
        fprintf(fid, '\n');
    case 'hb'
        fprintf(fid, 'hb %d,', structure.alpha);
        fprintf(fid, ' %d', structure.nodes1);
        fprintf(fid, '\n');
         
end



end
