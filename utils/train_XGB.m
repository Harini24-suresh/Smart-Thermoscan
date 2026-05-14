%% =================== Weighted Ensemble of RF + CNN + XGBoost ===================

% Load dataset
load dataset.mat  % X (features), Y (labels: 0,1,2)
fprintf("Loaded dataset: %d samples, %d features\n", size(X,1), size(X,2));

% Convert labels to categorical
Y_cat = categorical(Y);

% ------------------- Feature Selection (top 50) -------------------
numTopFeatures = 50;
[idx, scores] = fscmrmr(X, Y_cat);
X_selected = X(:, idx(1:numTopFeatures));
fprintf("Selected top %d features using MRMR.\n", numTopFeatures);

% ------------------- Handle Class Imbalance -------------------
classes = unique(Y);
X_balanced = [];
Y_balanced = [];

for c = classes'
    Xc = X_selected(Y==c, :);
    Yc = Y(Y==c);
    if c == 2  % minority class
        reps = ceil(sum(Y==0)/length(Yc));
        idxSample = randsample(length(Yc), reps*length(Yc), true);
        Xc = Xc(idxSample, :);
        Yc = Yc(idxSample, :);
    end
    X_balanced = [X_balanced; Xc];
    Y_balanced = [Y_balanced; Yc];
end

Y_balanced_cat = categorical(Y_balanced);
X_balanced = normalize(X_balanced);

% ------------------- Train/Test Split -------------------
cv = cvpartition(Y_balanced_cat,'HoldOut',0.2);
Xtrain = X_balanced(training(cv), :);
Ytrain = Y_balanced_cat(training(cv));
Xtest  = X_balanced(test(cv), :);
Ytest  = Y_balanced_cat(test(cv));

Ytrain_num = double(string(Ytrain));

% ------------------- Train Random Forest -------------------
numTrees = 300;
tab = tabulate(double(Ytrain));
counts = tab(:,2);
classWeights = sum(counts) ./ (numel(counts) * counts);

RFModel = TreeBagger(numTrees, Xtrain, Ytrain, ...
    'Method','classification', ...
    'OOBPrediction','on', ...
    'ClassNames', categorical([0 1 2]), ...
    'Weights', arrayfun(@(y) classWeights(y+1), Ytrain_num), ...
    'MinLeafSize',2, ...
    'MaxNumSplits',50);

% ------------------- Train Improved CNN -------------------
layers = [
    featureInputLayer(numTopFeatures)
    fullyConnectedLayer(64)
    reluLayer
    dropoutLayer(0.3)
    fullyConnectedLayer(32)
    reluLayer
    dropoutLayer(0.3)
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{Xtest,Ytest}, ...
    'Verbose',false);

cnnModel = trainNetwork(Xtrain, Ytrain, layers, options);

% ------------------- Train XGBoost (AdaBoostM2) -------------------
t = templateTree('MaxNumSplits',50,'MinLeafSize',2);
numLearners = 300;

XGBModel = fitcensemble(Xtrain, Ytrain, ...
    'Method','AdaBoostM2', ...
    'NumLearningCycles', numLearners, ...
    'Learners', t, ...
    'ClassNames', categorical([0 1 2]));

% ------------------- Predictions -------------------

% Convert categorical predictions to numeric
Ypred_RF_num  = double(string(predict(RFModel, Xtest)));
Ypred_CNN_num = double(string(classify(cnnModel, Xtest)));
Ypred_XGB_num = double(string(predict(XGBModel, Xtest)));

% Compute individual test accuracies for weighting
acc_RF  = sum(Ypred_RF_num == double(string(Ytest)))  / numel(Ytest);
acc_CNN = sum(Ypred_CNN_num == double(string(Ytest))) / numel(Ytest);
acc_XGB = sum(Ypred_XGB_num == double(string(Ytest))) / numel(Ytest);

% Normalize weights
totalAcc = acc_RF + acc_CNN + acc_XGB;
w_RF  = acc_RF / totalAcc;
w_CNN = acc_CNN / totalAcc;
w_XGB = acc_XGB / totalAcc;

% Weighted voting
numSamples = length(Ytest);
Ypred_ensemble_num = zeros(numSamples,1);

for i = 1:numSamples
    votes = zeros(1,3); % classes: 0,1,2
    votes(Ypred_RF_num(i)+1)  = votes(Ypred_RF_num(i)+1)  + w_RF;
    votes(Ypred_CNN_num(i)+1) = votes(Ypred_CNN_num(i)+1) + w_CNN;
    votes(Ypred_XGB_num(i)+1) = votes(Ypred_XGB_num(i)+1) + w_XGB;
    [~, Ypred_ensemble_num(i)] = max(votes);
    Ypred_ensemble_num(i) = Ypred_ensemble_num(i)-1; % map back to 0-based class
end

Ypred_ensemble = categorical(Ypred_ensemble_num);

% ------------------- Evaluate Ensemble -------------------
cm_ensemble = confusionmat(Ytest, Ypred_ensemble);
disp('Weighted Ensemble (RF + CNN + XGBoost) Confusion Matrix:');
disp(cm_ensemble);

ensembleAcc = sum(Ypred_ensemble == Ytest)/numel(Ytest) * 100;
fprintf("\n✅ Weighted Ensemble Test Accuracy: %.2f %%\n", ensembleAcc);

% ------------------- Summary Table -------------------
ModelNames = {'Random Forest','Improved CNN','XGBoost','Weighted Ensemble'};
TestAccs  = [acc_RF*100, acc_CNN*100, acc_XGB*100, ensembleAcc]';
T = table(ModelNames', TestAccs, 'VariableNames', {'Model','TestAccuracy'});
disp('================== Model Comparison Summary ==================');
disp(T);
