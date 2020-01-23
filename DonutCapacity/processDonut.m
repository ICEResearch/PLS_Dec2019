clear; close all; clc;


%%%%%%%%%% USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath DonutRawDataNew
dataNames = ["Jensen1_noamp_data.mat","Norman12_noamp_data.mat", ...
             "Redd11_noamp_data.mat", "Angerbauer3_noamp_data.mat"];
timeNames = ["Jensen1_noamp_time.mat","Norman12_noamp_time.mat", ...
             "Redd11_noamp_time.mat", "Angerbauer3_noamp_time.mat"];
saveNames = ["Jensen1_noamp_processed.mat", "Norman12_noamp_processed.mat", ...
             "Redd11_noamp_processed.mat", "Angerbauer3_noamp_processed.mat"];
save = 0;          % If you want it to save the files
startCarrier = 20; % Somewhat arbitrarily chosen -> Should be a signal carrier (not noise)
endCarrier = 106;
timeStepSize = 0.25;  % Average data over every (quarter) second
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numCarriers = 1 + (endCarrier - startCarrier)/2;
numFiles = length(dataNames);   % Should be four


for file = 1:numFiles
    
    %%% Load in Data 
    fileName_data = string(dataNames(file));
    fileName_time = string(timeNames(file));
    eval(sprintf("load('%s');", fileName_data));
    eval(sprintf("load('%s');", fileName_time));
    fileName_data = extractBetween(fileName_data, 1, strlength(fileName_data) - 4); % Trim off the ".mat"
    fileName_time = extractBetween(fileName_time, 1, strlength(fileName_time) - 4);
    eval(sprintf("tempData = %s;", fileName_data ));
    eval(sprintf("tempTime = %s;", fileName_time ));
    
    
    %%% Trim off trailing zeros 
    if (tempData(end) == 0) % If there is a trailing zero
        endOfData = max(find(tempData(:,1) ~= 0)); % Find last datapoint
        trimmedData = tempData(1:endOfData,:);     % Trim off trailing zeros
        trimmedTime = tempTime(1:endOfData);
    else 
        trimmedData = tempData;
        trimmedTime = tempTime;
    end
    
    %%% Process Data (Pwelch, fftShift, noise floor)
    processedData = zeros(endOfData, numCarriers); % Only keeping middle signal carriers
    Nfft = 128;
    for index = 1:endOfData
        pwelchedData = pwelch(trimmedData(index,:), boxcar(Nfft), 0, Nfft, 'twosided');
        fftshiftedData = fftshift(pwelchedData);
            % Average the noise floor over the middle carriers
        averageNoiseFloor = mean(fftshiftedData( (startCarrier+1):2:(endCarrier+1))); 
        processedData(index,:) = fftshiftedData( startCarrier:2:endCarrier) / averageNoiseFloor; % Divide out noise floor        
    end
    
    
    %%% 20 Log 10 because we want power...?
    processedData = 10*log10(processedData);   
    
    %%% Average over time periods
    refTime = trimmedTime(1);     % Use first timestamp as the initial reference
    timeBin = 1;                  % Index for storing data
    count = 0;
    temp = zeros(1, numCarriers);
    timeDif = max(trimmedTime) - min(trimmedTime);
    numOfBins = ceil(seconds(timeDif) / timeStepSize);
    
    averagedData = zeros(numOfBins, numCarriers);
    
    for index = 1:endOfData
        if (trimmedTime(index) < (refTime + seconds(timeStepSize)))
            count = count + 1;
            temp = temp + processedData(index,:);
        else
            refTime = refTime + seconds(timeStepSize);
            averagedData(timeBin,:) = temp / count;
            timeBin = timeBin + 1;
            count = 0;
            temp = zeros(1, numCarriers);
        end        
    end
    
    tempArray = zeros(numOfBins, 1);
    sum = 0;
    averagedData = averagedData / max(max(averagedData));
    
    %%% Calculate Capacity and Assign Values to Locations
    for index = 1:numOfBins
        for carrier = 1:numCarriers
            sum = sum + 0.5 * log2(1 + averagedData(index,carrier));
        end
        tempArray(index) = sum;
        sum = 0;
        % tempArray(index) = mean(averagedData(index,:));
    end
    eval(sprintf("%s = tempArray;",string(fileName_data)));
    disp('Finishing file at ' + string(datetime));
    if save
        save(saveNames(file), fileName_data);
    end
end


%% Trim Files to same size 

lengths = zeros(1, numFiles);

for file = 1:numFiles
    fileName_data = string(dataNames(file));
    fileName_data = extractBetween(fileName_data, 1, strlength(fileName_data) - 4); % Trim off the ".mat"
    eval(sprintf("lengths(1,%d) = length(%s);", file, fileName_data)); 
end

minDim = min(lengths);

for file = 1:numFiles
    fileName_data = string(dataNames(file));
    fileName_data = extractBetween(fileName_data, 1, strlength(fileName_data) - 4); % Trim off the ".mat"
    eval(sprintf("data%d = %s(1:minDim,1);", file, fileName_data));
end

% Norman12_noamp_data = Norman12_noamp_data(1:350,1);
% Jensen1_noamp_data = Jensen1_noamp_data(1:350,1);
% Redd11_noamp_data = Redd11_noamp_data(1:350,1);
% Angerbauer3_noamp_data = Angerbauer3_noamp_data(1:350,1);

tempAvg = (data1 + data2 + data3 + data4) / 4;

% tempAvg = (Norman12_noamp_data + Jensen1_noamp_data + Redd11_noamp_data + Angerbauer3_noamp_data ) /4;
averagedArray = zeros(375, 1);

for index = 1:(350-1)
    averagedArray(index+23) = tempAvg(index);
end

finalArray_avg = zeros(527, 527);

for x = 1:527
    for y = 1:527
        distance = round( sqrt( (x-263)^2 + (y-263)^2 ));
        if (distance <= 263 && distance ~= 0)
            finalArray_avg(x,y) = averagedArray(distance);
        else
            finalArray_avg(x,y) = nan;
        end
    end
end

%%
figure()
imagesc(finalArray_avg);
colorbar

figure()
surf(finalArray_avg);

figure()
plot(averagedArray);
         