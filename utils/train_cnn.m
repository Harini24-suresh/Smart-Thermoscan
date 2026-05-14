%% =================== Improved CNN for Small Tabular Data ===================

% Load dataset
load dataset.mat  % X (features), Y (labels: 0,1,2)
fprintf("Loaded dataset: %d samples, %d features\n", size(X,1), size(X,2));

% Convert labels to categorical
Y_cat = categorical(Y);

% ------------------- Feature Selection -------------------
numTopFeatures = 50; % Adjust for experiment
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
        % Random oversampling with replacement
        idxSample = randsample(length(Yc), reps*length(Yc), true);
        Xc = Xc(idxSample, :);
        Yc = Yc(idxSample, :);
    end
    X_balanced = [X_balanced; Xc];
    Y_balanced = [Y_balanced; Yc];
end

Y_balanced_cat = categorical(Y_balanced);

% ------------------- Normalize Features -------------------
X_balanced = normalize(X_balanced);

% ------------------- Train/Test Split -------------------
cv = cvpartition(Y_balanced_cat,'HoldOut',0.2);
Xtrain = X_balanced(training(cv), :);
Ytrain = Y_balanced_cat(training(cv));
Xtest  = X_balanced(test(cv), :);
Ytest  = Y_balanced_cat(test(cv));

% ------------------- Define CNN Network -------------------
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

% ------------------- Training Options -------------------
options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{Xtest,Ytest}, ...
    'Verbose',false, ...
    'Plots','training-progress');

% ------------------- Train CNN -------------------
cnnModel = trainNetwork(Xtrain, Ytrain, layers, options);

% ------------------- Evaluate -------------------
Ypred = classify(cnnModel, Xtest);
cm = confusionmat(Ytest, Ypred);
disp('Improved CNN Confusion Matrix:');
disp(cm);

testAcc = sum(Ypred == Ytest)/numel(Ytest) * 100;
fprintf("\n✅ Improved CNN Test Accuracy: %.2f %%\n", testAcc);
