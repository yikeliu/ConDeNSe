#!/bin/bash

echo ''
echo -e "\e[34m======== Steps 1 & 2: Subgraph Generation and Labeling  ==========\e[0m"
echo "Please provide the name of datafile:"
#read inputfile
inputfile=$1
clus_method=$2
filename=$(basename "$inputfile")
#filename='enron.graph'
filetype="${filename##*.}"
dataname="${filename%.*}" 
echo "Choose the clustering method (SL for SlashBurn, K for Kcores, L for Louvain, M for Metis, SP for Spectral, H for Hyperbolic, U for Unified):"
#read clus_method
#clus_method=SL
clus_name=$(case "$clus_method" in
	(SL) echo SlashBurn;;
	(K) echo Kcores;;
	(L) echo Louvain;;
	(M) echo Metis;;
	(SP) echo Spectral;;
	(H) echo Hyperbolic;;
	(BL) echo BlockModel;;
	(BI) echo BigClam;;
	(U) echo Unified
esac)

alpha=0.5


#matlab -r -nosplash -nodesktop "run_structureDiscovery('$clus_method')"



#dataname='chocMediaWiki.sentenceEdges'
#filetype='graph'
unweighted_graph='DATA/'$dataname'.'$filetype
model='DATA/'$clus_name'/'$dataname'_orderedALL.model'
modelFile=$dataname'_orderedALL.model'
modelTop10='DATA/'$clus_name'/'$dataname'_top10ordered.model'
#modelUnified='DATA/Unified/'$dataname'_orderedALL.model'
#modelUnifiedTop10='DATA/Unified/'$dataname'_top10ordered.model'

rm data.txt
echo $dataname >>data.txt
echo $filetype >>data.txt
echo $unweighted_graph >>data.txt

if [ "$clus_name" = "Unified" ]; then
	bash ./runMATLAB.sh STRUCTURE_DISCOVERY_noNearStructs/Unified/ unified_model \'../../DATA/Unified\' \'$dataname\'
else
	bash ./matlab_batcher.sh run_structureDiscovery $clus_name
fi
echo ''
echo 'Structure discovery finished.'

#unweighted_graph='DATA/chocMediaWiki.sentenceEdges.graph'
#model='DATA/chocMediaWiki.sentenceEdges_orderedALL.model'
#modelFile='chocMediaWiki.sentenceEdges_orderedALL.model'
#modelTop10='DATA/chocMediaWiki.sentenceEdges_top10ordered.model'

echo ''
echo -e "\e[34m=============== Step 3: Summary Assembly ===============\e[0m"
echo ''
#echo -e "\e[31m=============== TOP 10 structures ===============\e[0m"
#head -n 10 $model > $modelTop10
#echo 'Computing the encoding cost...'
#echo ''
#python MDL/score.py $unweighted_graph $modelTop10 > DATA/$clus_name/encoding_$dataname\_top10.out
#
#echo ''
#echo 'Explanation of the above output:'
#echo 'L(G,M):  Number of bits to describe the data given a model M.'
#echo 'L(M): Number of bits to describe only the model.'
#echo 'L(E): Number of bits to describe only the error.'
#echo ': M_0 is the zero-model where the graph is encoded as noise (no structure is assumed).'
#echo ': M_x is the model of the graph as represented by the top-10 structures.'
#echo ''
#cat DATA/$clus_name/encoding_$dataname\_top10.out
#echo ''
#echo ''
#
#echo -e "\e[31m========= Greedy selection of structures =========\e[0m"
#echo 'Computing the encoding cost...'
#echo ''
#python2.7 MDL/greedySearch_nStop.py $unweighted_graph $model > DATA/$clus_name/encoding_GnF_$dataname.out
#cat out_final.out
#rm out_final.out
#echo ''
#mv heuristic* DATA/$clus_name
#echo '>> Outputs saved in DATA/. To interpret the structures that are selected, check the file MDL/readme.txt.'
#echo ": DATA/heuristicSelection_nStop_ALL_$modelFile has the lines of the $model structures included in the summary."
#echo ": DATA/heuristic_Selection_costs_ALL_$modelFile has the encoding cost of the considered model at each time step."
#echo ''
#echo ''
#
#echo -e "\e[31m========= Optimal Greedy selection of structures with conjecture =========\e[0m"
#echo 'Computing the encoding cost...'
#echo ''
#python2.7 MDL/MDL_faster_optGreedy/greedySearch_nStop.py $unweighted_graph $model > DATA/$clus_name/encoding_OptGreedy_conjecture_$dataname.out
#cat out_final_opt.out
#rm out_final_opt.out
#mv greedySelection* DATA/$clus_name
#echo ''
#echo '>> Outputs saved in DATA/. To interpret the structures that are selected, check the file MDL/readme.txt.'
#echo ": DATA/greedySelection_nStop_ALL_$modelFile has the lines of the $model structures included in the summary."
#echo ": DATA/greedySelection_costs_ALL_$modelFile has the encoding cost of the considered model at each time step."
#echo ''
#echo ''
#
#echo -e "\e[31m========= Optimal Greedy selection of structures with conjecture and margin =========\e[0m"
#echo 'Computing the encoding cost...'
#echo ''
#python2.7 MDL/MDL_faster_optGreedy_withMargin/greedySearch_nStop.py $unweighted_graph $model > DATA/$clus_name/encoding_OptGreedy_conjectureWithMargin_$dataname.out
#cat out_final_opt.out
#rm out_final_opt.out
#mv greedySelection* DATA/$clus_name
#echo ''
#echo '>> Outputs saved in DATA/. To interpret the structures that are selected, check the file MDL/readme.txt.'
#echo ": DATA/greedySelectionMargin_nStop_ALL_$modelFile has the lines of the $model structures included in the summary."
#echo ": DATA/greedySelectionMargin_costs_ALL_$modelFile has the encoding cost of the considered model at each time step."
#echo ''
#echo ''

echo -e "\e[31m========= Optimal Greedy selection of structures without conjecture =========\e[0m"
echo 'Computing the encoding cost...'
echo ''
python2.7 MDL/MDL_faster_Step_noClaim/greedySearch_nStop.py $unweighted_graph $model > DATA/$clus_name/encoding_OptGreedy_$dataname.out
cat out_final_opt.out
rm out_final_opt.out
mv optGreedySelection* DATA/$clus_name
echo ''
echo '>> Outputs saved in DATA/. To interpret the structures that are selected, check the file MDL/readme.txt.'
echo ": DATA/optGreedySelection_nStop_ALL_$modelFile has the lines of the $model structures included in the summary."
echo ": DATA/optGreedySelection_costs_ALL_$modelFile has the encoding cost of the considered model at each time step."
echo ''
echo ''
