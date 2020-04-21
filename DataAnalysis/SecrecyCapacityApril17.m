clear; close all;
set(0,'DefaultFigureVisible','off'); % Supress figure visibility
CapacityApril17; % Run Capacity File
close all; clear hist*; % Gets rid of figures and variables from capacity plots
set(0,'DefaultFigureVisible','on'); % Return figure visibility

%% User Controlled Variables
bob = "Harrison";
histBins = 0:50;

%% The Code
% group1 = ["Redd", "Richmond", "Angerbauer"]; % We decided to throw out Angerbauer
group1 = ["Redd", "Richmond"];
group2 = ["Twitchell", "Jensen", "Cheng", "Harrison"]; 
group1alt = ["A_1", "A_2"];
group2alt = ["B_1", "B_2", "B_3", "B_4"];

dataGroup1 = zeros(length(group1), carriers, frames);
dataGroup2 = zeros(length(group2), carriers, frames);

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
bobDurations = durations(bob_idx,:);
bobCapPerCarrier_temp = capPerCarrier(bob_idx,:,:);
bobStartEnd = idxStartEnd(bob_idx,:);
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
for i = 1:min(bobLengths)
    bobCapPerCarrier(idxBobMin, :, i) = ...
        bobCapPerCarrier_temp(idxBobMin, :, bobStartEnd(idxBobMin, 1) - 1 + i);
    bobCapPerCarrier(~idxBobMin, :, i) = ...
        bobCapPerCarrier_temp(~idxBobMin, :, bobClosestIdx(i));
end

% Identify the indices for all of Eve's cases
for i = 1:sum(eve_idx)
    t2 = eveDurations(i,1:eveStartEnd(i,2));
    eveClosestIdx(i,:) = interp1(t2, 1:length(t2), t1, 'nearest');
end

% Create the final array of Eve's capacities
eveCapPerCarrier = zeros(sum(eve_idx), carriers, min(bobLengths));
for i = 1:sum(eve_idx)
    for j = 1:min(bobLengths)
        eveCapPerCarrier(i,:,j) = ...
            eveCapPerCarrier_temp(i,:, eveClosestIdx(i,j));
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
xDuration = bobDurations(idxBobMin, bobStartEnd(idxBobMin,1):bobStartEnd(idxBobMin,2));
for i = 1:2:sum(eve_idx)
    figure();
    plot(xDuration, secrecyCapacity(i,:));
    hold on
    plot(xDuration, secrecyCapacity(i+1,:));
    hold off
    grid on;
    legend('Empty','Traffic');
    title('Bob is ' + bobName + ' || Eve is ' + eveNames(idxForPlot));
    idxForPlot = idxForPlot + 1;
end

% Histogram Plotting
idxForPlot = 1;
for i = 1:2:sum(eve_idx)
    figure();
    histEmpty = histogram(secrecyCapacity(i,:), histBins);
    hold on
    histTraffic = histogram(secrecyCapacity(i+1,:), histBins);
    hold off
    grid on;
    legend('Empty','Traffic');
    xlabel('Bits Per Channel Use');
    ylabel('Count');
    title('Bob is ' + bobName + ' || Eve is ' + eveNames(idxForPlot));
    idxForPlot = idxForPlot + 1;
end


%% This can stay commented out, it was only used to save data that Dr Rice
%% wanted access to

% for i = 1:sum(eve_idx)
%     if mod(i,2) % Odd numbers (Empty Case)
%         c = 'empty';
%     else % Even Numbers (Traffic Case)
%         c = 'traffic';
%     end
%     eval(['secrecyCapacity_' char(lower(extractBefore(bobName, '_'))) char(extractAfter(bobName, '_')) ...
%         '_' char(lower(extractBefore(eveNames(ceil(i/2)), '_'))) char(extractAfter(eveNames(ceil(i/2)), '_')) ...
%         '_' c ' = secrecyCapacity(i,:);']);
% end
% timeForXAxis = bobDurations(idxBobMin, bobStartEnd(idxBobMin,1):bobStartEnd(idxBobMin,2));
% save(['SecrecyCapacity_' char(lower(extractBefore(bobName, '_'))) char(extractAfter(bobName, '_')) '.mat'], ...
%     'secrecyCapacity_*', 'timeForXAxis');
