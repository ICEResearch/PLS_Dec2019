clear; close all;
load ProcessedResultsFeb2020.mat;

%% User Controlled Variables (Le Magicke Numerals)
snr = 10;
histBins = 0:50;

%% Everything Else
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
clear new*;

% Capacity calculations / results
[capPerCarrier, capPerFrame] = CalculateCapacity(data, snr);

% Capacity Curve Plotting
namesAlt = ["B_1", "B_1", "B_2", "B_2", "A_1", "A_1", "B_3", "B_3", ...
    "A_2", "A_2", "B_4", "B_4", "Dropped", "Dropped"];

for i = 1:2:sets-2
    figure();
    plot(capPerFrame(i,1:idxEndOfData(i)));
    hold on
    plot(capPerFrame(i+1,1:idxEndOfData(i+1)));
    hold off
    grid on
    ylabel('Bits Per Channel Use');
    xlabel('Frame Index');
    title(namesAlt(i));
    legend('Empty','Traffic');
end

% Histogram Plotting
for i = 1:2:sets-2
    figure();
    histEmpty = histogram(capPerFrame(i,1:idxEndOfData(i)), histBins);
    hold on
    histTraffic = histogram(capPerFrame(i+1,1:idxEndOfData(i+1)), histBins);
    hold off
    grid on;
    legend('Empty','Traffic');
    xlabel('Bits Per Channel Use');
    ylabel('Count');
    title(namesAlt(i));
end