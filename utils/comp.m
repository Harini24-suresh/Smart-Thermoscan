ModelNames = {'SVM','Random Forest','Improved CNN','XGBoost','Weighted Ensemble'};
TestAccs  = [acc_SVM, acc_RF, acc_CNN, acc_XGB, ensembleAcc];

T = table(ModelNames', TestAccs', 'VariableNames', {'Model','TestAccuracy'});
disp('================== Model Comparison Summary ==================');
disp(T);
figure('Color','w');
bar(TestAccs, 0.5, 'FaceColor',[0.2 0.6 0.8]);
set(gca, 'XTickLabel', ModelNames, 'FontSize',12);
ylabel('Test Accuracy (%)', 'FontSize', 14);
ylim([0 100]);
title('Comparison of Model Test Accuracies', 'FontSize', 16);
grid on;

% Add accuracy values on top of bars
for i = 1:length(TestAccs)
    text(i, TestAccs(i)+1, sprintf('%.2f%%', TestAccs(i)), ...
        'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
end
