clc;
clear;
close all;
warning off all;

here = genpath('.');
addpath(here);
[file,path] = uigetfile('*.jpg','Select Blood Sample Image File');  %% uigetfile displays a dialog box used to retrieve one or more files. The dialog box lists the files and directories in the current directory.
image_file = fullfile(path,file);                                                %% fullfile(dir1, dir2, ..., filename) builds a full filename from the directories and filename specified.
im = imread(image_file);
figure;
subplot(3,3,1);
imshow(im);
title('Original Image');

%% convert to grayscale and do Histogram Equalization

gray = rgb2gray(im);


 subplot(3,3,2);
imshow(gray);
title('GrayScale Image');

%% Image enhancement

Enhanced_gray = imadjust(gray);


subplot(3,3,3);
imshow(Enhanced_gray);
title('Enhanced Image After Histogram Equalization');

%% Image Segmentation

BW = edge(Enhanced_gray,'Canny',0.5);

figure;
% subplot(3,3,4);
imshow(BW);
title('Detected Edges');


%% Morphological Operations

se = strel('square',3);
BW2 = imdilate(BW,se);

figure;
% subplot(3,3,5);
imshow(BW2);
title('Holes Filled');



BW3 = imfill(BW2,'holes');
% BW3 = ~BW3;

L = bwlabel(BW3);
S = regionprops(L,'BoundingBox');

figure;
% subplot(3,3,6);
imshow(~BW3);
hold on;

for nn = 1:length(S)
    
    rectangle('Position',S(nn).BoundingBox,'EdgeColor','r');
    
end

mytitle = strcat('Detected RBCs:',num2str(length(S)));
title(mytitle);


%% %%%%%%%%%  RBC Extraction  %%%%%%%%%%%% %%


total_rows = size(im,1);
total_columns = size(im,2);

old_color_image = im;

new_color_image = uint8(zeros(total_rows,total_columns,3));

for rows = 1:total_rows
    for columns = 1:total_columns
        
        if (old_color_image(rows,columns,1) <= 255 && old_color_image(rows,columns,1) >= 170 )
            new_color_image(rows,columns,1) = old_color_image(rows,columns,1);
        else
            new_color_image(rows,columns,1) = 255;
        end
        
        if (old_color_image(rows,columns,2) <= 201 && old_color_image(rows,columns,1) >= 150 )
            new_color_image(rows,columns,2) = old_color_image(rows,columns,1);
        else
            new_color_image(rows,columns,2) = 255;
        end
        
        if (old_color_image(rows,columns,3) <= 220 && old_color_image(rows,columns,1) >= 160 )
            new_color_image(rows,columns,3) = old_color_image(rows,columns,1);
        else
            new_color_image(rows,columns,3) = 255;
        end
        
    end
end

figure;
% subplot(3,3,7);
imshow(new_color_image);
title('RBC Detection');

%% RBC Counting

new_gray_image = rgb2gray(new_color_image);
th = graythresh(new_gray_image);
new_bw_image = im2bw(new_gray_image,th);

figure;
% subplot(3,3,8);
imshow(new_bw_image);
title('RBC Detection B n W');

%% Malarial Parasite Detection


new_color_image_malarial = uint8(zeros(total_rows,total_columns,3));

for rows = 1:total_rows
    for columns = 1:total_columns
        
        if (old_color_image(rows,columns,1) <= 202 && old_color_image(rows,columns,1) >= 127 )
            new_color_image_malarial(rows,columns,1) = old_color_image(rows,columns,1);
        else
            new_color_image_malarial(rows,columns,1) = 255;
        end
        
        if (old_color_image(rows,columns,2) <= 131 && old_color_image(rows,columns,2) >= 35 )
            new_color_image_malarial(rows,columns,2) = old_color_image(rows,columns,2);
        else
            new_color_image_malarial(rows,columns,2) = 255;
        end
        
        if (old_color_image(rows,columns,3) <= 211 && old_color_image(rows,columns,3) >= 143 )
            new_color_image_malarial(rows,columns,3) = old_color_image(rows,columns,3);
        else
            new_color_image_malarial(rows,columns,3) = 255;
        end
        
    end
end

figure;
% subplot(3,3,9);
imshow(new_color_image_malarial);
title('Malaria Cells Detection');
hold on;

%% Malaria Cells Segmentation
% uncomment to show intermediate results

gg = rgb2gray(new_color_image_malarial);
gth = graythresh(gg);
BW = im2bw(gg);
BW2 = bwareaopen(BW,100);

% figure;
% imshow(BW2);

BW2 = ~BW2;
% figure;
% imshow(BW2);

BW3= imfill(BW2,'holes');

se = strel('disk',1);
% erodedBW = imerode(BW3,se);
BW4 = imdilate(BW3,se);
BW5 = bwareaopen(BW4,100);
% 
% figure;
% imshow(BW5);

BW6= imfill(BW5,'holes');
% figure;
% imshow(BW6);

Iprops = regionprops(BW6,'BoundingBox');

% disp(Iprops);

for jj = 1:length(Iprops)
   
    rectangle('Position',Iprops(jj).BoundingBox,'EdgeColor','r','LineWidth',2);
    
end

