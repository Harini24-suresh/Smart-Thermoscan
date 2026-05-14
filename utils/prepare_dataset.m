clc; clear; close all;

%% ------------------------------
%  Paths
% -------------------------------
csvFile  = "C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\csv\Diagnostics.csv";
baseDir  = "C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\data\raw_images";

%% ------------------------------
%  Load metadata
% -------------------------------
metadata = readtable(csvFile);
fprintf("✅ Loaded metadata with %d patients\n", height(metadata));

%% ------------------------------
%  Prepare dataset
% -------------------------------
X = [];
Y = [];

for i = 1:height(metadata)
    patientID = string(metadata.Image(i));   % e.g. "IIR0001"
    patientFolder = fullfile(baseDir, patientID);

    if ~isfolder(patientFolder)
        warning("⚠️ Folder not found for patient %s", patientID);
        continue;
    end

    % Expected images
    imgFiles = {
        fullfile(patientFolder, patientID + "_anterior.jpg")
        fullfile(patientFolder, patientID + "_oblleft.jpg")
        fullfile(patientFolder, patientID + "_oblright.jpg")
    };

    featPatient = [];
    for j = 1:numel(imgFiles)
        if isfile(imgFiles{j})
            img = imread(imgFiles{j});
            img = imresize(img, [240, 320]);

            if size(img,3) == 3
                img = rgb2gray(img);
            end

            % Extract normalized histogram features
            feat = imhist(img, 64);
            feat = feat / sum(feat);

            featPatient = [featPatient; feat(:)];
        else
            warning("⚠️ Missing image: %s", imgFiles{j});
        end
    end

    if isempty(featPatient)
        continue;
    end

    % Diagnosis label (using LEFT side only for now)
    labelStr = string(metadata.Left(i));
    switch labelStr
        case "N"
            label = 0;   % Normal
        case "PB"
            label = 1;   % Benign
        case "PM"
            label = 2;   % Malignant
        otherwise
            label = NaN;
    end

    if ~isnan(label)
        X(end+1,:) = featPatient(:)'; %#ok<AGROW>
        Y(end+1,1) = label;           %#ok<AGROW>
    end
end

fprintf("✅ Features prepared → %d samples, %d features\n", size(X,1), size(X,2));

%% ------------------------------
%  Save dataset
% -------------------------------
save("dataset.mat", "X", "Y");
fprintf("💾 Dataset saved as dataset.mat\n");

%% ------------------------------
%  Quick check
% -------------------------------
tabulate(Y)
