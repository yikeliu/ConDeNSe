#!/usr/bash
data='chocMediaWiki.sentenceEdges.graph'
dataname="${data%.*}"

bash demo_vog_choc.bash $data SL > $dataname\_SL.out
#bash demo_vog_choc.bash $data K > $dataname\_K.out
#bash demo_vog_choc.bash $data L > $dataname\_L.out
#bash demo_vog_choc.bash $data SP > $dataname\_SP.out
#bash demo_vog_choc.bash $data M > $dataname\_M.out
#bash demo_vog_choc.bash $data H > $dataname\_H.out
#bash demo_vog_choc.bash $data BI > $dataname\_BI.out
#bash demo_vog_choc.bash $data U > $dataname\_U.out
