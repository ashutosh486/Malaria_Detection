function varargout = malaria_gui(varargin)
% MALARIA_GUI MATLAB code for malaria_gui.fig
%      MALARIA_GUI, by itself, creates a new MALARIA_GUI or raises the existing
%      singleton*.
%
%      H = MALARIA_GUI returns the handle to a new MALARIA_GUI or the handle to
%      the existing singleton*.
%
%      MALARIA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MALARIA_GUI.M with the given input arguments.
%
%      MALARIA_GUI('Property','Value',...) creates a new MALARIA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before malaria_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to malaria_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help malaria_gui

% Last Modified by GUIDE v2.5 17-May-2018 03:30:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @malaria_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @malaria_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before malaria_gui is made visible.
function malaria_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to malaria_gui (see VARARGIN)

% Choose default command line output for malaria_gui
handles.output = hObject;


axes(handles.axes4);
imshow('red.jpg');
axes(handles.axes3);
imshow('logo.jpg');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes malaria_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = malaria_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loaddata.
function loaddata_Callback(hObject, eventdata, handles)

here = genpath('.');
addpath(here);
[file,path] = uigetfile('*.jpg','Select Blood Sample Image File');  %% uigetfile displays a dialog box used to retrieve one or more files. The dialog box lists the files and directories in the current directory.
image_file = fullfile(path,file);                                                %% fullfile(dir1, dir2, ..., filename) builds a full filename from the directories and filename specified.

im = imread(image_file);
figure;
imshow(im);
title('Original Image');
handles.im=im;
guidata(hObject, handles);

% --- Executes on button press in imageenhance.
function imageenhance_Callback(hObject, eventdata, handles)
% hObject    handle to imageenhance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% convert to grayscale and do Histogram Equalization
im=handles.im;
gray = rgb2gray(im);

figure;
subplot(2,1,1);
imshow(gray);
title('GrayScale Image');

%% Image enhancement

Enhanced_gray = imadjust(gray);

subplot(2,1,2);
imshow(Enhanced_gray);
title('Enhanced Image After Histogram Equalization');
handles.Enhanced_gray=Enhanced_gray;
guidata(hObject, handles);



% --- Executes on button press in segment.
function segment_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Image Segmentation
Enhanced_gray=handles.Enhanced_gray;
BW = edge(Enhanced_gray,'Canny',0.5);

figure;
% subplot(3,3,4);
imshow(BW);
title('Detected Edges');
handles.BW=BW;
guidata(hObject, handles);


% --- Executes on button press in morph.
function morph_Callback(hObject, eventdata, handles)
% hObject    handle to morph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Morphological Operations
BW=handles.BW;

se = strel('square',3);
BW2 = imdilate(BW,se);

figure;
% subplot(3,3,5);
imshow(BW2);
title('Dilated Image');



BW3 = imfill(BW2,'holes');

L = bwlabel(BW3);
S = regionprops(L,'BoundingBox');

figure;
% subplot(3,3,6);
imshow(~BW3);
hold on;

for nn = 1:length(S)
    
    rectangle('Position',S(nn).BoundingBox,'EdgeColor','r');
    
end

mytitle = strcat('Holes Filling and Detected RBCs:',num2str(length(S)));
title(mytitle);


% --- Executes on button press in rbcext.
function rbcext_Callback(hObject, eventdata, handles)
% hObject    handle to rbcext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%% %%%%%%%%%  RBC Extraction  %%%%%%%%%%%% %%

im=handles.im;
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
th = graythresh(new_gray_image);    %%
new_bw_image = im2bw(new_gray_image,th);    %%

figure;
% subplot(3,3,8);
imshow(new_bw_image);
title('RBC Detection B n W');
handles.new_bw_image=new_bw_image;
guidata(hObject, handles);
handles.total_rows=total_rows;
guidata(hObject, handles);
handles.total_columns=total_columns;
guidata(hObject, handles);
handles.old_color_image=old_color_image;
guidata(hObject, handles);


function plasmodium_Callback(hObject, eventdata, handles)
%% Malarial Parasite Detection

new_bw_image=handles.new_bw_image;
total_rows=handles.total_rows;
total_columns=handles.total_columns;
old_color_image=handles.old_color_image;
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


% --- Executes on button press in plasmodium.

% hObject    handle to plasmodium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Malaria Cells Segmentation

gg = rgb2gray(new_color_image_malarial);
%gth = graythresh(gg);
BW = im2bw(gg);
BW2 = bwareaopen(BW,100);

% figure;
% imshow(BW2);

BW2 = ~BW2;
% figure;
% imshow(BW2);

BW3= imfill(BW2,'holes');

se = strel('disk',1);
BW4 = imdilate(BW3,se);
BW5 = bwareaopen(BW4,100);
% 
% figure;
% imshow(BW5);

BW6= imfill(BW5,'holes');
% figure;
% imshow(BW6);

Iprops = regionprops(BW6,'BoundingBox');


for jj = 1:length(Iprops)
   
    rectangle('Position',Iprops(jj).BoundingBox,'EdgeColor','r','LineWidth',2);
    
end
