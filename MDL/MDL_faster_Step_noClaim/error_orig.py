from graph import Graph;

class Error :
    numNodes = 0;

    # 1s present in G but not in M    
    numUnmodelledErrors = 0;
    unmodelled = [];
    unmodelledLast = [];
    numUnmodelledErrorsOld = 0;
    unmodelledOld = [];
    

    # incorrect cell values in M wrt G
    numModellingErrors = 0;
    modelled = [];
    modelledLast = [];
    numModellingErrorsOld = 0;
    modelledOld = [];

    # number of unique cells in M
    numCellsCovered = 0;
    covered = [];
    coveredLast = [];
    numCellsCoveredOld = 0;
    coveredOld = [];

    # number of cells directly encoded by M, no error possible
    numCellsExcluded = 0;
    excluded = [];
    excludedLast = [];
    numCellsExcludedOld = 0;
    excludedOld = [];

    
    def __init__(self, graph, err = None):

        if err is None :
            self.numNodes = graph.numNodes;

            self.unmodelled = [set(x) for x in graph.edges];
            self.unmodelledLast = [];
            self.numUnmodelledErrors = graph.numEdges;

            self.modelled = [set() for x in range(len(graph.edges))];
            self.modelledLast = [];
            self.numModellingErrors = 0;
        
            self.covered = [set() for i in range(self.numNodes)];
            self.coveredLast = [];
            self.numCellsCovered = 0;

            self.excluded = [set() for i in range(self.numNodes)];
            self.excludedLast = [];
            self.numCellsExcluded = 0;
        else :
            self.numNodes = err.numNodes;

            self.unmodelled = [set(x) for x in err.unmodelled];
            self.numUnmodelledErrors = err.numUnmodelledErrors;

            self.modelled = [set(x) for x in err.modelled];
            self.numModellingErrors = err.numModellingErrors;

            self.covered = [set(x) for x in err.covered];
            self.numCellsCovered = err.numCellsCovered;

            self.excluded = [set(x) for x in err.excluded];
            self.numCellsExcluded = err.numCellsExcluded;

    def resetLast(self) :
       
        self.unmodelledLast = [];
        self.modelledLast = [];
        self.coveredLast = [];
        self.excludedLast = [];

    
    def recoverOld(self):

        # print "Unmodelled Before struct removal: %.0f" %  self.numUnmodelledErrors;
        # print "Modelling Before struct removal: %.0f" % self.numModellingErrors;
        # print "Covered Before struct removal: %.0f" % self.numCellsCovered;
        # print "Excluded Before struct removal: %.0f" % self.numCellsExcluded;


        for x in self.unmodelledLast:
            (i,j,k) = x;
            if k == 0:
                self.delUnmodelledError(i,j);
            elif k == 1:
                self.addUnmodelledError(i,j);

        for x in self.modelledLast:
            (i,j,k) = x;
            if k == 0:
                self.delModellingError(i,j);
            elif k == 1:
                self.addModellingError(i,j);
        
        for x in self.coveredLast:
            (i,j,k) = x;
            self.uncover(i,j);
   
        for x in self.excludedLast:
            (i,j,k) = x;
            self.unexclude(i,j);    
        
       # print "Unmodelled After struct removal: %.0f " % self.numUnmodelledErrors;
       # print "Modelling After struct removal: %.0f " % self.numModellingErrors;
       # print "Covered After struct removal: %.0f " % self.numCellsCovered;
       # print "Excluded After struct removal: %.0f " % self.numCellsExcluded;
              
        self.resetLast();

    # checks whether edge (i,j) is covered
    def isModelled(self, i, j) :
        return (max(i,j)-1 in self.covered[min(i,j)-1]);
    def isCovered(self, i, j) :
        return self.isModelled(i,j);
        
    # annotates edge (i,j) as covered
    # ! (i,j) does not have to be in E of G(V,E)
    def cover(self, i, j) :
        self.covered[min(i,j)-1].add(max(i,j)-1);
        self.numCellsCovered += 1;
        return;

    def uncover(self, i, j) :
        self.covered[min(i,j)-1].remove(max(i,j)-1);
        self.numCellsCovered -= 1;
        return;

    # keep track of the changes for Error greedy   
    def updateCoveredLast(self, i, j, k) :
        self.coveredLast.append((i,j,k));

    # annotates edge (i,j) as both covered, and error-free
    # ! (i,j) does not have to be in E of G(V,E)
    def coverAndExclude(self, i, j) :
        self.cover(i,j)
        self.exclude(i,j);
        return;
        
    def exclude(self, i, j) :
        self.excluded[min(i,j)-1].add(max(i,j)-1);
        self.numCellsExcluded += 1;
        return;
     
    def unexclude(self, i, j) :
        self.excluded[min(i,j)-1].remove(max(i,j)-1);
        self.numCellsExcluded -= 1;
        return;

    # keep track of the changes for Error greedy   
    def updateExcludedLast(self, i, j, k) :
        self.excludedLast.append((i,j,k));

    def isError(self, i, j):
        return max(i,j)-1 in self.unmodelled[min(i,j)-1] or max(i,j)-1 in self.modelled[min(i,j)-1];
        
    def isExcluded(self, i, j):
        return max(i,j)-1 in self.excluded[min(i,j)-1];
        
    def isUnmodelledError(self, i, j):
        return max(i,j)-1 in self.unmodelled[min(i,j)-1];
    def isUnmodelledEdge(self, i, j):
        return self.isUnmodelledError(i,j);

    def isModellingError(self, i, j):
        return max(i,j)-1 in self.modelled[min(i,j)-1];

    # annotates edge (i,j) as correct
    def delError(self, i, j) :
        if self.isUnmodelledError(i,j) :
            self.delUnmodelledError(i,j);
        else :
            self.delModellingError(i,j);      

    # annotates edge (i,j) as not-modelled
    def addUnmodelledError(self, i, j) :
        self.unmodelled[min(i,j)-1].add(max(i,j)-1);
        self.numUnmodelledErrors += 1;
        
    # annotates edge (i,j) as correctly modelled
    def delUnmodelledError(self, i, j) :
        self.unmodelled[min(i,j)-1].remove(max(i,j)-1);
        self.numUnmodelledErrors -= 1;

    # keep track of the changes for Error greedy   
    def updateUnmodelledLast(self, i, j, k) :
        self.unmodelledLast.append((i,j,k));

    # annotates edge (i,j) as erronously modelled
    def addModellingError(self, i, j) :
        self.modelled[min(i,j)-1].add(max(i,j)-1);
        self.numModellingErrors += 1;

    # annotates edge (i,j) as incorrectly modelled
    def delModellingError(self, i, j) :
        self.modelled[min(i,j)-1].remove(max(i,j)-1);
        self.numModellingErrors -= 1;

    # keep track of the changes for Error greedy   
    def updateModellingLast(self, i, j, k) :
        self.modelledLast.append((i,j,k));

    def plotCover(self):
        for idx in range(len(self.covered)) :
            mystr = "".join(["." for x in range(0,idx+1)]);
            for idy in range(idx+1,len(self.covered)) :
                if idy in self.covered[idx] :
                    mystr += "1";
                else :
                    mystr += "-";
            print mystr;

    def plotError(self):
        for idx in range(len(self.unmodelled)) : # uses 'unmodelled' only as numNodes
            mystr = "".join(["." for x in range(0,idx+1)]);
            for idy in range(idx+1,len(self.unmodelled)) :
                if idy in self.covered[idx] :
                    if idy in self.excluded[idx] :
                        mystr += "*";
                    elif idy in self.modelled[idx] :
                        mystr += "+";
                    else :
                        mystr += "-";
                else :
                    if idy in self.unmodelled[idx] :
                        mystr += "1";
                    else :
                        mystr += "0";
            print mystr;

    def plotExcluded(self):
        for idx in range(len(self.excluded)) :
            mystr = "".join(["." for x in range(0,idx+1)]);
            for idy in range(idx+1,len(self.excluded)) :
                if idy in self.excluded[idx] :
                    mystr += "1";
                else :
                    mystr += "0";
            print mystr;

    def listCover(self):
        print self.covered;
    
    def listError(self):
        for idx in range(len(self.unmodelled)) :
            if len(self.unmodelled[idx]) > 0 :
                print idx+1, "+: "+str([x+1 for x in self.unmodelled[idx]]), "-: "+str([x+1 for x in self.modelled[idx]]),;

    def listExcluded(self):
        print self.excluded;
