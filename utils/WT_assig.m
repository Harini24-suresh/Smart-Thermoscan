clc
clear
close all

%% 1. Load Dataset
data = readtable('parkinsons.data');

% Remove the name column (not useful for ML)
data.name = [];

%% 2. Separate Features and Target
X = data{:,1:end-1};   % Input features
Y = data.status;       % Output label (0 = Healthy, 1 = Parkinson's)

%% 3. Train-Test Split
cv = cvpartition(Y,'HoldOut',0.2);

Xtrain = X(training(cv),:);
Ytrain = Y(training(cv));

Xtest = X(test(cv),:);
Ytest = Y(test(cv));

%% 4. KNN Model
knnModel = fitcknn(Xtrain,Ytrain,'NumNeighbors',5);
pred_knn = predict(knnModel,Xtest);
acc_knn = sum(pred_knn==Ytest)/length(Ytest);

%% 5. SVM Model
svmModel = fitcsvm(Xtrain,Ytrain);
pred_svm = predict(svmModel,Xtest);
acc_svm = sum(pred_svm==Ytest)/length(Ytest);

%% 6. Decision Tree
treeModel = fitctree(Xtrain,Ytrain);
pred_tree = predict(treeModel,Xtest);
acc_tree = sum(pred_tree==Ytest)/length(Ytest);

%% 7. Random Forest (Ensemble Learning)
rfModel = fitcensemble(Xtrain,Ytrain);
pred_rf = predict(rfModel,Xtest);
acc_rf = sum(pred_rf==Ytest)/length(Ytest);

%% 8. Display Accuracy Comparison
models = {'KNN';'SVM';'Decision Tree';'Random Forest'};
accuracy = [acc_knn;acc_svm;acc_tree;acc_rf];

result_table = table(models,accuracy)
disp(result_table)

%% 9. Plot Comparison Graph
figure
bar(accuracy)
set(gca,'XTickLabel',models)
ylabel('Accuracy')
title('Machine Learning Model Comparison for Parkinsons Detection')
grid on

%% 10. Confusion Matrix for Best Model (Random Forest)
figure
confusionchart(Ytest,pred_rf)
title('Confusion Matrix - Random Forest')