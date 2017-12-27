import config;
import mdl_base;
import mdl_structs;

from math import log,factorial;
from error import Error;
from graph import Graph;
from model import Model;

from mdl_base import LU,LnU;
from mdl_structs import *;

### Encoding the Error

# here I encode all errors uniformly by a binomial -- hence, not yet the typed advanced stuff yet!
def LErrorNaiveBinom(G, M, E) :
    # possible number of edges in an undirected, non-self-connected graph of N nodes
    posNumEdges = (G.numNodes * G.numNodes - G.numNodes) / 2
    cost = LU(posNumEdges - E.numCellsExcluded, E.numUnmodelledErrors + E.numModellingErrors);
    if config.optVerbosity > 1 : print ' - L_nb(E)', cost;
    return cost;

def LErrorNaivePrefix(G, M, E) :
    # possible number of edges in an undirected, non-self-connected graph of N nodes
    posNumEdges = (G.numNodes * G.numNodes - G.numNodes) / 2
    cost = LnU(posNumEdges - E.numCellsExcluded, E.numModellingErrors + E.numUnmodelledErrors);
    if config.optVerbosity > 1 : print ' - L_np(E)', cost;
    return cost;

# here I encode all errors uniformly by a binomial -- hence, not yet the typed advanced stuff yet!
def LErrorTypedBinom(G, M, E) :
    # possible number of edges in an undirected, non-self-connected graph of N nodes
    posNumEdges = (G.numNodes * G.numNodes - G.numNodes) / 2
    
    # First encode the modelling errors
    #print 'First encode the modelling errors'
    #print 'E.numCellsCovered, E.numCellsExcluded, E.numModellingErrors;'
    #print E.numCellsCovered, E.numCellsExcluded, E.numModellingErrors;
    costM = LU(E.numCellsCovered - E.numCellsExcluded, E.numModellingErrors);
    if config.optVerbosity > 1 : print ' - L_tb(E+)', costM;

    # Second encode the unmodelled errors
    #print 'Second encode the unmodelled errors' (excluded cells are always covered!)
    #print posNumEdges - E.numCellsCovered, E.numUnmodelledErrors;
    costU = LU(posNumEdges - E.numCellsCovered, E.numUnmodelledErrors);
    if config.optVerbosity > 1 : print ' - L_tb(E-)', costU;
    return costM + costU;

def LErrorTypedPrefix(G, M, E) :
    # possible number of edges in an undirected, non-self-connected graph of N nodes
    posNumEdges = (G.numNodes * G.numNodes - G.numNodes) / 2
    costM = LnU(E.numCellsCovered - E.numCellsExcluded, E.numModellingErrors);
    if config.optVerbosity > 1 : print ' - L_tp(E+)', costM;
    costU = LnU(posNumEdges - E.numCellsCovered, E.numUnmodelledErrors);
    if config.optVerbosity > 1 : print ' - L_tp(E-)', costU;
    #print E.numCellsCovered, E.numCellsExcluded, E.numModellingErrors, posNumEdges, E.numUnmodelledErrors;
    if config.optOverlap :
        # possible number of edges overlapped, number of edges overlapped
        #costO = LnU(E.numCellsCovered - E.numCellsExcluded, E.numEdgeOverlapped);
        countOverlappedCells = E.listToSet();
        if config.optDebug :
                print "overlap counts: " + str(countOverlappedCells);
        numOverlappedCells = len(countOverlappedCells);
        if config.optDebug :
                print "# overlaps: " + str(numOverlappedCells);
        if numOverlappedCells >= 1 :
                costO = log(numOverlappedCells, 2);
                costO += LnU(posNumEdges, posNumEdges-numOverlappedCells);
		for i in range(len(countOverlappedCells)) :
                        for j in range(len(countOverlappedCells[i])) :
                                if config.optDebug :
                                        print "i: " + str(i) + " j: " + str(j);
                                costO += LN(countOverlappedCells[i][j]);
        else : costO = 0;

    if config.optOverlap :
        return costM + costU + costO;
    else :
    	return costM + costU;
