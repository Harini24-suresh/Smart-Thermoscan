% main_analysis.m
clc; clear; close all;

%% Step 1: Locate Diagnostics file
basePath = "C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\";
csvFile  = fullfile(basePath,"csv\Diagnostics.csv");

if isfile(csvFile)
    fprintf("Loading Diagnostics.csv ✅\n");
    metadata = readtable(csvFile,'VariableNamingRule','preserve');
else
    error("Diagnostics.csv not found in %s", csvFile);
end

% Show actual headers
disp("Detected column headers:");
disp(metadata.Properties.VariableNames);

%% Step 2: Select patient ID
patientID = "IIR0053";   % <-- change as needed
row = metadata(strcmp(metadata.("Image"), patientID), :);

if isempty(row)
    error("Patient ID %s not found in Diagnostics file.", patientID);
end

% Extract metadata values
weight = row.("Weight (Kg)");
height = row.("Height(cm)");
temp   = row.("Temp(¡C)");
age    = row.("Age(years)");
leftLabel  = row.("Left"){1};
rightLabel = row.("Right"){1};

fprintf("Loaded patient %s (Age: %d, Temp: %.1f)\n", patientID, age, temp);

%% Step 3: Decide scan type
if ~isempty(leftLabel) && strcmpi(leftLabel,"Abnormal")
    scanType = "left";
elseif ~isempty(rightLabel) && strcmpi(rightLabel,"Abnormal")
    scanType = "right";
else
    scanType = "anterior"; % fallback
end
fprintf("Selected scan type: %s\n", scanType);

%% Step 4: Image file path
imgFolder = fullfile(basePath,"data","raw_images",patientID);
imgPattern = fullfile(imgFolder, sprintf("%s*%s*", patientID, scanType));
fileList = dir(imgPattern);

if isempty(fileList)
    warning("No %s scan found. Trying any scan...", scanType);
    fileList = dir(fullfile(imgFolder, sprintf("%s*", patientID)));
end

if isempty(fileList)
    error("No image found for patient %s in %s", patientID, imgFolder);
else
    imgFile = fullfile(fileList(1).folder, fileList(1).name);
    fprintf("Using image file: %s\n", imgFile);
end

%% Step 5: Preprocess image
img = imread(imgFile);
if size(img,3) == 3
    img = rgb2gray(img);
end
img = imresize(img, [240, 320]);

figure;
imshow(img);
title(sprintf("Thermal Image - %s (%s)", patientID, scanType));

%% Step 6: Extract features
zoneFeatures = extract_features(img);

%% Step 7: Classify biopsy urgency
urgency = biopsy_urgency(zoneFeatures, temp, age, weight, height);

fprintf("Biopsy urgency for %s: %s\n", patientID, urgency);
