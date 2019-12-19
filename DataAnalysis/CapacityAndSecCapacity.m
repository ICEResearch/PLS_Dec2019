clear; close all;
load data.mat;
dataTrimmed = data(:,any(data(:,:,1),1),:); % Removes all zero (non-signal) carriers
%% Capacity Variables
[dataSets, carriers, frames] = size(dataTrimmed);
snr = 10;
capacity_perCarrier = zeros(dataSets,carriers,frames);
capacity = zeros(dataSets,frames);

%% Capacity Calculation
for i = 1:dataSets
    for j = 1:carriers
        for k = 1:frames
            capacity_perCarrier(i,j,k) = (1.0/2.0)*log2(1 + dataTrimmed(i,j,k) * snr);
        end
    end
end
for i = 1:dataSets
    for j = 1:frames
        capacity(i,j) = sum(capacity_perCarrier(i,:,j));
    end
end

%% Secrecy Capacity Variables (Radio 2 [Farah] is Bob)
bobCapacity_radio2 = capacity_perCarrier(3:4,:,:);
otherCapacity_radio2 = zeros(dataSets-2,carriers,frames);
otherCapacity_radio2(1:2,:,:) = capacity_perCarrier(1:2,:,:);
otherCapacity_radio2(3:dataSets-2,:,:) = capacity_perCarrier(5:dataSets,:,:);
secCapacity_perCarrier_radio2 = zeros(dataSets-2,carriers,frames);
secCapacity_radio2 = zeros(dataSets-2,frames);
names_radio2 = ["Harrison", "Kalin", "Benj", "Amy", "Nathan", "Autumn", ...
    "Bryan", "Spencer", "Morteza"];

%% Secrecy Capacity Calculation
for i = 1:dataSets-2
    for j = 1:carriers
        for k = 1:frames
            if mod(i,2) == 0
                secCapacity_perCarrier_radio2(i,j,k) = ...
                    max(bobCapacity_radio2(2,j,k)-otherCapacity_radio2(i,j,k),0);
            else
                secCapacity_perCarrier_radio2(i,j,k) = ...
                    max(bobCapacity_radio2(1,j,k)-otherCapacity_radio2(i,j,k),0);
            end
        end
    end
end
for i = 1:dataSets-2
    for j = 1:frames
        secCapacity_radio2(i,j) = sum(secCapacity_perCarrier_radio2(i,:,j));
    end
end

%% Secrecy Capacity Variables (Radio 1 [Harrison] is Bob)
bobCapacity_radio1 = capacity_perCarrier(1:2,:,:);
otherCapacity_radio1(:,:,:) = capacity_perCarrier(3:dataSets,:,:);
secCapacity_perCarrier_radio1 = zeros(dataSets-2,carriers,frames);
secCapacity_radio1 = zeros(dataSets-2,frames);
names_radio1 = ["Farah", "Kalin", "Benj", "Amy", "Nathan", "Autumn", ...
    "Bryan", "Spencer", "Morteza"];

%% Secrecy Capacity Calculation
for i = 1:dataSets-2
    for j = 1:carriers
        for k = 1:frames
            if mod(i,2) == 0
                secCapacity_perCarrier_radio1(i,j,k) = ...
                    max(bobCapacity_radio1(2,j,k)-otherCapacity_radio1(i,j,k),0);
            else
                secCapacity_perCarrier_radio1(i,j,k) = ...
                    max(bobCapacity_radio1(1,j,k)-otherCapacity_radio1(i,j,k),0);
            end
        end
    end
end
for i = 1:dataSets-2
    for j = 1:frames
        secCapacity_radio1(i,j) = sum(secCapacity_perCarrier_radio1(i,:,j));
    end
end

% Filters (smooth out) the data to make it more understandable visually
bb = 1/100 * ones(1,100);
for i = 1:dataSets-2
    a(i,:) = conv(secCapacity_radio1(i,:), bb);
    b(i,:) = conv(secCapacity_radio2(i,:), bb);
end

%% Plot
index = 1;
for i = 1:2:dataSets-2
    figure();
    plot(secCapacity_radio1(i,:));
    hold on
    plot(secCapacity_radio1(i+1,:));
    hold off
    legend("without Traffic","with Traffic");
    title({names_radio1(index)+" Secrecy Capacity", "Harrison is Bob"});
    index = index + 1;
end

index = 1;
for i = 1:2:dataSets-2
    figure();
    plot(secCapacity_radio2(i,:));
    hold on
    plot(secCapacity_radio2(i+1,:));
    hold off
    legend("without Traffic","with Traffic");
    title({names_radio2(index)+" Secrecy Capacity", "Farah is Bob"});
    index = index + 1;
end

index = 1;
for i = 1:2:dataSets-2
    figure();
    plot(a(i,:));
    hold on
    plot(a(i+1,:));
    hold off
    legend("without Traffic","with Traffic");
    title({names_radio1(index)+" Secrecy Capacity", "Harrison is Bob"});
    index = index + 1;
end

index = 1;
for i = 1:2:dataSets-2
    figure();
    plot(b(i,:));
    hold on
    plot(b(i+1,:));
    hold off
    legend("without Traffic","with Traffic");
    title({names_radio2(index)+" Secrecy Capacity", "Farah is Bob"});
    index = index + 1;
end