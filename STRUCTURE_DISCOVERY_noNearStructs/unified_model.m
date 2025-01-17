%% create unified model of all clustering methods
modelSL = load('SlashBurn/model.mat');
modelK = load('Kcores/model.mat');
modelL = load('Louvain/model.mat');
modelM = load('Metis/model.mat');
modelSP = load('Spectral/model.mat');

modelSL = modelSL.model_ordered;
modelK = modelK.model_ordered;
modelL = modelL.model_ordered;
modelM = modelM.model_ordered;
modelSP = modelSP.model_ordered;

modelField = fieldnames(modelSL);

modelSL = struct2cell(modelSL);
modelK = struct2cell(modelK);
modelL = struct2cell(modelL);
modelM = struct2cell(modelM);
modelSP = struct2cell(modelSP);

% concatenate models
modelCell = cat(3, modelSL, modelK, modelL, modelM, modelSP);
modelUni = cell2struct(modelCell, modelField, 1);

% sort structs by benefit cost
[~, order] = sort([modelUni(:).benefit_notEnc], 'descend');
modelUniOrdered = modelUni(order);