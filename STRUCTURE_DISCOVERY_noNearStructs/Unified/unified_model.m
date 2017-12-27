function [] = unified_model(outFolder, fname)
clear randOrder;
%% create unified model of all clustering methods
%outFolder = '../../DATA/Unified';
%fname = 'chocMediaWiki.sentenceEdges';
addpath('../');

benefit_rank = true;
permutation = false;

tic

modelSL = load('../SlashBurn/model.mat');
modelK = load('../Kcores/model.mat');
modelL = load('../Louvain/model.mat');
modelM = load('../Metis/model.mat');
modelSP = load('../Spectral/model.mat');
modelBI = load('../BigClam/model.mat');
modelH = load('../Hyperbolic/model.mat');

modelSL = modelSL.model_ordered;
modelK = modelK.model_ordered;
modelL = modelL.model_ordered;
modelM = modelM.model_ordered;
modelSP = modelSP.model_ordered;
modelBI = modelBI.model_ordered;
modelH = modelH.model_ordered;

modelField = fieldnames(modelSL);

modelSL = struct2cell(modelSL);
modelK = struct2cell(modelK);
modelL = struct2cell(modelL);
modelM = struct2cell(modelM);
modelSP = struct2cell(modelSP);
modelBI = struct2cell(modelBI);
modelH = struct2cell(modelH);

% add method labels
modelSL(8,:,:) = {'SL'};
modelK(8,:,:) = {'K'};
modelL(8,:,:) = {'L'};
modelM(8,:,:) = {'M'};
modelSP(8,:,:) = {'SP'};
modelBI(8,:,:) = {'BI'};
modelH(8,:,:) = {'H'};

modelField(8) = {'method'};

% concatenate models
modelCell = cat(3, modelSL, modelK, modelL, modelM, modelSP, modelBI, modelH);
% concatenate without sorting and SL at the end
%modelCell = cat(3, modelK, modelL, modelSP, modelM, modelSL);
modelUni = cell2struct(modelCell, modelField, 1);

if benefit_rank == true
    % sort structs by benefit cost
    [~, order] = sort([modelUni(:).benefit_notEnc], 'descend');
    modelUniOrdered = modelUni(order);
elseif permutation == true
    % random permutation
    numStructs = size(modelCell, 3);
    s = RandStream('mt19937ar','Seed','shuffle');
    RandStream.setGlobalStream(s);
    randOrder = randperm(s, numStructs);
    % rank structs by benefit for mapping
    [~, order] = sort([modelUni(:).benefit_notEnc], 'descend');
    modelUni = modelUni(order);
    modelUniOrdered = modelUni(randOrder);
    % save mapping of permutation
    save('perm_map.mat', 'order', 'randOrder');
else
    % concatenate without sorting
    modelUniOrdered = modelUni;
end

runtime = toc
time_stored = sprintf('%s/%s_runtime.txt', outFolder, fname);
save(time_stored, 'runtime', '-ascii');

save('model.mat', 'modelUniOrdered');
mkdir('../../DATA/Unified');
copyfile('model.mat', '../../DATA/Unified');
try
copyfile('perm_map.mat', '../../DATA/Unified');
catch
end
%outFolder = '../DATA/Unified';
%[~, fname, ~] = fileparts(graphFile);
outfile_ordered_unified = sprintf('%s/%s_orderedALL.model', outFolder, fname);
printModel(modelUniOrdered, outfile_ordered_unified);
all_costs = 0;
all_costs_incStruct = 0;

disp('=== Graph decomposition and structure labeling: finished! ===')

%fclose(out_fid);

