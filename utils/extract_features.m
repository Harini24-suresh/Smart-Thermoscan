function featureVector = extract_features(img)
    % Resize for standardization
    img = imresize(img, [240, 320]);

    % Split image into 6 zones
    [height, width] = size(img);
    h1 = round(height / 3);
    w1 = round(width / 2);

    Z1 = img(1:h1, 1:w1);
    Z2 = img(1:h1, w1+1:end);
    Z3 = img(h1+1:2*h1, 1:w1);
    Z4 = img(h1+1:2*h1, w1+1:end);
    Z5 = img(2*h1+1:end, 1:w1);
    Z6 = img(2*h1+1:end, w1+1:end);

    % Extract features (max, mean, std per zone)
    featureVector = [ ...
        max(Z1(:)), mean(Z1(:)), std(double(Z1(:))), ...
        max(Z2(:)), mean(Z2(:)), std(double(Z2(:))), ...
        max(Z3(:)), mean(Z3(:)), std(double(Z3(:))), ...
        max(Z4(:)), mean(Z4(:)), std(double(Z4(:))), ...
        max(Z5(:)), mean(Z5(:)), std(double(Z5(:))), ...
        max(Z6(:)), mean(Z6(:)), std(double(Z6(:))) ...
    ];
end
