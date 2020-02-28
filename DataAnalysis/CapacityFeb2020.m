% Made by Kalin Norman
% This file is designed to be run with the processed data that was a result
% of the data collection performed in the MARB at BYU in February of 2020.
% Eight radios were set up in various locations with one transmitter. Two
% data runs were made, one during a time of low traffic density near the
% radios, another with a high traffic density (during a break between
% classes). 
% The processed data should be contained in the file
% ProcessedResultsFeb2020.mat and may be found on Box (box.byu.edu) or can
% be generated through running the Process.m file.
% The capacities for each of the data runs is calculated herein, and using
% a selected invidual as the intended recipient, secrecy capacity is also
% calculated and plots of both may be presented.
clear; close all;

load ProcessedResultsFeb2020.mat; 
% Contains the variables:
% data - the processed signal carriers for the 14 processed data sets
% idxEndofData - the index of each of the 14 data sets that correspond with
%          the last radio frame (each set has a different number of frames)
% names - the names and radio numbers corresponding to each data set
% times - the datetime associated with each radio frame collected (each
%          computer started and stopped at approximately the same time with
%          some differences in how each computer recorded it's local
%          datetime

%% Capacity Variables
snr = 10; % Signal to noise ration (set by the user somewhat arbitrarily)
showPlot = false; % Whether or not to plot the capacity
sameAxis = false; % True -> one figure with overlaid plots.
                  % False -> multiple figures, one per radio

%% Secrecy Capacity Variables
bob = "Redd"; % SEE NAME OPTIONS BELOW
plotSecCap = false; % Whether ot nor to plot the secrecy capacity

%% Plotting Variables
smoothOutput = false; % Applies a filter to the outputs, smoothing it out but losing resolution
filterSize = 500; % Larger -> smoother plot, smaller -> more accurate plot

% Name options for bob are as follows:
% Radio 1: Twitchell
% Radio 2: Jensen
% Radio 3: Redd
% Radio 8: Cheng
% Radio 9: Richmond
% Radio 11: Harrison
% Radio 12: Angerbauer

%% Variable Setup
% When working this file I found that there were some duplicates in the
% times, causing problems with identifying unique frames, so the following
% section eliminates the duplicates and reassigns all of the necessary
% variables to express the changes
[sets, carriers, frames] = size(data);
newData = zeros(sets,carriers,frames);
newTimes = NaT(sets,frames);
newIdxEndOfData = zeros(1,sets);
uniqueIdxs = zeros(sets,frames);
for i = 1:sets
    [tempTimes, tempIdxs] = unique(times(i,1:idxEndOfData(i)));
    newTimes(i,1:length(tempTimes)) = tempTimes;
    uniqueIdxs(i,1:length(tempIdxs)) = tempIdxs;
    newData(i,:,1:length(tempIdxs)) = data(i,:,tempIdxs);
    newIdxEndOfData(i) = length(tempIdxs);
end

data = newData;
idxEndOfData = newIdxEndOfData;
times = newTimes;

%% Capacity
% Each radio frame has a capacity value (bits per channel use) relating to
% the amount of data that can be transmitted in that instance, which
% results from the sum of the capacity of each carrier.
capacity_perCarrier = zeros(sets,carriers,frames);
capacity = zeros(sets,frames);

for i = 1:sets
    for j = 1:carriers
        for k = 1:frames
            capacity_perCarrier(i,j,k) = (1.0/2.0)*log2(1 + data(i,j,k) * snr);
        end
    end
end
for i = 1:sets
    for j = 1:frames
        capacity(i,j) = sum(capacity_perCarrier(i,:,j));
    end
end

%% Plotting for Capacity
% Options for plotting the capacities. The plots are all overlaid on one
% figure, or they are split into one figure per radio, with two subplots,
% one for each data run.
capacityPlotting = capacity;
capacityPlotting = [capacityPlotting, zeros(sets, filterSize-1)];
if showPlot
    if smoothOutput
        filter = (1 / filterSize) * ones(1, filterSize);
        for i = 1:sets
            capacityPlotting(i,:) = conv(capacityPlotting(i,1:frames),filter);
        end
    end
    if sameAxis
        figure();
        hold on
        for i = 1:sets
            plot(capacityPlotting(i,:));
        end
        title('Capacity');
        xlabel('Index');
        ylabel('Bits');
        legend(names, 'Interpreter', 'none');
    else
        for i = 1:sets
            figure(i);
            plot(capacityPlotting(i,:));
            title('Capacity: ' + names(i), 'Interpreter', 'none');
            xlabel('Index');
            ylabel('Bits');
        end
    end
end


%% Secrecy Capacity 
% Secrecy capacity is a measure of how much information could be sent to
% bob while not leaking any information to eve. As a result, bob must be
% selected from the available data sets, and is then compared to all other
% sets. The two data sets are treated separately and are contained as odd
% and even indexes of the arrays used (odd -> low traffic, even -> high)

bobIdx = contains(names, bob, 'IgnoreCase', true); % Indices related to bob
% From the stored datetimes calculates the durations of each data run
for i = 1:sets
    temp = times(i,idxEndOfData(i)) - times(i,:);
    temp(isnan(temp)) = temp(idxEndOfData(i));
    durations(i,:) = temp;
end
[minDuration, minIdx] = min(durations(:,1)); % Finds the shortest duration
% Locates the index in each set that matches with the shortest duration
for i = 1:sets
    idxOfMinDuration(i) = find(durations(i,:) <= minDuration, 1);
end
% Stores the starting and ending indices for each data run for later use
idxStartEnd = [idxOfMinDuration; idxEndOfData]';

% The following lines split up bob and eve for easier calculations and
% comparisons
bobNames = names(bobIdx);
eveNames = names(~bobIdx);
bobData = data(bobIdx,:,:);
eveData = data(~bobIdx,:,:);
bobTimes = times(bobIdx,:);
eveTimes = times(~bobIdx,:);
bobStartEnd = idxStartEnd(bobIdx,:);
eveStartEnd = idxStartEnd(~bobIdx,:);
bobDuration = durations(bobIdx,:);
eveDuration = durations(~bobIdx,:);
bobCapacity = capacity_perCarrier(bobIdx,:,:);
eveCapacity = capacity_perCarrier(~bobIdx,:,:);

[eveSets, ~, ~] = size(eveData);
[bobSets, ~, ~] = size(bobData);

% The low and high traffic sets have different lengths and should all
% correspond to bob's lenghts for these data sets
bobSizes = bobStartEnd(:,2) - bobStartEnd(:,1) + 1;
eveClosestIdx = -ones(eveSets, max(bobSizes));
% Locates the indices for eve's duration array that most closely correspond
% to bob's durations, allowing for a one-to-one comparison. These indices
% will later be used to compare the appropriate radio frames
for i = 1:eveSets
    if mod(i,2)
        t1 = bobDuration(1,bobStartEnd(1,1):bobStartEnd(1,2));
    else
        t1 = bobDuration(2,bobStartEnd(2,1):bobStartEnd(2,2));
    end
    t2 = eveDuration(i,eveStartEnd(i,1):eveStartEnd(i,2));
    eveIndexesTemp = interp1(t2, 1:length(t2), t1, 'nearest');
    eveIndexesTemp(isnan(eveIndexesTemp)) = 1;
    eveClosestIdx(i,1:length(t1)) = eveIndexesTemp - 1 + eveStartEnd(i,1);
end

% Secrecy capacity calculations are performed using the appropriate indices
% identified earlier
secCapacity_perCarrier = zeros(eveSets, carriers, max(bobSizes));
for i = 1:eveSets
    for j = 1:carriers
        if mod(i,2)
            bobFrames = bobSizes(1);
        else
            bobFrames = bobSizes(2);
        end
        for k = 1:bobFrames
            if mod(i,2)
                secCapacity_perCarrier(i,j,k) = ...
                    max(bobCapacity(1,j,bobStartEnd(1,1) + k-1)- ...
                    eveCapacity(i,j,eveClosestIdx(i,k)),0);
            else
                secCapacity_perCarrier(i,j,k) = ...
                    max(bobCapacity(2,j,bobStartEnd(2,1) + k-1) - ...
                    eveCapacity(i,j,eveClosestIdx(i,k)),0);
            end
        end
    end
end
secCapacity = zeros(eveSets,max(bobSizes));
for i = 1:eveSets
    for j = 1:max(bobSizes)
        secCapacity(i,j) = sum(secCapacity_perCarrier(i,:,j));
    end
end

%% Plotting for Secrecy Capacity
% Plots the secrecy capacities, with the option to smooth out the plots,
% making them more readable, but less accurate. 

secCapPlotting = secCapacity;
if plotSecCap
    if smoothOutput
        filter = (1 / filterSize) * ones(1, filterSize);
        for i = 1:eveSets
            secCapPlotting(i,1:bobSizes(mod(i-1,2)+1)+filterSize-1) = ...
                conv(secCapPlotting(i,1:bobSizes(mod(i-1,2)+1)), filter);
        end
    end
    for i = 1:2:eveSets
        figure(50+i);
        subplot(2,1,1);
        plot(flip(eveDuration(i,eveClosestIdx(i,1:bobSizes(1)))), ...
            secCapPlotting(i,1:bobSizes(1)));
        title(eveNames(i), 'Interpreter', 'none');
        subplot(2,1,2);
        plot(flip(eveDuration(i+1,eveClosestIdx(i+1,1:bobSizes(2)))), ...
            secCapPlotting(i+1,1:bobSizes(2)));
        title(eveNames(i+1), 'Interpreter', 'none');
        sgtitle("Secrecy Capacity, Bob is " + string(bob));
    end
end
    
