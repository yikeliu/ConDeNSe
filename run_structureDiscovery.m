function[] = run_structureDiscovery(clus_name)
 %profile -memory on;
 

 %clus_method = 'SlashBurn'
 datafilename = 'data.txt';
 datafid = fopen(datafilename, 'r');
 dataname = fgetl(datafid);
 filetype = fgetl(datafid);
 unweighted_graph = fgetl(datafid);
 fclose(datafid);
 %parpool;
 
 %input_file = absolutepath('DATA/chocMediaWiki.sentenceEdges.graph');
 input_file = absolutepath(unweighted_graph);
 unweighted_graph = input_file;
 %clus = {'SL', 'SlashBurn'; 'K', 'Kcores'; 'L', 'Louvain'; 'M', 'Metis'; 'SP', 'Spectral'; 'H', 'Hyperbolic'};
 %display(clus{1:6,1});
 %clus_name = clus(find(ismember(clus(:,1), clus_method)),2);
 %display(clus_name);
 %clus_name = char(clus_name);
 output_model_greedy = absolutepath('DATA/');
 output_model_greedy = [output_model_greedy,'/',clus_name];
 output_model_top10 = absolutepath('DATA/');
 output_model_top10 = [output_model_top10,'/',clus_name];
 %display(output_model_greedy)
 mkdir(output_model_greedy);
 %dataname = 'chocMediaWiki.sentenceEdges';
 %filetype = 'graph';
 
% addpath('STRUCTURE_DISCOVERY');

 addpath(absolutepath('STRUCTURE_DISCOVERY_noNearStructs'));

 orig = spconvert(load(input_file));
 orig(max(size(orig)),max(size(orig))) = 0;
 orig_sym = orig + orig';
 [i,j,k] = find(orig_sym);
 orig_sym(i(find(k==2)),j(find(k==2))) = 1;
 orig_sym_nodiag = orig_sym - diag(diag(orig_sym));
 
 disp('==== Running VoG for structure discovery ====')
 global model; 
 model = struct('code', {}, 'edges', {}, 'nodes1', {}, 'nodes2', {}, 'benefit', {}, 'benefit_notEnc', {}, 'quality', {}, 'alpha', {});
 global model_idx;
 model_idx = 0;

 %clust_method = 'SlashBurn';
 %clus_method = input('Choose the clustering method (SlashBurn, Kcores, Louvain, Metis, Spectral): ','s');
 
 
 
 switch clus_name
     case 'SlashBurn'
         cd STRUCTURE_DISCOVERY_noNearStructs/SlashBurn;
         SlashBurnEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         cd ../;
     case 'Kcores'
         cd STRUCTURE_DISCOVERY_noNearStructs/Kcores;
         %addpath('gaimc/');
         KcoresEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         cd ..;
     case 'Louvain'
         cd STRUCTURE_DISCOVERY_noNearStructs/Louvain;
         shcommand = ['bash ./louvain.sh ', dataname,'.',filetype,' -> outputs in ../../VariablePrecisionIntegers/VariablePrecisionIntegers/'];
         %display(shcommand);
         tic
         system(['bash ./louvain.sh ', dataname,'.',filetype,' -> outputs in ../../VariablePrecisionIntegers/VariablePrecisionIntegers/']);
         %system('bash ./louvain.sh chocMediaWiki.sentenceEdges.out -> outputs in ../VariablePrecisionIntegers/VariablePrecisionIntegers');
         LouvainEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         runtime = toc
         cd ..;
     case 'Metis'
	     cd STRUCTURE_DISCOVERY_noNearStructs/Metis;
         tic
	     metis(['../../DATA/',dataname,'.',filetype],'../VariablePrecisionIntegers/VariablePrecisionIntegers/');
         MetisEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         runtime = toc
	     cd ..;
     case 'Spectral'
         cd STRUCTURE_DISCOVERY_noNearStructs/Spectral;
         %display(['../../DATA/',dataname,'.',filetype]);
         tic
         spectral_fact(['../../DATA/',dataname,'.',filetype]);
         SpectralEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         runtime = toc
         cd ..;
     case 'Hyperbolic'
         cd STRUCTURE_DISCOVERY_noNearStructs/Hyperbolic;
         tic
  	     system(['bash ./hyperbolic.sh ', dataname,'.',filetype, ' -> outputs in ../../VariablePrecisionIntegers/VariablePrecisionIntegers/']);
	     HyperbolicEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         runtime = toc
	     cd ..;
     case 'BlockModel'
         cd STRUCTURE_DISCOVERY_noNearStructs/BlockModel;
         tic
         blockmodel(['../../DATA/',dataname,'.',filetype]);
         BlockModelEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         runtime = toc
         cd ..;
     case 'BigClam'
         cd STRUCTURE_DISCOVERY_noNearStructs/BigClam;
         tic
         system(['bash ./bigclam.sh ', dataname,'.',filetype]);
         BigClamEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
         runtime = toc
     otherwise
         warning('Wrong input, VoG_Reduced did not run.');
 end

 
% SlashBurnEncode( orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);
%delete(gcp);

%profile off;
%profsave(profile('info'),'vogprofile_results_memory_SL');

 quit
