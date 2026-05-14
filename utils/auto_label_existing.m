% STEP 1: Read image
img = imread("C:\Users\Harini\OneDrive\Desktop\Smart Thermoscan\data\raw_images\IIR0053\IIR0053_anterior.jpg");
if ndims(img) == 3
    img = rgb2gray(img);
end
img = imresize(img, [240, 320]);  % standard size

% STEP 2: Define dimensions
[h, w] = size(img);
h1 = round(h / 3);  % height split into 3
w1 = round(w / 2);  % width split into 2

% STEP 3: Define 6 zones
Z1 = img(1:h1, 1:w1);        % Upper Left
Z2 = img(1:h1, w1+1:end);    % Upper Right
Z3 = img(h1+1:2*h1, 1:w1);   % Middle Left
Z4 = img(h1+1:2*h1, w1+1:end); % Middle Right
Z5 = img(2*h1+1:end, 1:w1);  % Lower Left
Z6 = img(2*h1+1:end, w1+1:end); % Lower Right

% STEP 4: Display zones
figure;
subplot(2,3,1), imshow(Z1), title('Upper Left (Z1)');
subplot(2,3,2), imshow(Z2), title('Upper Right (Z2)');
subplot(2,3,3), imshow(Z3), title('Middle Left (Z3)');
subplot(2,3,4), imshow(Z4), title('Middle Right (Z4)');
subplot(2,3,5), imshow(Z5), title('Lower Left (Z5)');
subplot(2,3,6), imshow(Z6), title('Lower Right (Z6)');
