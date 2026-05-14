% STEP 5: Generate Heatmap for entire image
figure;
imshow(img, []);
colormap hot;
colorbar;
title('Thermal Heatmap Overlay');

% STEP 6: Overlay heatmap on original image
figure;
imshow(img); hold on;
hMap = imagesc(img);  % overlay heat intensity
colormap hot;
alpha(hMap, 0.4);     % transparency for overlay
colorbar;
title('Overlayed Thermal Heatmap');

zones = {Z1,Z2,Z3,Z4,Z5,Z6};
zoneNames = {'Upper Left','Upper Right','Middle Left','Middle Right','Lower Left','Lower Right'};
zoneMeans = zeros(1,6);

for i = 1:6
    zoneMeans(i) = mean(zones{i}(:));
end

[~, hotIdx] = max(zoneMeans);
fprintf("🔥 Hottest Zone: %s (Mean Intensity = %.2f)\n", zoneNames{hotIdx}, zoneMeans(hotIdx));

% Normalize image
imgNorm = mat2gray(img);
heatRGB = ind2rgb(gray2ind(imgNorm, 256), hot(256));

% Overlay with transparency
figure;
imshow(img); hold on;
hOverlay = imshow(heatRGB);
alpha(hOverlay, 0.5);  % adjust transparency
title('Enhanced Thermal Overlay (Smart Heatmap)');

