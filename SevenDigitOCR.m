%% Step 1: Set Input/Output Paths
inputFolder = uigetdir('', 'Select folder containing images'); % Interactive folder selection
outputFile = 'SevenSegmentReadings3.xlsx'; % Output filename

%% Step 2: Get List of Images (FIXED)
supportedFormats = {'*.jpg';'*.jpeg';'*.png';'*.bmp';'*.tif'}; % Cell array of formats
fileList = [];
for k = 1:length(supportedFormats)
    fileList = [fileList; dir(fullfile(inputFolder, supportedFormats{k}))];
end
numImages = length(fileList);

%% Step 3: Initialize Results Table
results = table('Size',[numImages 2],...
    'VariableTypes',{'string','string'},...
    'VariableNames',{'Filename','Reading'});

%% Step 4:Bounding conditions from user input
prompt1 = "Enter minimum reading:";
prompt2 = "Enter maximum reading:";
prompt3 = "test";
minRead = 400;
maxRead = 3000;


%% Step 4: Process All Images
for i = 1:numImages
    % Read image
    imgPath = fullfile(inputFolder, fileList(i).name);
    oldImg = imread(imgPath);

    %Image Preprocessing
    img = imtophat(oldImg,strel("disk",15));
    BW1 = imbinarize(img);
    BW2 = imcomplement(BW1);
       
    % Use regionprops to find bounding boxes around text regions and measure their area.
    cc = bwconncomp(BW1);
    stats = regionprops(cc, ["BoundingBox","Area"]);
   
    % Extract bounding boxes and area from the output statistics.
    roi = vertcat(stats(:).BoundingBox);
    area = vertcat(stats(:).Area);

 
    % Define area constraint based on the area of smallest character of interest.
    minArea = 50;
    maxArea = 400;
    areaConstraint = (area>minArea)&(area<maxArea);
    
    % Keep regions that meet the area constraint.
    roi = double(roi(areaConstraint,:));

    % Get all corners of ROIs
    x1 = roi(:,1);
    y1 = roi(:,2);
    x2 = x1 + roi(:,3); % x + width
    y2 = y1 + roi(:,4); % y + height
    
    % Find min/max coordinates to enclose all ROIs
    newX = min(x1);
    newY = min(y1);
    newWidth = max(x2) - newX;
    newHeight = max(y2) - newY;
    spacing = 5;
    
    combinedROI = [newX-spacing, newY-spacing, newWidth+spacing, newHeight+spacing];

    croppedImg = imcrop(BW2, combinedROI);
    ocrResult = ocr(croppedImg, Model='seven-segment', LayoutAnalysis="word",CharacterSet="0123456789");

    text = deblank({ocrResult.Text});

    %{
    croppedImg_uint8 = im2uint8(croppedImg);
    imgAnnot  = insertObjectAnnotation(croppedImg_uint8,"rectangle",combinedROI,text);
    imglist = {oldImg,BW2,croppedImg_uint8};
    figure
    montage(imglist);
    continue
    %}

    if ~isempty(text)
        % check Bounding condition
        if (str2double(text)<minRead) || (str2double(text)>maxRead)
            results.Filename(i) = fileList(i).name;
            results.Reading(i) = "Incorrect Reading";
            figure
            montage({oldImg;croppedImg});
            title("Input Image | Detected Text Regions");
        else
            results.Filename(i) = fileList(i).name;
            results.Reading(i) = text;
        end
    else
        results.Filename(i) = fileList(i).name;
        results.Reading(i) = "No digits detected";
        figure
        montage({oldImg;croppedImg});
        title("Input Image | Detected Text Regions");
    end
end

%% Step 5: Export to Excel
writetable(results, outputFile);
fprintf('Results saved to %s\n', outputFile);