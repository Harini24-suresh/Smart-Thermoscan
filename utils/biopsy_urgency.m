function urgency = biopsy_urgency(features, temp, age, weight, height)
    % Ensure numeric type
    features = double(features);

    % Calculate BMI
    height_m = double(height) / 100;
    BMI = double(weight) / (height_m^2);

    % Initialize
    riskScore = 0;
    reasons = {};

    % Imaging features
    if max(features) > 200
        riskScore = riskScore + 2;
        reasons{end+1} = sprintf("High max intensity (%.1f > 200)", max(features));
    end
    if mean(features) > 100
        riskScore = riskScore + 1;
        reasons{end+1} = sprintf("High mean intensity (%.1f > 100)", mean(features));
    end
    if std(features) > 50
        riskScore = riskScore + 1;
        reasons{end+1} = sprintf("High variance in features (std %.1f > 50)", std(features));
    end

    % Age factor
    if age > 50
        riskScore = riskScore + 1;
        reasons{end+1} = sprintf("Older age (%.0f > 50)", age);
    end

    % Temp anomaly
    if temp > 37.5
        riskScore = riskScore + 2;
        reasons{end+1} = sprintf("High temperature (%.1f°C > 37.5°C)", temp);
    end

    % BMI factor
    if BMI > 30
        riskScore = riskScore + 1;
        reasons{end+1} = sprintf("High BMI (%.1f > 30)", BMI);
    end

    % Final decision
    if riskScore <= 2
        urgency = "Low";
    elseif riskScore <= 4
        urgency = "Medium";
    else
        urgency = "High";
    end

    % Print explanation
    fprintf("Biopsy urgency decision: %s (Risk Score = %d)\n", urgency, riskScore);
    if ~isempty(reasons)
        fprintf("Contributing factors:\n");
        for i = 1:numel(reasons)
            fprintf(" - %s\n", reasons{i});
        end
    else
        fprintf("No major risk factors detected.\n");
    end
end
