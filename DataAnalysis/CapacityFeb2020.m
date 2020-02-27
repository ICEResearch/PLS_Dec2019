clear; close all;

load ProcessedResultsFeb2020.mat;

%% Capacity Variables
snr = 10;
showPlot = false;
sameAxis = false;

%% Secrecy Capacity Variables
bob = "Redd"; % See name options below
plotSecCap = true;

% Name options for bob are as follows:
% Radio 1: Twitchell
% Radio 2: Jensen
% Radio 3: Redd
% Radio 8: Cheng
% Radio 9: Richmond
% Radio 11: Harrison
% Radio 12: Angerbauer

%% Variable Setup
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
if showPlot
    if sameAxis
        figure();
        hold on
        for i = 1:sets
            plot(capacity(i,:));
        end
        title('Capacity');
        xlabel('Index');
        ylabel('Bits');
        legend(names);
    else
        for i = 1:sets
            figure(i);
            plot(capacity(i,:));
            title('Capacity: ' + names(i));
            xlabel('Index');
            ylabel('Bits');
        end
    end
end


%% Secrecy Capacity 
bobIdx = contains(names, bob, 'IgnoreCase', true);
for i = 1:sets
    temp = times(i,idxEndOfData(i)) - times(i,:);
    temp(isnan(temp)) = temp(idxEndOfData(i));
    durations(i,:) = temp;
end
[minDuration, minIdx] = min(durations(:,1));
for i = 1:sets
    idxOfMinDuration(i) = find(durations(i,:) <= minDuration, 1);
end
idxStartEnd = [idxOfMinDuration; idxEndOfData]';

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

bobSizes = bobStartEnd(:,2) - bobStartEnd(:,1) + 1;
eveClosestIdx = -ones(eveSets, max(bobSizes));
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

if plotSecCap
    for i = 1:2:eveSets
        figure(50+i);
        subplot(2,1,1);
        plot(flip(eveDuration(i,eveClosestIdx(i,1:bobSizes(1)))), ...
            secCapacity(i,1:bobSizes(1)));
        title(eveNames(i), 'Interpreter', 'none');
        subplot(2,1,2);
        plot(flip(eveDuration(i+1,eveClosestIdx(i+1,1:bobSizes(2)))), ...
            secCapacity(i+1,1:bobSizes(2)));
        title(eveNames(i+1), 'Interpreter', 'none');
        sgtitle("Secrecy Capacity, Bob is " + string(bob));
    end
end
    
