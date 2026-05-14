function auto_label_existing(inCSV, outCSV)
% AUTO_LABEL_EXISTING - Recompute biopsy labels and risk scores
% from an existing feature dataset (like dataset_auto.csv)
%
% Example:
% auto_label_existing("C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\utils\dataset_auto.csv", ...
%                     "C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\utils\dataset_relabelled.csv")

%% --- Read dataset
fprintf('Reading feature dataset from: %s\n', inCSV);
T = readtable(inCSV, 'VariableNamingRule','preserve');
vars = T.Properties.VariableNames;
disp('Detected columns:');
disp(vars);

n = height(T);
labels = strings(n,1);
riskScores = zeros(n,1);

%% --- Recompute risk & label
for i = 1:n
    age = safeNum(T.Age(i));
    temp = safeNumIfExists(T, 'Temp__C_');
    if isnan(temp) && ismember('Temp', T.Properties.VariableNames)
        temp = safeNum(T.Temp(i));
    end
    if isnan(temp), temp = 36.5; end
    if isnan(age), age = 35; end

    % Feature extraction from row
    feats = table2array(T(i,1:18));

    % Compute zone max
    zoneMaxes = feats(1:3:end);
    maxZone = max(zoneMaxes);

    % Approximate asymmetry
    leftMean  = mean(feats([2,5,8,11,14,17]));
    rightMean = mean(feats([5,8,11,14,17,2]));
    asymmetry = abs(leftMean - rightMean);

    % Normalized factors
    asymNorm = min(1, asymmetry/30);
    maxNorm  = min(1, max(0,(maxZone - 100)/150));
    tempNorm = min(1, max(0,(temp - 36)/3));
    ageNorm  = min(1, max(0,(age - 30)/30));

    % Risk score (0–100)
    risk = (0.35*asymNorm + 0.35*maxNorm + 0.2*tempNorm + 0.1*ageNorm) * 100;
    riskScores(i) = risk;

    % Assign label
    if (maxZone >= 240) || (age >= 45 && temp >= 37.5)
        label = "High";
    elseif risk >= 70
        label = "High";
    elseif risk >= 40
        label = "Medium";
    else
        label = "Low";
    end
    labels(i) = label;
end

%% --- Update and save
T.Label = categorical(labels);
T.RiskScore = riskScores;
writetable(T, outCSV);

fprintf('\n✅ Saved relabelled dataset: %s\n', outCSV);
end

%% --- Helper functions
function val = safeNum(v)
if iscell(v), v = v{1}; end
val = double(v);
if isnan(val)
    try val = str2double(v); catch; val = NaN; end
end
end

function val = safeNumIfExists(T, col)
if ismember(col, T.Properties.VariableNames)
    val = safeNum(T.(col)(1));
else
    val = NaN;
end
end
