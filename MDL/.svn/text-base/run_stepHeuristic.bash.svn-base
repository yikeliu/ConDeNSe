#!/bin/bash

#cp /usr1/dkoutra/VoG/code/slashburn/RESULTS_SB_asNConly_4journal_difference/*_orderedALL.model ../../models/slashburn_noNearStructs/

time -p python2.7 greedySearch_nStop.py ../../Graphs/lcrMediaWiki.sentenceEdges.graph ../../models/slashburn_noNearStructs/lcrMediaWiki.sentenceEdges_orderedALL.model > OUTPUT_step_lcr_whole.out &
time -p python2.7 greedySearch_nStop.py ../../Graphs/chocMediaWiki.wholeEdges.graph ../../models/slashburn_noNearStructs/chocMediaWiki.wholeEdges_ALL.model > OUTPUT_step_choc_sentence.out &

time -p python2.7 greedySearch_nStop.py ../../Graphs/as-oregon.graph ../../models/slashburn_noNearStructs/as-oregon_orderedALL.model > OUTPUT_step_oregon.out &
time -p python2.7 greedySearch_nStop.py ../../Graphs/enron.graph ../../models/slashburn_noNearStructs/enron_orderedALL.model > OUTPUT_step_enron.out &
time -p python2.7 greedySearch_nStop.py ../../Graphs/epinions_sym.graph ../../models/slashburn_noNearStructs/epinions_sym_orderedALL.model > OUTPUT_step_epinions.out &
time -p python2.7 greedySearch_nStop.py ../../Graphs/wwwbb_sym.graph ../../models/slashburn_noNearStructs/wwwbb_sym_orderedALL.model > OUTPUT_step_wwwbb.out &
time -p python2.7 greedySearch_nStop.py ../../Graphs/flickr.graph ../../models/slashburn_noNearStructs/flickr_orderedALL.model > OUTPUT_step_flickr.out &




