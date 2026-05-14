%% Train Weighted SVM Classifier for ThermoScan Data

% Load dataset
load dataset.mat
fprintf("Loaded dataset: %d samples, %d features\n", size(X,1), size(X,2));

% Class distribution
tab = tabulate(Y);
disp("Class distribution:");
disp(tab(:,2)');

% Define class weights (inverse frequency)
counts = tab(:,2);              % sample counts
classWeights = sum(counts) ./ (numel(counts) * counts);  
fprintf("\nClass Weights (higher = more importance):\n");
disp(classWeights);

% Convert labels to categorical
Y_cat = categorical(Y);

% Split dataset into train/test (80/20)
cv = cvpartition(Y_cat, 'HoldOut', 0.2);
Xtrain = X(training(cv), :);
Ytrain = Y_cat(training(cv));
Xtest  = X(test(cv), :);
Ytest  = Y_cat(test(cv));

% Map categorical labels back to numeric [0,1,2]
Ytrain_num = double(string(Ytrain));
Ytest_num  = double(string(Ytest));
Y_num      = double(string(Y_cat));

%% Define SVM template
template = templateSVM('KernelFunction','rbf','KernelScale','auto','Standardize',true);

%% Train weighted SVM on training set
SVMModel2 = fitcecoc(Xtrain, Ytrain, ...
    'Learners', template, ...
    'ClassNames', categorical([0 1 2]), ...
    'Coding', 'onevsone', ...
    'FitPosterior', true, ...
    'Weights', arrayfun(@(y) classWeights(y+1), Ytrain_num));

%% Evaluate on test set
Ypred = predict(SVMModel2, Xtest);
cm = confusionmat(Ytest, Ypred);
disp('Confusion Matrix:');
disp(cm);

testAcc = sum(Ypred == Ytest) / numel(Ytest) * 100;
fprintf("\n✅ Test Accuracy: %.2f %%\n", testAcc);

%% Cross-validation (with weights)
SVMModel = fitcecoc(X, Y_cat, ...
    'Learners', template, ...
    'ClassNames', categorical([0 1 2]), ...
    'Coding', 'onevsone', ...
    'FitPosterior', true, ...
    'Weights', arrayfun(@(y) classWeights(y+1), Y_num));

cvModel = crossval(SVMModel, 'KFold', 5);
cvLoss = kfoldLoss(cvModel);
cvAcc = (1 - cvLoss) * 100;
fprintf("\n✅ Cross-val Accuracy: %.2f %%\n", cvAcc);

% Confusion matrix from cross-validation
Ypred_cv = kfoldPredict(cvModel);
cm_cv = confusionmat(Y_cat, Ypred_cv);
disp('Cross-val Confusion Matrix:');
disp(cm_cv);
