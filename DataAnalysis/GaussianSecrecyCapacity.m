clear; close all;
set(0,'DefaultFigureVisible','off'); % Supress figure visibility
GaussianCapacity; % Run Capacity File
close all; clear hist* xAxis*; % Gets rid of figures and variables from capacity plots
set(0,'DefaultFigureVisible','on'); % Return figure visibility

%% User Controlled Variables
histBins = 0:50;

%% The Code
% group1 = ["Redd", "Richmond", "Angerbauer"]; % We decided to throw out
% Angerbauer's Data
group1 = ["Redd", "Richmond"];
group2 = ["Twitchell", "Jensen", "Cheng", "Harrison"];
group1alt = ["B2", "B1"];
group2alt = ["E1", "E4", "E2", "E3"];
plotNames_group1 = ["B2", "B1"];

xAxis_time = zeros(2, 22000);

% From the stored datetimes calculates the durations of each data run
for i = 1:sets
    temp = times(i,idxEndOfData(i)) - times(i,:);
    temp(isnan(temp)) = temp(idxEndOfData(i));
    durations(i,:) = temp;
end
[minDuration, minIdx] = min(durations(:,1)); % Finds the shortest duration
% Locates the index in each set that matches with the shortest duration
idxOfMinDuration = zeros(1,sets);
for i = 1:sets
    idxOfMinDuration(i) = find(durations(i,:) <= minDuration, 1);
end
% Stores the starting and ending indices for each data run for later use
idxStartEnd = [idxOfMinDuration; idxEndOfData]';

plotIdx = 1;
axesIdx = 1;


for bobSelect = 1:length(group1)
    bob = group1(bobSelect);
    
    % Identifies the indices that correspond to both groups and to bob
    group1_idx = contains(names, group1, 'IgnoreCase', true);
    group2_idx = contains(names, group2, 'IgnoreCase', true);
    bob_idx = contains(names, bob, 'IgnoreCase', true);
    
    % Determines which group bob is in, and thereby which group is eve
    bobName = namesAlt(bob_idx); bobName = bobName(1);
    if any(bob_idx & group1_idx)
        eve_idx = group2_idx;
        eveNames = group2alt;
    elseif any(bob_idx & group2_idx)
        eve_idx = group1_idx;
        eveNames = group1alt;
    else
        disp('ERROR: specified Bob was not found in either group');
        return
    end
    
    % Separates bob and eve's data into their own variable for easier use
    bobData = data(bob_idx,:,:);
    bobDurations = durations(bob_idx,:);
    bobCapPerCarrier_temp = capPerCarrier(bob_idx,:,:);
    bobStartEnd = idxStartEnd(bob_idx,:);
    eveData = data(eve_idx,:,:);
    eveDurations = durations(eve_idx,:);
    eveCapPerCarrier_temp = capPerCarrier(eve_idx,:,:);
    eveStartEnd = idxStartEnd(eve_idx,:);
    
    % Ultimately we want equal length arrays, both between bob and eve, and
    % also between the empty and traffic cases, in order to plot and compare
    % histograms of the secrecy capacity data. This next section of code
    % determines the smallest length array of bob's two cases, and then
    % determines the nearest duration values for bob's other case, and all of
    % eve's cases. Those nearest duration values are used to identify the
    % correct indices of the capacity arrays in order to be used for secrecy
    % capacity calculations.
    % Identify Bob's minimum length array, and corresponding index
    bobLengths = bobStartEnd(:,2) - bobStartEnd(:,1) + 1;
    idxBobMin = bobLengths' == min(bobLengths);
    
    % Get the indices for bob's longer array
    t1 = bobDurations(idxBobMin,bobStartEnd(idxBobMin,1):bobStartEnd(idxBobMin,2));
    t2 = bobDurations(~idxBobMin,1:bobStartEnd(~idxBobMin,2));
    bobClosestIdx = interp1(t2, 1:length(t2), t1, 'nearest');
    
    % Create the final array of Bob's capacities
    bobCapPerCarrier = zeros(sum(bob_idx), carriers, min(bobLengths));
    eval(['closestIdxBobData_' char(group1alt(bobSelect)) ' = bobCapPerCarrier;']);
    for i = 1:min(bobLengths)
        bobCapPerCarrier(idxBobMin, :, i) = ...
            bobCapPerCarrier_temp(idxBobMin, :, bobStartEnd(idxBobMin, 1) - 1 + i);
        bobCapPerCarrier(~idxBobMin, :, i) = ...
            bobCapPerCarrier_temp(~idxBobMin, :, bobClosestIdx(i));
        eval(['closestIdxBobData_' char(group1alt(bobSelect)) '(idxBobMin, :, i)' ...
            ' = bobData(idxBobMin, :, bobStartEnd(idxBobMin, 1) - 1 + i);']);
        eval(['closestIdxBobData_' char(group1alt(bobSelect)) '(~idxBobMin, :, i)' ...
            ' = bobData(~idxBobMin, :, bobClosestIdx(i));']);
        eval(['durations_' char(group1alt(bobSelect)) '(1, i)' ...
            ' = bobDurations(idxBobMin, bobStartEnd(idxBobMin, 1) - 1 + i);']);
    end
    
    eval(['time_' char(group1alt(bobSelect)) ...
        ' = fliplr(durations_' char(group1alt(bobSelect)) ');']);
    
    % Identify the indices for all of Eve's cases
    eveClosestIdx = zeros(sum(eve_idx), min(bobLengths));
    for i = 1:sum(eve_idx)
        t2 = eveDurations(i,1:eveStartEnd(i,2));
        eveClosestIdx(i,:) = interp1(t2, 1:length(t2), t1, 'nearest');
    end
    
    % Create the final array of Eve's capacities
    eveCapPerCarrier = zeros(sum(eve_idx), carriers, min(bobLengths));
    eval(['closestIdxEveData_' char(group1alt(bobSelect)) ' = eveCapPerCarrier;']);
    for i = 1:sum(eve_idx)
        for j = 1:min(bobLengths)
            eveCapPerCarrier(i,:,j) = ...
                eveCapPerCarrier_temp(i,:, eveClosestIdx(i,j));
            eval(['closestIdxEveData_' char(group1alt(bobSelect)) '(i, :, j)' ...
                ' = eveData(i, :, eveClosestIdx(j));']);
        end
    end
    
    % Secrecy Capacity Calculations
    secrecyCapacity = zeros(sum(eve_idx), min(bobLengths));
    for i = 1:sum(eve_idx)
        if mod(i,2) % Odd numbers (Empty Case)
            bobIn = squeeze(bobCapPerCarrier(1,:,:));
        else % Even Numbers (Traffic Case)
            bobIn = squeeze(bobCapPerCarrier(2,:,:));
        end
        eveIn = squeeze(eveCapPerCarrier(i,:,:));
        [perCarrier, perFrame] = CalculateSecrecyCapacity(bobIn, eveIn);
        secrecyCapacity(i,:) = perFrame;
    end
    
    % Secrecy Curve Plotting
    idxForPlot = 1;
    plotIdx = (bobSelect-1)*4 + 1;
    axesIdx = (bobSelect-1)*8 + 1;
    
    tempTime = seconds(flip(bobDurations(idxBobMin, bobStartEnd(idxBobMin,1):bobStartEnd(idxBobMin,2))));
    
    for i = 1:2:sum(eve_idx)
        figure(1);
        subplot(4,2,plotIdx)
        hold on 
        plot(tempTime, secrecyCapacity(i,:));
        axes(axesIdx) = gca;
        plot(tempTime, secrecyCapacity(i+1,:));
        axes(axesIdx+1) = gca;
        grid on;
        xlabel('Time (s)');
        ylabel('Bits');
        legend('Sparse','Heavy');
        title(plotNames_group1(bobSelect) + ' || ' + eveNames(idxForPlot));
        hold off
        idxForPlot = idxForPlot + 1;
        plotIdx = plotIdx + 1;
        axesIdx = axesIdx + 2;
    end
    
    if length(tempTime) ~= length(xAxis_time)
        diff = length(xAxis_time) - length(tempTime);
        tempTime = [tempTime zeros(1, diff)];
    end
    xAxis_time(bobSelect, :) = tempTime;
    
    % Histogram Plotting
    idxForPlot = 1;
    plotIdx = (bobSelect-1)*4 + 1;
    axesIdx = (bobSelect-1)*8 + 1;
    for i = 1:2:sum(eve_idx)
        figure(2);
        subplot(4,2, plotIdx)
        hold on 
        histEmpty = histogram(secrecyCapacity(i,:), histBins, 'Normalization', 'probability');
        histAxes(axesIdx) = gca;
        histTraffic = histogram(secrecyCapacity(i+1,:), histBins, 'Normalization', 'probability');
        histAxes(axesIdx + 1) = gca;
        grid on;
        legend('Sparse','Heavy');
        xlabel('Bits Per Channel Use');
        ylabel('Count');
        title(plotNames_group1(bobSelect) + ' || ' + eveNames(idxForPlot));
        hold off
        idxForPlot = idxForPlot + 1;
        plotIdx = plotIdx + 1;
        axesIdx = axesIdx + 2;
    end
    
%     % This can stay commented out, it was only used to save data that Dr Rice
%     %   wanted access to
%     for i = 1:sum(eve_idx)
%         if mod(i,2) % Odd numbers (Empty Case)
%             c = 'empty';
%         else % Even Numbers (Traffic Case)
%             c = 'traffic';
%         end
%         eval(['secrecyCapacity_' char(lower(bobName)) ...
%             '_' char(lower(eveNames(ceil(i/2)))) ...
%             '_' c ' = secrecyCapacity(i,:);']);
%     end
%     timeForXAxis = bobDurations(idxBobMin, bobStartEnd(idxBobMin,1):bobStartEnd(idxBobMin,2));
%     save(['SecrecyCapacity_' char(lower(bobName)) '.mat'], ...
%         'secrecyCapacity_*', 'timeForXAxis');
    
end


% Set Y/X Limits on all plots to the same values
ylims = cell2mat(get(axes, 'Ylim'));
xlims = cell2mat(get(axes, 'Xlim'));

yLimsNew = [min(ylims(:,1)) max(ylims(:,2))];
set(axes, 'Ylim', yLimsNew);

xLimsNew = [min(xlims(:,1)) max(xlims(:,2))];
set(axes, 'Xlim', xLimsNew);

set(axes, 'FontSize', 14);

% Set Y/X Limits on all plots to the same values
ylims = cell2mat(get(histAxes, 'Ylim'));
xlims = cell2mat(get(histAxes, 'Xlim'));

yLimsNew = [min(ylims(:,1)) max(ylims(:,2))];
set(histAxes, 'Ylim', yLimsNew);

xLimsNew = [min(xlims(:,1)) max(xlims(:,2))];
set(histAxes, 'Xlim', xLimsNew);

set(histAxes, 'FontSize', 14);

%% Determine the means + standard deviations
% stored in rows of (Mean, St. Dev)

for i = 1:2:16
    stats(i, 1) = mean(histAxes(i).Children(1).Data);
    stats(i, 2) = std(histAxes(i).Children(1).Data);

    stats(i+1, 1) = mean(histAxes(i).Children(2).Data);
    stats(i+1, 2) = std(histAxes(i).Children(2).Data);
end

%% Save the data by pulling it off the plots
    % Start with B2, storing time and then heavy/sparse for each Eve
SecrecyCapacity_B2(1,:) = axes(1).Children(1).XData; % Time data for B2  

for i = 1:2:8
    SecrecyCapacity_B2((i+1),:) = axes(i).Children(1).YData; % Heavy
    SecrecyCapacity_B2((i+2),:) = axes(i).Children(2).YData; % Sparse
end

    % Start with B1, storing time and then heavy/sparse for each Eve
SecrecyCapacity_B1(1,:) = axes(9).Children(1).XData; % Time data for B1  

for i = 1:2:8
    SecrecyCapacity_B1((i+1),:) = axes(i+8).Children(1).YData; % Heavy
    SecrecyCapacity_B1((i+2),:) = axes(i+8).Children(2).YData; % Sparse
end

%% 
for i = 1:4
    figure(1)
    subplot(4,2,i)
    hold on 
    plot(SecrecyCapacity_B2(1,:), SecrecyCapacity_B2(2*i+1,:));
    plot(SecrecyCapacity_B2(1,:), SecrecyCapacity_B2(2*i,:));
    hold off 
end

for i = 1:4
    figure(1)
    subplot(4,2,i+4)
    hold on 
    plot(SecrecyCapacity_B1(1,:), SecrecyCapacity_B1(2*i+1,:));
    plot(SecrecyCapacity_B1(1,:), SecrecyCapacity_B1(2*i,:));
    hold off 
end