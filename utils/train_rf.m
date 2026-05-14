%% =================== Improved Random Forest with OOB ===================

% Load dataset
load dataset.mat  % X (features), Y (labels: 0,1,2)
fprintf("Loaded dataset: %d samples, %d features\n", size(X,1), size(X,2));

% Convert labels to categorical
Y_cat = categorical(Y);

% ------------------- Feature Selection -------------------
numTopFeatures = 50; % Adjust as needed
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
        reps = ceil(sum(Y==0)/length(Yc)); % upsample to match majority
        Xc = repmat(Xc, reps, 1);
        Yc = repmat(Yc, reps, 1);
    end
    X_balanced = [X_balanced; Xc];
    Y_balanced = [Y_balanced; Yc];
end

Y_balanced_cat = categorical(Y_balanced);

% ------------------- Train/Test Split -------------------
cv = cvpartition(Y_balanced_cat, 'HoldOut', 0.2);
Xtrain = X_balanced(training(cv), :);
Ytrain = Y_balanced_cat(training(cv));
Xtest  = X_balanced(test(cv), :);
Ytest  = Y_balanced_cat(test(cv));

% ------------------- Compute Class Weights -------------------
tab = tabulate(double(Ytrain));
counts = tab(:,2);
classWeights = sum(counts) ./ (numel(counts) * counts);
Ytrain_num = double(string(Ytrain));

% ------------------- Train Random Forest -------------------
numTrees = 300;
RFModel = TreeBagger(numTrees, Xtrain, Ytrain, ...
    'Method','classification', ...
    'OOBPrediction','on', ...
    'ClassNames', categorical([0 1 2]), ...
    'Weights', arrayfun(@(y) classWeights(y+1), Ytrain_num), ...
    'MinLeafSize',2, ...
    'MaxNumSplits',50);

% ------------------- Evaluate on Test Set -------------------
Ypred_RF = predict(RFModel, Xtest);
Ypred_RF = categorical(str2double(Ypred_RF));

cm_RF = confusionmat(Ytest, Ypred_RF);
disp('Random Forest Confusion Matrix:');
disp(cm_RF);

testAcc_RF = sum(Ypred_RF == Ytest) / numel(Ytest) * 100;
fprintf("\n✅ RF Test Accuracy: %.2f %%\n", testAcc_RF);

% ------------------- Out-of-Bag Error -------------------
oobErr = oobError(RFModel);
figure;
plot(oobErr, 'LineWidth',2);
xlabel('Number of Trees'); ylabel('OOB Error');
title('Random Forest Out-of-Bag Error');
grid on;

% OOB Accuracy
oobAcc = (1 - oobErr(end)) * 100;
fprintf('✅ RF Out-of-Bag Accuracy: %.2f %%\n', oobAcc);
