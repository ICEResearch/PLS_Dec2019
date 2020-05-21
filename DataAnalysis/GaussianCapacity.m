clear; close all;
addpath ../Data
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
    % This list is just provided for reference
namesAlt = ["Twitchell", "Twitchell", "Jensen", "Jensen", "Redd", "Redd", ...
             "Cheng", "Cheng", "Richmond", "Richmond", "Harrison", "Harrison", ...
             "Angerbauer", "Angerbauer"];
    % This is the list of names actually used
namesAlt = ["E1", "E1", "E4", "E4", "B2", "B2", "E2", "E2", "B1", "B1", ...
            "E3", "E3", "TOSS", "TOSS"];


for i = 1:sets
    xAxisTimes(i,:) = seconds(times(i,idxEndOfData(i)) - times(i,:));
end

%%
plotIdx = 1;
for i = 1:2:sets-2 % the '-2' corresponds to dropping Angerbauer's data
    figure(1);
    subplot(2, 3, plotIdx);
    hold on
    plot(flip(xAxisTimes(i,1:idxEndOfData(i))), capPerFrame(i,1:idxEndOfData(i)));
    axes(i) = gca;
    plot(flip(xAxisTimes(i+1,1:idxEndOfData(i+1))), capPerFrame(i+1,1:idxEndOfData(i+1)));
    axes(i+1) = gca;
    hold off
    grid on
    if (plotIdx == 1 || plotIdx ==4)
        ylabel('Bits Per Channel Use');
    end
    if (plotIdx > 3)
        xlabel('Time (s)');
    end
    
    if (plotIdx == 3)
        legend('Sparse','Heavy');
    end
    title(namesAlt(i));
    
    plotIdx = plotIdx + 1;
end

%%
% Histogram Plotting
plotIdx = 1;
for i = 1:2:sets-2 % the '-2' corresponds to dropping Angerbauer's data
    figure(2);
    subplot(2, 3, plotIdx)
    hold on 
    histEmpty = histogram(capPerFrame(i,1:idxEndOfData(i)), histBins, 'Normalization', 'probability');
    hAxes(i) = gca;
    histTraffic = histogram(capPerFrame(i+1,1:idxEndOfData(i+1)), histBins, 'Normalization', 'probability');
    hAxes(i+1) = gca;
    hold off
    grid on;
    if plotIdx == 3   
        legend('Sparse','Heavy');
    end
    if plotIdx > 3
        xlabel('Bits Per Channel Use');
    end
    if (plotIdx == 1 || plotIdx == 4)
        ylabel('Frequency');
    end
    title(namesAlt(i));
    
    plotIdx = plotIdx + 1;
end


%%
% Set Y/X Limits on all plots to the same values
ylims = cell2mat(get(axes, 'Ylim'));
xlims = cell2mat(get(axes, 'Xlim'));

yLimsNew = [min(ylims(:,1)) max(ylims(:,2))];
set(axes, 'Ylim', yLimsNew);

xLimsNew = [min(xlims(:,1)) max(xlims(:,2))];
set(axes, 'Xlim', xLimsNew);

set(axes, 'FontSize', 14);

% Repeat for histograms
ylims = cell2mat(get(hAxes, 'Ylim'));
xlims = cell2mat(get(hAxes, 'Xlim'));

yLimsNew = [min(ylims(:,1)) max(ylims(:,2))];
set(hAxes, 'Ylim', yLimsNew);

xLimsNew = [min(xlims(:,1)) max(xlims(:,2))];
set(hAxes, 'Xlim', xLimsNew);

set(hAxes, 'FontSize', 14);