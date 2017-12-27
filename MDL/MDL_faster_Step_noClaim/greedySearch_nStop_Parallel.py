#!/usr/local/bin/python2.6

#########################################################################
#                                                                       #
# Implementation of the GreedyNForget heuristic described in the paper  #
# VOG: Summarizing and Understanding Large Graphs                       #
# by Danai Koutra, U Kang, Jilles Vreeken, Christos Faloutsos           #
# http://www.cs.cmu.edu/~dkoutra/papers/VoG.pdf                         #
#                                                                       #
#########################################################################


import sys
import os
import config
import copy

from time import time

from mdl import *;
from error import Error;
from graph import Graph;
from model import *;
from random import shuffle;
#from description_length import *;

if len(sys.argv) <= 1 :
    print 'at least: <graph.graph> [model.model] [-pC] [-lC] [-pE] [-lE] [-e{NP,NB,TP,TB}]';
    print ' optional argument model = file to read model from, otherwise only empty model';
    print ' optional argument -vX    = verbosity (1, 2, or 3)';
    print ' optional argument -pG    = plot Graph adjacency matrix';
    print ' optional argument -pC    = plot Cover matrix';
    print ' optional argument -pE    = plot Error matrix';
    print ' optional argument -lC    = list Cover entries';
    print ' optional argument -lE    = list Error entries';
    print ' optional argument -eXX   = encode error resp. untyped using prefix (NP), or';
    print '                            binomial (NB) codes, or using typed';
    print '                            prefix (TP) or binomial (TB, default) codes';
    print ' optional argument -optX   = optimization function -- simple (S), coverage (C)';
    print '                             newCoverage (N), coverage + repeatedErr (CRE)'; 
    print '                             coverage + repeated All (CRA)'; 
    exit();

if (len(sys.argv) > 1 and ("-v1" in sys.argv)) :
    config.optVerbosity = 1;
elif (len(sys.argv) > 1 and ("-v2" in sys.argv)) :
    config.optVerbosity = 2;
if (len(sys.argv) > 1 and ("-v3" in sys.argv)) :
    config.optVerbosity = 3;

t0 = time()

gFilename = sys.argv[1];
g = Graph();
g.load(gFilename);


if config.optVerbosity > 1 : print "- graph loaded."

m = Model();


errorEnc = config.optDefaultError;
if (len(sys.argv) > 1 and ("-eNP" in sys.argv or "-NP'" in sys.argv)) :
    errorEnc = "NP";
elif (len(sys.argv) > 1 and ("-eNB" in sys.argv or "-NB" in sys.argv)) :
    errorEnc = "NB";
elif (len(sys.argv) > 1 and ("-eTP" in sys.argv or "-TP" in sys.argv)) :
    errorEnc = "TP";
elif (len(sys.argv) > 1 and ("-eTB" in sys.argv or "-TB" in sys.argv)) :
    errorEnc = "TB";


optMethod = config.optDefaultMethod;
if (len(sys.argv) > 3 and "-optS" in sys.argv) :
    optMethod = "simple";
elif (len(sys.argv) > 3 and "-optC" in sys.argv) :
    optMethod = "coverage";
elif (len(sys.argv) > 3 and "-optN" in sys.argv) :
    optMethod = "newCoverage";
elif (len(sys.argv) > 3 and "-optCRE" in sys.argv) :
    optMethod = "coverRepErr";
elif (len(sys.argv) > 3 and "-optCRA" in sys.argv) :
    optMethod = "coverRepAll";

        
if config.optVerbosity > 1 : print "- calculating L(M_0,G)"
(l_total_0, l_model_0, l_error_0, E_0, l_total_wCoverage0, l_total_wNEWcoverage0,l_total_coverageRepeatedErr0, l_total_coverageRepeatedAll0) = L(g,m, errorEnc);
if config.optVerbosity > 1 : print "- calculated L(M_0,G)"
print "   \t" + "L(G,M)" + "\tL(M)" + "\tL(E)" + "\t#E+" + "\t#E-" + "\t\t#Ex"+ "\t\tL/coverage" + "\tL/new_coverage";
print "M_0:\t" + '%.0f' % l_total_0 + "\t" + '%.0f' % l_model_0 + "\t" + '%.0f' %  l_error_0 + "\t" + str(E_0.numModellingErrors) + '/' + str(E_0.numCellsCovered) + '\t' + str(E_0.numUnmodelledErrors)  + '/' + str(((E_0.numNodes * E_0.numNodes)-E_0.numNodes) - E_0.numCellsCovered) + '\t' + str(E_0.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage0 + '\t%.0f' % l_total_wNEWcoverage0 + "\t\t%.0f" % l_total_coverageRepeatedErr0 + "\t%.0f" % l_total_coverageRepeatedAll0;


if len(sys.argv) > 2 and sys.argv[2][0] != '-' :
    mFilename = sys.argv[2];
    m.load(mFilename);
    print "Number of structures in the model: %.0f" % m.numStructs;
    if config.optVerbosity > 1 : print "- M_x loaded."
    (l_total_x, l_model_x, l_error_x, E_x, l_total_wCoverage, l_total_wNEWcoverage, l_total_coverageRepeatedErr, l_total_coverageRepeatedAll) = L(g,m, errorEnc);
    print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
    
    # reinitialize the model for the greedy approach
    m = Model();

    # maximum number of structures considered
    structLim = 100000; # 10000;
    # read maxStructs structures from the model file and save it in modelContent
    mHandle = open(mFilename, 'r')
    mContent = mHandle.readlines();  #(structLim);
    structs_not_selected = range(0, len(mContent)); 
    maxStructs = len(mContent);
    lines_all = [];

    # node distribution file
    if config.optDecompose and config.optDebug:
	nodeDist = open('node_dist_choc.out','w');


    if optMethod == "simple":
        l_total_prev = l_total_0;
    elif optMethod == "coverage":
        l_total_prev = l_total_wCoverage0;
    elif optMethod == "newCoverage":
        l_total_prev = l_total_wNEWcoverage0;
    elif optMethod == "coverRepErr":
        l_total_prev = l_total_coverageRepeatedErr0;
    elif optMethod == "coverRepAll":
        l_total_prev = l_total_coverageRepeatedAll0;

    # the encoding cost per structure is 0 initially
    #lmodel_struct_prev = 0;
    #E_x_old = E_0; 
    #E_x = E_0;
    #structsInSummary = [];
    #times = 1;
    
    #mFilename_list = mFilename.split('/');
    #mFilename_main = mFilename_list[len(mFilename_list) - 1];
    #print '%s' % mFilename_main
    #mFilenameGreedy = 'optSubSelection_nStop_' + optMethod + '_' + mFilename_main;
    #fgreedy = open(mFilenameGreedy,'w')
    #mFilenameGreedyCost = 'optSubSelection_costs_' + optMethod + '_' + mFilename_main;
    #fgreedyCost = open(mFilenameGreedyCost,'w')
                                                                                          
    #fgreedyCost.write("l_total_0: %.0f\n" % l_total_0 )
    #l_total_x_best = l_total_0;
    #if optMethod == "simple":
    #    l_total_best = l_total_0;
    #elif optMethod == "coverage":
    #    l_total_best = l_total_wCoverage0;
    #elif optMethod == "newCoverage":
    #    l_total_best = l_total_wNEWcoverage0;
    #elif optMethod == "coverRepErr":
    #    l_total_best = l_total_coverageRepeatedErr0;
    #elif optMethod == "coverRepAll":
    #    l_total_best = l_total_coverageRepeatedAll0;
    #best_struct_id = -1;

    if config.optDecompose:
	nodesRange = 3000;
        k = 100; 
	nodeSet = [list() for i in range(k)];
	for i in range(k):
	    nodeSet[i] = range(int(nodesRange/k) * i, int(nodesRange/k) * (i+1));
        #nodeSet1 = range(1000);
        #nodeSet2 = range(1000, 2000);
        #nodeSet3 = range(2000, 3000);
        subProbStruct = [list() for i in range(k)]; 
        subNodes = [list() for i in range(k)];
        for s in structs_not_selected:
            inter = [list() for i in range(k)];   
            percent = []; 
	    newStruct = m.loadLine(mContent, s);	
            # check node distribution among 3 node sets
            if newStruct.isFullClique():
                nodesSet = newStruct.nodes;
            elif newStruct.isChain():
                nodesSet = newStruct.nodes;
            elif newStruct.isStar():
                #nodesSet = sorted(newStruct.sNodes.append(newStruct.cNode));
                nodesSet = sorted(newStruct.sNodes);
            elif newStruct.isBiPartiteCore():
                nodesSet = sorted(newStruct.lNodes + newStruct.rNodes);
            else: print "Can't identify struct."
	    for i in range(k):
		inter[i] = set(nodeSet[i]).intersection(nodesSet); 
            #inter1 = set(nodeSet1).intersection(nodesSet);
            #inter2 = set(nodeSet2).intersection(nodesSet);
            #inter3 = set(nodeSet3).intersection(nodesSet);
		percent.append(len(inter[i])/float(len(nodesSet)));
            #percent1 = len(inter1)/float(len(nodesSet));
            #percent2 = len(inter2)/float(len(nodesSet));
            #percent3 = len(inter3)/float(len(nodesSet));
            #gap = max(nodesSet) - min(nodesSet);
            #print "struct%.0f :"%s + "{0:.0f}%\t".format(percent1 * 100) + "{0:.0f}%\t".format(percent2 * 100) + "{0:.0f}%\t".format(percent3 * 100) + "%.0f"%gap;
            #nodeDist = open('node_dist_choc.out','w');
            #if config.optDebug:
            #    nodeDist.write("struct%.0f: " %s + "{0:.0f}%\t".format(percent1 * 100) + "{0:.0f}%\t".format(percent2 * 100) + "{0:.0f}%\t".format(percent3 * 100));# + "%.0f\n" %gap);
            # assign struct to the set with highest interesection
            #percent = [percent1, percent2, percent3];
            subProbIdx = percent.index(max(percent));
            subNodes[subProbIdx].append(nodesSet);
            subProbStruct[subProbIdx].append(s); 
        if config.optDebug:
            print "structs in sub problems: " + str(subProbStruct);
        # permute node ID according to clusters
        newIdx = subNodes[0] + subNodes[1] + subNodes[2];
    
        # solve each sub problem individually
	subProbSummary = [];
	runtime = [];
	time_prev = t0;
        for i in range(k):
            print "solving the %.0f problem..." %i;
            structs_not_selected = range(0, len(subProbStruct[i]));  
            maxStructs = len(subProbStruct[i]);
            # reinitialize for the small problem
            # reinitialize the model for the greedy approach
            m = Model();
            # the encoding cost per structure is 0 initially
            lmodel_struct_prev = 0;
            E_x_old = E_0;
            E_x = E_0;
            structsInSummary = []; 
            times = 1;

            mFilename_list = mFilename.split('/');
            mFilename_main = mFilename_list[len(mFilename_list) - 1];
            print '%s' % mFilename_main
            mFilenameGreedy = 'optSubSelection_nStop_' + optMethod + '_' + mFilename_main + str(i);
            fgreedy = open(mFilenameGreedy,'w')
            mFilenameGreedyCost = 'optSubSelection_costs_' + optMethod + '_' + mFilename_main + str(i);
            fgreedyCost = open(mFilenameGreedyCost,'w')

            fgreedyCost.write("l_total_0: %.0f\n" % l_total_0 )
            l_total_x_best = l_total_0;
            l_total_best = l_total_0;
            best_struct_id = -1;
                   	
	    while times <= min(structLim, maxStructs) :  # add upto structLim structures or as many as there are in the model file  
	        print "time\t" + '%.0f' % times;
	        # add to the model the new structure
	        print "structs not selected: %.0f" % len(structs_not_selected);
	        struct_idx = 0;
	        structs_to_remove = [];
	        for s in structs_not_selected:
	            if struct_idx % 50 == 0:
	                print "LOADING BAR: trying out struct %.0f" % struct_idx + "(in model %.0f)" % s;
	            struct_idx += 1;
                    if config.optDebug:
    	                print "struct number: " + str(subProbStruct[i][s]);
	            newStruct = m.loadLine(mContent, subProbStruct[i][s]);
	            (l_total_x, l_model_x, l_model_struct, l_error_x, E_x, l_total_wCoverage, l_total_wNEWcoverage, l_total_coverageRepeatedErr, l_total_coverageRepeatedAll,toKeep) = Lgreedy(g, m, errorEnc, times, newStruct, l_total_prev, E_x_old, lmodel_struct_prev);
	            
	            # check if Ex and Ex_old are recovered properly
	            # print "============================================================================"
	            # print "When I first run Lgreedy"
	            # print "Ex_old:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x_old.numUnmodelledErrors, E_x_old.numModellingErrors, E_x_old.numCellsCovered, E_x_old.numCellsExcluded);
	            # print "Ex:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x.numUnmodelledErrors, E_x.numModellingErrors, E_x.numCellsCovered, E_x.numCellsExcluded);
	            # print "============================================================================"
	           
	            if toKeep == 'false':
	                structs_to_remove.append(subProbStruct[i][s]);
	            #if l_total_x > l_total_prev:
	                # probably this structure will never help
	                #print "Increased the cost of the graph encoding. Probably won't help. Difference = %.0f " % l_total_x + "-  %.0f = " % l_total_prev + "%.0f" % (l_total_x - l_total_prev);
	                #structs_to_remove.append(s);
	            print "%.0f :" % subProbStruct[i][s] + " l_total_x %.0f" % l_total_x + "\tl_total_x_best %.0f" % l_total_x_best + "\tl_total_best %.0f" % l_total_best + "\tl_total_wCoverage %.0f" % l_total_wCoverage + "\tl_total_wNEWcoverage %.0f" % l_total_wNEWcoverage;
	            print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
	            
	            if toKeep == 'false':
	                structs_to_remove.append(subProbStruct[i][s]);
	            elif toKeep == 'true': 
	                if optMethod == "simple":
	                    l_total_check = l_total_x;
	                elif optMethod == "coverage":
	                    l_total_check = l_total_wCoverage;
	                elif optMethod == "newCoverage":
	                    l_total_check = l_total_wNEWcoverage;
	                elif optMethod == "coverRepErr":
	                    l_total_check = l_total_coverageRepeatedErr;
	                elif optMethod == "coverRepAll":
	                    l_total_check = l_total_coverageRepeatedAll;
	                
	                #if l_total_check < l_total_best : # and 
	                if l_total_x < l_total_x_best : 
	                    print "%.0f :" % subProbStruct[i][s] + " l_total_x %.0f" % l_total_x + "\tl_total_best %.0f" % l_total_x_best + "\tl_total_best %.0f" % l_total_best + "\tl_total_check %.0f" % l_total_check + "\tl_total_wCoverage %.0f" % l_total_wCoverage + "\tl_total_wNEWcoverage %.0f" % l_total_wNEWcoverage;
	                    print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
	                    l_total_best = l_total_check;
	                    l_total_x_best = l_total_x;
	                    best_struct_id = subProbStruct[i][s];
	            
	            # remove the last added structure
	            #print "structs in model %.0f " % m.numStructs;
	            m.rmStructure(newStruct);
	            E_x.recoverOld();
	            #print "structs in model %.0f " % m.numStructs;
	            #E_x = copy.deepcopy(E_x_old); #E_x.recoverOld(); 
	            #print "============================================================================"
	            #print "When I recover E_x (E_x should be identical to E_x_old)"
	            #print "Ex_old:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x_old.numUnmodelledErrors, E_x_old.numModellingErrors, E_x_old.numCellsCovered, E_x_old.numCellsExcluded);
	            #print "Ex:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x.numUnmodelledErrors, E_x.numModellingErrors, E_x.numCellsCovered, E_x.numCellsExcluded);
	            #print "============================================================================"
	          
	        if best_struct_id >= 0:
		    subProbSummary.append(best_struct_id);
	            print "structs in model %.0f " % m.numStructs;
	            if config.optCompare :
	                 if m.numStructs == 20 :
	                         time20 = time() - t0;
	                         print "Running time for 20 structs: %.2f" % time20;
	                 elif m.numStructs == 50 :
	                         time50 = time() - t0;
	                         print "Running time for 50 structs: %.2f" % time50;
	                 elif m.numStructs == 100 :
	                         time100 = time() - t0;
	                         print "Running time for 100 structs: %.2f" % time100;
	            print "Adding the best struct id in the model: %.0f" % best_struct_id;
	            bestStruct = m.loadLine(mContent, best_struct_id);
	            # save the Error matrix to this point
	            (l_total_x, l_model_x, l_model_struct, l_error_x, E_x, l_total_wCoverage, l_total_wNEWcoverage, l_total_coverageRepeatedErr, l_total_coverageRepeatedAll, toKeep) = Lgreedy(g, m, errorEnc, times, bestStruct, l_total_prev, E_x_old, lmodel_struct_prev);
	            # save the Error matrix to this point
	            E_x_old = E_x;
	            print "============================================================================"
	            print " E_x_old = E_x (update old with new values)"
	            print "Ex_old:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x_old.numUnmodelledErrors, E_x_old.numModellingErrors, E_x_old.numCellsCovered, E_x_old.numCellsExcluded);
	            print "Ex:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x.numUnmodelledErrors, E_x.numModellingErrors, E_x.numCellsCovered, E_x.numCellsExcluded);
	            print "============================================================================"
	            #E_x_old = copy.deepcopy(E_x);
	            if bestStruct.isFullClique() :
	                print "nodes %.0f" % bestStruct.numNodes;
	            elif bestStruct.isNearClique() :
	                print "nodes %.0f" % bestStruct.numNodes;
	            elif bestStruct.isChain() :
	                print "nodes %.0f" % bestStruct.numNodes;
	            elif bestStruct.isStar() :
	                print "hub node %.0f" % bestStruct.cNode;
	            elif bestStruct.isBiPartiteCore() :
	                print "nodes %.0f" % bestStruct.numNodesLeft;
	            elif bestStruct.isNearBiPartiteCore() :
	                print "nodes %.0f" % bestStruct.numNodesLeft;
	            #(l_total_x, l_model_x, l_model_struct, l_error_x) = (l_total_x_best, l_model_x_best, l_model_struct_best, l_error_x_best);
	            print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
	            # print "kept the structure";
	            print "structs in model %.0f " % m.numStructs;
	            if optMethod == "simple":
	                l_total_prev = l_total_x;
	            elif optMethod == "coverage":
	                l_total_prev = l_total_wCoverage;
	            elif optMethod == "newCoverage":
	                l_total_prev = l_total_wNEWcoverage;
	            elif optMethod == "coverRepErr":
	                l_total_prev = l_total_coverageRepeatedErr;
	            elif optMethod == "coverRepAll":
	                l_total_prev = l_total_coverageRepeatedAll;
	            l_error_prev = l_error_x;
	            # update the up-to-now cost per structure
	            lmodel_struct_prev = l_model_struct;
	            structsInSummary.append(best_struct_id+1);
	            fgreedyCost.write("Time %.0f" % times + "\t%.0f\n" % l_total_x )
	            print "-----------------------------------------------------------"
	            # I need to remove multiple structures
	            #structs_not_selected.remove(best_struct_id)
	            print "Going to remove structures that do not help. Initial number of structs %.0f" % len(structs_not_selected);
	            structs_to_remove.append(best_struct_id);
	            remainingStructs = set(structs_not_selected).difference(set(structs_to_remove));
	            structs_not_selected = list(remainingStructs); 
	            #for sRm in structs_to_remove:
	            #   structs_not_selected.remove(sRm);
	            print "Number of remaining structs after removal %.0f" % len(structs_not_selected);
	            best_struct_id = -1;
	            toKeep = 'true';
	        # if none of the structures reduce the cost, just quit
	        else:
	            break;
	        if times == 10 or times % 200 == 0 :
	            mFilenameGreedyTemp = 'optSubSelection_' + optMethod + '_' + str(times) + '_' + mFilename_main + str(i);
	            fgreedyTemp = open(mFilenameGreedyTemp, 'w');
	            fgreedyTemp.write("Structures of model in the summary (each number is the corresponding line number of the structure in the model file)\n");
	            for line in structsInSummary:
	                # fgreedyTemp.write("%s" % line + "\t%s" % mContent[line]);
	                fgreedyTemp.write("%s\n" % line);
	            fgreedyTemp.close();
	        times += 1; 	
	    	
            print "structs in model %.0f " % m.numStructs;

	    for line in structsInSummary:
                fgreedy.write("%s\n" % line)

            fgreedy.close();
            fgreedyCost.close();
	    structsInSummary[:] = [x - 1 for x in structsInSummary];
            #subProbSummary += structsInSummary;
	    if config.optDebug:
	        print "updated selected list: " + str(subProbSummary);   

            runtime.append(time() - time_prev);
            time_prev = time();

    # do the final optimal selection in the sub models
    # reinitialize the model for the greedy approach
    m = Model();
                                                                                 
    # maximum number of structures considered
    structLim = 100000; # 10000;
    # read maxStructs structures from the model file and save it in modelContent
    mHandle = open(mFilename, 'r')
    mContent = mHandle.readlines();  #(structLim);
    structs_not_selected = range(0, len(subProbSummary)); 
    maxStructs = len(subProbSummary);
    lines_all = [];
                                                                                 
    if optMethod == "simple":
        l_total_prev = l_total_0;
    elif optMethod == "coverage":
        l_total_prev = l_total_wCoverage0;
    elif optMethod == "newCoverage":
        l_total_prev = l_total_wNEWcoverage0;
    elif optMethod == "coverRepErr":
        l_total_prev = l_total_coverageRepeatedErr0;
    elif optMethod == "coverRepAll":
        l_total_prev = l_total_coverageRepeatedAll0;
                                                                                 
    # the encoding cost per structure is 0 initially
    lmodel_struct_prev = 0;
    E_x_old = E_0; 
    E_x = E_0;
    structsInSummary = [];
    times = 1;

    t1 = time();

    mFilename_list = mFilename.split('/');                                                       
    mFilename_main = mFilename_list[len(mFilename_list) - 1];
    print '%s' % mFilename_main
    mFilenameGreedy = 'optSubSelection_nStop_' + optMethod + '_' + mFilename_main;
    fgreedy = open(mFilenameGreedy,'w')
    mFilenameGreedyCost = 'optSubSelection_costs_' + optMethod + '_' + mFilename_main;
    fgreedyCost = open(mFilenameGreedyCost,'w')
                                                                                         
    fgreedyCost.write("l_total_0: %.0f\n" % l_total_0 )
    l_total_x_best = l_total_0;
    if optMethod == "simple":
        l_total_best = l_total_0;
    elif optMethod == "coverage":
        l_total_best = l_total_wCoverage0;
    elif optMethod == "newCoverage":
        l_total_best = l_total_wNEWcoverage0;
    elif optMethod == "coverRepErr":
        l_total_best = l_total_coverageRepeatedErr0;
    elif optMethod == "coverRepAll":
        l_total_best = l_total_coverageRepeatedAll0;
    best_struct_id = -1;                                                                     

    print "doing the final optimal selection...\n";
    print "# structs to select from sub models %.0f\n" %len(subProbSummary); 

    while times <= min(structLim, maxStructs) :  # add upto structLim structures or as many as there are in the model file        
        print "time\t" + '%.0f' % times;
        # add to the model the new structure
        print "structs not selected: %.0f" % len(structs_not_selected);
        struct_idx = 0;
        structs_to_remove = [];
        for s in structs_not_selected:
            if struct_idx % 50 == 0:
                print "LOADING BAR: trying out struct %.0f" % struct_idx + "(in model %.0f)" % s;
            struct_idx += 1;
            if config.optDebug:
                print "struct number: " + str(subProbSummary[s]);
            newStruct = m.loadLine(mContent, subProbSummary[s]);
            (l_total_x, l_model_x, l_model_struct, l_error_x, E_x, l_total_wCoverage, l_total_wNEWcoverage, l_total_coverageRepeatedErr, l_total_coverageRepeatedAll,toKeep) = Lgreedy(g, m, errorEnc, times, newStruct, l_total_prev, E_x_old, lmodel_struct_prev);
            
            # check if Ex and Ex_old are recovered properly
            # print "============================================================================"
            # print "When I first run Lgreedy"
            # print "Ex_old:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x_old.numUnmodelledErrors, E_x_old.numModellingErrors, E_x_old.numCellsCovered, E_x_old.numCellsExcluded);
            # print "Ex:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x.numUnmodelledErrors, E_x.numModellingErrors, E_x.numCellsCovered, E_x.numCellsExcluded);
            # print "============================================================================"
           
            if toKeep == 'false':
                structs_to_remove.append(subProbSummary[s]);
            #if l_total_x > l_total_prev:
                # probably this structure will never help
                #print "Increased the cost of the graph encoding. Probably won't help. Difference = %.0f " % l_total_x + "-  %.0f = " % l_total_prev + "%.0f" % (l_total_x - l_total_prev);
                #structs_to_remove.append(s);
            print "%.0f :" % subProbSummary[s] + " l_total_x %.0f" % l_total_x + "\tl_total_x_best %.0f" % l_total_x_best + "\tl_total_best %.0f" % l_total_best + "\tl_total_wCoverage %.0f" % l_total_wCoverage + "\tl_total_wNEWcoverage %.0f" % l_total_wNEWcoverage;
            print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
            
            if toKeep == 'false':
                structs_to_remove.append(subProbSummary[s]);
            elif toKeep == 'true': 
                if optMethod == "simple":
                    l_total_check = l_total_x;
                elif optMethod == "coverage":
                    l_total_check = l_total_wCoverage;
                elif optMethod == "newCoverage":
                    l_total_check = l_total_wNEWcoverage;
                elif optMethod == "coverRepErr":
                    l_total_check = l_total_coverageRepeatedErr;
                elif optMethod == "coverRepAll":
                    l_total_check = l_total_coverageRepeatedAll;
                
                #if l_total_check < l_total_best : # and 
                if l_total_x < l_total_x_best : 
                    print "%.0f :" % subProbSummary[s] + " l_total_x %.0f" % l_total_x + "\tl_total_best %.0f" % l_total_x_best + "\tl_total_best %.0f" % l_total_best + "\tl_total_check %.0f" % l_total_check + "\tl_total_wCoverage %.0f" % l_total_wCoverage + "\tl_total_wNEWcoverage %.0f" % l_total_wNEWcoverage;
                    print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
                    l_total_best = l_total_check;
                    l_total_x_best = l_total_x;
                    best_struct_id = subProbSummary[s];
            
            # remove the last added structure
            #print "structs in model %.0f " % m.numStructs;
            m.rmStructure(newStruct);
            E_x.recoverOld();
            #print "structs in model %.0f " % m.numStructs;
            #E_x = copy.deepcopy(E_x_old); #E_x.recoverOld(); 
            #print "============================================================================"
            #print "When I recover E_x (E_x should be identical to E_x_old)"
            #print "Ex_old:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x_old.numUnmodelledErrors, E_x_old.numModellingErrors, E_x_old.numCellsCovered, E_x_old.numCellsExcluded);
            #print "Ex:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x.numUnmodelledErrors, E_x.numModellingErrors, E_x.numCellsCovered, E_x.numCellsExcluded);
            #print "============================================================================"
          
        if best_struct_id >= 0:
            print "structs in model %.0f " % m.numStructs;
            if config.optCompare :
                 if m.numStructs == 20 :
                         time20 = time() - t0;
                         print "Running time for 20 structs: %.2f" % time20;
                 elif m.numStructs == 50 :
                         time50 = time() - t0;
                         print "Running time for 50 structs: %.2f" % time50;
                 elif m.numStructs == 100 :
                         time100 = time() - t0;
                         print "Running time for 100 structs: %.2f" % time100;
            print "Adding the best struct id in the model: %.0f" % best_struct_id;
            bestStruct = m.loadLine(mContent, best_struct_id);
            # save the Error matrix to this point
            (l_total_x, l_model_x, l_model_struct, l_error_x, E_x, l_total_wCoverage, l_total_wNEWcoverage, l_total_coverageRepeatedErr, l_total_coverageRepeatedAll, toKeep) = Lgreedy(g, m, errorEnc, times, bestStruct, l_total_prev, E_x_old, lmodel_struct_prev);
            # save the Error matrix to this point
            E_x_old = E_x;
            print "============================================================================"
            print " E_x_old = E_x (update old with new values)"
            print "Ex_old:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x_old.numUnmodelledErrors, E_x_old.numModellingErrors, E_x_old.numCellsCovered, E_x_old.numCellsExcluded);
            print "Ex:  numUnmodelledErrors = %.0f, numModellingErrors = %.0f, numCellsCovered = %.0f, numCellsExcluded = %.0f" % (E_x.numUnmodelledErrors, E_x.numModellingErrors, E_x.numCellsCovered, E_x.numCellsExcluded);
            print "============================================================================"
            #E_x_old = copy.deepcopy(E_x);
            if bestStruct.isFullClique() :
                print "nodes %.0f" % bestStruct.numNodes;
            elif bestStruct.isNearClique() :
                print "nodes %.0f" % bestStruct.numNodes;
            elif bestStruct.isChain() :
                print "nodes %.0f" % bestStruct.numNodes;
            elif bestStruct.isStar() :
                print "hub node %.0f" % bestStruct.cNode;
            elif bestStruct.isBiPartiteCore() :
                print "nodes %.0f" % bestStruct.numNodesLeft;
            elif bestStruct.isNearBiPartiteCore() :
                print "nodes %.0f" % bestStruct.numNodesLeft;
            #(l_total_x, l_model_x, l_model_struct, l_error_x) = (l_total_x_best, l_model_x_best, l_model_struct_best, l_error_x_best);
            print "M_x:\t" + '%.0f' % l_total_x + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_x + "\t" + str(E_x.numModellingErrors) + '/' + str(E_x.numCellsCovered) + '\t' + str(E_x.numUnmodelledErrors)  + '/' + str(((E_x.numNodes * E_x.numNodes)-E_x.numNodes) - E_x.numCellsCovered) + '\t\t' + str(E_x.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;
            # print "kept the structure";
            print "structs in model %.0f " % m.numStructs;
            if optMethod == "simple":
                l_total_prev = l_total_x;
            elif optMethod == "coverage":
                l_total_prev = l_total_wCoverage;
            elif optMethod == "newCoverage":
                l_total_prev = l_total_wNEWcoverage;
            elif optMethod == "coverRepErr":
                l_total_prev = l_total_coverageRepeatedErr;
            elif optMethod == "coverRepAll":
                l_total_prev = l_total_coverageRepeatedAll;
            l_error_prev = l_error_x;
            # update the up-to-now cost per structure
            lmodel_struct_prev = l_model_struct;
            structsInSummary.append(best_struct_id+1);
            fgreedyCost.write("Time %.0f" % times + "\t%.0f\n" % l_total_x )
            print "-----------------------------------------------------------"
            # I need to remove multiple structures
            #structs_not_selected.remove(best_struct_id)
            print "Going to remove structures that do not help. Initial number of structs %.0f" % len(structs_not_selected);
            structs_to_remove.append(best_struct_id);
            remainingStructs = set(structs_not_selected).difference(set(structs_to_remove));
            structs_not_selected = list(remainingStructs); 
            #for sRm in structs_to_remove:
            #   structs_not_selected.remove(sRm);
            print "Number of remaining structs after removal %.0f" % len(structs_not_selected);
            best_struct_id = -1;
            toKeep = 'true';
        # if none of the structures reduce the cost, just quit
        else:
            break;
        if times == 10 or times % 200 == 0 :
            mFilenameGreedyTemp = 'optSubSelection_' + optMethod + '_' + str(times) + '_' + mFilename_main + str(i);
            fgreedyTemp = open(mFilenameGreedyTemp, 'w');
            fgreedyTemp.write("Structures of model in the summary (each number is the corresponding line number of the structure in the model file)\n");
            for line in structsInSummary:
                # fgreedyTemp.write("%s" % line + "\t%s" % mContent[line]);
                fgreedyTemp.write("%s\n" % line);
            fgreedyTemp.close();
        times += 1; 
	
    # output final cost
    output = open('out_final_opt.out','w');
    output.write("M_x:\t" + '%.0f' % l_total_prev + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_prev + "\t" + str(E_x_old.numModellingErrors) + '/' + str(E_x_old.numCellsCovered) + '\t' + str(E_x_old.numUnmodelledErrors)  + '/' + str(((E_x_old.numNodes * E_x_old.numNodes)-E_x_old.numNodes) - E_x_old.numCellsCovered) + '\t\t' + str(E_x_old.numCellsExcluded));
    ##output.write("M_x:\t" + '%.0f' % l_total_prev + "\t" + '%.0f' % l_model_x + "\t" + '%.0f' % l_error_prev + "\t" + str(E_x_old.numModellingErrors) + '/' + str(E_x_old.numCellsCovered) + '\t' + str(E_x_old.numUnmodelledErrors)  + '/' + str(((E_x_old.numNodes * E_x_old.numNodes)-E_x_old.numNodes) - E_x_old.numCellsCovered) + '\t\t' + str(E_x_old.numCellsExcluded) + '\t\t%.0f' % l_total_wCoverage + '\t%.0f' % l_total_wNEWcoverage  + "\t\t%.0f" % l_total_coverageRepeatedErr + "\t%.0f" % l_total_coverageRepeatedAll;)
    #output.close();

    print "structs in model %.0f " % m.numStructs;

    for line in structsInSummary:
        fgreedy.write("%s\n" % line)
    
    fgreedy.close();
    fgreedyCost.close();


if (len(sys.argv) > 3 and "-pG" in sys.argv) :
    print "Adjacency matrix:";
    g.plot();

if (len(sys.argv) > 3 and "-pC" in sys.argv) :
    print "Cover matrix:";
    E_x.plotCover();

if (len(sys.argv) > 3 and "-pE" in sys.argv) :
    print "Error matrix:";    
    E_x.plotError();

if (len(sys.argv) > 3 and "-lC" in sys.argv) :
    print "Cover list:";
    E_x.listCover();

if (len(sys.argv) > 3 and "-lE" in sys.argv) :
    print "Error list:";    
    E_x.listError();

#print time()-t0
print runtime;    
print "Total running time of final selection %.2f" % (time()-t1);
print "Total running time: %.2f" % (max(runtime) + time() - t1);

mHandle.close()
if config.optDecompose and config.optDebug:
	nodeDist.close();
