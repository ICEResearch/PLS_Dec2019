% clear; 
close all;
tic;

addpath('../Data/');
addpath('../RefSignalFolder/');
addpath('../Data/RawData');
addpath('../Data/RawData/matFiles');

inFileNames = ["Redd3_noTraffic.mat", "Redd3_traffic.mat", ...
    "twitchell8_notraffic.mat", "twitchell8_traffic.mat", ...
    "Cheng6_notaffic.mat", "Cheng6_traffic.mat",...
    "Harrison9_notraffic.mat", "Harrison9_highTraffic.mat"];
[~, numFiles] = size(inFileNames);

refFileNames = ["Radio3_ref.mat", ...
    "Radio8_ref.mat", ...
    "Radio6_ref.mat", ...
    "Radio9_ref.mat"];
[~, numRefFiles] = size(refFileNames);

idxEndOfData = zeros(1,numFiles);
Nfft = 128; % Number of FFT bins
numCarriers = Nfft;
numFrames = 40000; %FIXME this number is hard coded. Needs to be changed if different data is read in
dataSets = zeros(numFiles, numCarriers, numFrames);
times = NaT(numFiles, numFrames);
carriersToTrimEachSide = 16; % On EACH side, so 2*this total

for i = 1:numFiles %- cut out the two Angerbauer
    disp('Working on file ' + string(i) + ' at time ' + string(datetime));
    %     tic;
    structContainingData = load(inFileNames(i)); % Load in raw data
    % The data is loaded in as a struct, so the desired array must be
    % extracted from the 1x1 struct
    eval(sprintf('dataFromStruct = structContainingData.%s_data;', erase(inFileNames(i), ".mat")));
    eval(sprintf('timeFromStruct = structContainingData.%s_time;', erase(inFileNames(i), ".mat")));
    [x, y] = size(dataFromStruct);
    if x == 2048
        dataArray = dataFromStruct;
    else
        dataArray = dataFromStruct';
    end
    [rawData, ~] = size(dataArray);
    
    idxEndOfData(i) = find(sum(dataArray)==0,1) - 1;
    dataTrimmed = dataArray(:,1:idxEndOfData(i));
    
    % Gets the processed data showing each carrier, function inputs are the
    % raw data array and the number of fft bins for the pwelch function
    linearData = PwelchAndFFTShift(dataTrimmed, Nfft);
    
    for qq=1:length(linearData)
        savedLinearDataAfterPwelchAndFFTShift(i,:,qq) = linearData(:,qq);
    end
    
    % The pluto radios attentuate the edge carriers, RemoveAttentuatedEdges
    % sets all of those attenuated carriers to a value of 0. The function
    % inputs are the processed data (in linear or dB), whether or not the
    % noise carriers are on the odd or even numbered indexes (true for odd,
    % false for even), and whether or not the data is linear or in dB (true
    % for linear, false for dB)
    noiseOnOddCarriers = true;
    
    isolatedGoodData = RemoveAttenuatedEdgeCarriersEvenly(linearData, noiseOnOddCarriers, carriersToTrimEachSide);
    
%     if i == 1 || i == 2
%         isolatedGoodData = RemoveAttenuatedEdges(linearData, noiseOnOddCarriers, true);
%         [numCarriers, ~] = size(isolatedGoodData);
%         gc(:,i) = isolatedGoodData(:,1) > 0;
%     else
%         if sum(gc(:,1)) > sum(gc(:,2))
%             isolatedGoodData = linearData .* gc(:,2);
%         else
%             isolatedGoodData = linearData .* gc(:,1);
%         end
%     end
    goodDataAugmented = zeros(numCarriers, numFrames);
    goodDataAugmented(:,1:idxEndOfData(i)) = isolatedGoodData;
    dataSets(i,:,:) = goodDataAugmented;
    times(i,:) = timeFromStruct(1, 1:numFrames);
end
dataSets = dataSets(:,:,1:max(idxEndOfData));
[~, numCarriers, numFrames] = size(dataSets);
times = times(:,1:numFrames);
names = erase(inFileNames, ".mat");

leftCarrier = 2*carriersToTrimEachSide + 1;
rightCarrier = 128 - (2*carriersToTrimEachSide);

% % Finds the common carriers across all the data sets and frames that are
% % good and removes any inconsistent carriers so that the data may be
% % compared appropriately across all of the data sets
% minIdx = min(idxEndOfData); % Number of frames that can be compared across all data sets
% allNonZero = numFiles * minIdx;
% leftCarrier = 0;
% rightCarrier = 0;
% 
% for i = 1:numCarriers
%     if nnz(dataSets(:,i,1:minIdx)) == allNonZero
%         if leftCarrier == 0
%             leftCarrier = i;
%         end
%         rightCarrier = i;
%     end
% end
% goodCarriers = zeros(numCarriers,1);
% if mod(sum(goodCarriers(:,1)),2) ~= 0
%     goodCarriers(leftCarrier:rightCarrier,1) = 1;
%     halfwayCarrier = round(numCarriers / 2);
%     numLeftCarriers = sum(goodCarriers(1:halfwayCarrier,1));
%     numRightCarriers = sum(goodCarriers(halfwayCarrier:numCarriers,1));
%     if numLeftCarriers > numRightCarriers
%         leftCarrier = leftCarrier + 1;
%     else
%         rightCarrier = rightCarrier - 1;
%     end
% end
% 
% dataSets(:,1:leftCarrier-1,:) = 0;
% dataSets(:,rightCarrier+1:numCarriers,:) = 0;


% Plots one frame of the data showing which carriers were common across all
% the data sets allowing for visual confirmation for the user

stem(10*log10(abs(linearData(:,1))));
grid on;
hold on
maskedData = zeros(numCarriers,1);
maskedData(leftCarrier:rightCarrier,1) = linearData(leftCarrier:rightCarrier,1);
stem(10*log10(abs(maskedData)), 'MarkerFaceColor','k');
title({'Resulting Data that is Analyzed', ...
    'Plot values are in dB for visual clarity'});
hold off
drawnow;

% Scales the data so that the average noise power is equal to 1
scaledData = zeros(numFiles,numCarriers,numFrames);
for i = 1:numFiles
    scaledData(i,:,1:idxEndOfData(i)) = ...
        ScaleAvgNoiseToOne(squeeze(dataSets(i,:,1:idxEndOfData(i))), noiseOnOddCarriers);
end

% Loads in the Reference Signal data, processes it, and isolates the same
% carriers found in the measured data
for i = 1:numRefFiles
    structContainingData = load(refFileNames(i)); % Load in raw data
    % The data is loaded in as a struct, so the desired array must be
    % extracted from the 1x1 struct
    dataArray = struct2array(structContainingData);
   
    Nfft = 128; % Number of FFT bins
    % Gets the processed data showing each carrier, function inputs are the
    % raw data array and the number of fft bins for the pwelch function
    linearData = PwelchAndFFTShift(dataArray, Nfft);
    [x, y] = size(linearData);
    
    % Restricts the carriers that we care about to match the carriers from
    % the data sets
    isolatedGoodData = zeros(x,y);
    isolatedGoodData(leftCarrier:rightCarrier,:) = linearData(leftCarrier:rightCarrier,:);
    refData(i,:,:) = isolatedGoodData;
end

% Scales the reference signal so that the sum of the signal carriers is
% equal to 1
scaledRefData = ScaleRefSignalToSumToOne(refData, noiseOnOddCarriers);

% In the frequency domain, divides the signal carriers for each data set by
% the reference carriers for the radio used in that data set
signalCarriers = zeros(numFiles,numCarriers,numFrames);
refSignalCarriers = zeros(numRefFiles,numCarriers);
signalCarriers(:,2:2:numCarriers,:) = scaledData(:,2:2:numCarriers,:);
refSignalCarriers(:,2:2:numCarriers) = scaledRefData(:,2:2:numCarriers);
for i = 1:numRefFiles
    b = 2 * i;
    a = b - 1;
    for j = 1:numFrames
        removedRefSignal(a,:,j) = signalCarriers(a,:,j) ./ refSignalCarriers(i,:);
        removedRefSignal(b,:,j) = signalCarriers(b,:,j) ./ refSignalCarriers(i,:);
    end
end

% Normalize each carrier by dividing by the max carrier overall
maxCarrierVal = max(max(max(removedRefSignal(:,:,:))));

processedData = zeros(numFiles,numCarriers,numFrames);
processedData(:,:,:) = removedRefSignal(:,:,:) ./ maxCarrierVal;
% All locations that are marked with a 0 became a NaN because in the above
% code 0/0 results in NaN. So we must now set each NaN back to 0
processedData(isnan(processedData)) = 0;

% Many of the carrier indices of the 128 now contain only zeros for every
% frame, so removing those isolates the signal carriers that we actually
% care about
data = processedData(:,any(processedData,1:2:3),:); % Removes unnecessary carriers

% Save the appropriate variables into a .mat file to be used elsewhere
save ../DataAnalysis/ProcessedResultsJul2020Phantom.mat data times names idxEndOfData;
toc;


%% Desired Process for the Code

% Pwelch and FFTShift everything

% Scale the data so that the avg noise power is 1
%%% Verify that the signal to noise difference is equal for before and
%%% after scaling in dB

% Normalize the reference signal by scaling the height of all of the
% carriers to sum to 1

% In frequency domain: divide the signal carriers by the reference carriers

% Repeat 1-4 for each frame

% Repeat 1-5 for each channel

% Normalize all the channels by the strongest carrier of all of the
% channels
