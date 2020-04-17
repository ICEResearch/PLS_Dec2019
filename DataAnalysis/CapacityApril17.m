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


for i = 1:2:sets
    figure();
    subplot(2,1,1);
    histEmpty = histogram(capPerFrame(i,1:idxEndOfData(i)), histBins);
    hold on
    histTraffic = histogram(capPerFrame(i+1,1:idxEndOfData(i+1)), histBins);
    hold off
    grid on;
    legend('Empty','Traffic');
    xlabel('Bits Per Channel Use');
    ylabel('Count');
    subplot(2,1,2);
    bar(histTraffic.Values - histEmpty.Values);
    grid on;
    title('Difference Between Traffic And Empty');
    xlabel('Bits Per Channel Use');
    ylabel('Count');
    sgtitle(string(extractBefore(upper(extractBefore(names(i),2)) ...
        + extractAfter(names(i),1),'_')));
end