clear; close all;

load ProcessedResultsFeb2020.mat;

%% Capacity Variables
[sets, carriers, frames] = size(data);
snr = 10;
capacity_perCarrier = zeros(sets,carriers,frames);
capacity = zeros(sets,frames);
showPlot = true;
sameAxis = true;

%% Capacity Calculation
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

% Plots the capacities
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