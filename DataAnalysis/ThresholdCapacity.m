%% Created by Kalin Norman
% April 23, 2020 (Modified version of File from V2VSecurity paper, original
% file created by Bradford Clark

%% Actual File
close all; clear;
SecrecyCapacityApril17; % Run secrecy capacity file to get necessary variables
groupBob = group1alt; % rename 
groupEve = group2alt; % rename
%%
close all; clearvars -except groupBob groupEve closestIdx*; % Isolate the only needed variables
groupBobVars = lower(extractBefore(groupBob, '_'))+extractAfter(groupBob, '_');
groupEveVars = lower(extractBefore(groupEve, '_'))+extractAfter(groupEve, '_');
group1vars = [groupBobVars(1) groupEveVars];
group2vars = [groupBobVars(2) groupEveVars];

thresholdDB = 0;
thresholdLinear = 10^(thresholdDB/10);
firstDecade = 0; % 10^firstDecade
secondDecade = 4; % 10^secondDecade
numSNRs = 200;
snrArray = logspace(firstDecade, secondDecade, numSNRs);

groups = 2;
dataGroup1 = zeros(10, 42, 20459);
dataGroup2 = zeros(10, 42, 16050);
carriersGroup1 = zeros(10, numSNRs, 20459);
carriersGroup2 = zeros(10, numSNRs, 16050);
for i = 1:10
    if i <= 2
        temp1 = squeeze(closestIdxBobData_A_1(i,:,:));
        temp2 = squeeze(closestIdxBobData_A_2(i,:,:));
        dataGroup1(i,:,:) = temp1;
        dataGroup2(i,:,:) = temp2;
    else
        temp1 = squeeze(closestIdxEveData_A_1(i-2,:,:));
        temp2 = squeeze(closestIdxEveData_A_2(i-2,:,:));
        dataGroup1(i,:,:) = temp1;
        dataGroup2(i,:,:) = temp2;
    end
    for j = 1:numSNRs
        carriersGroup1(i,j,:) = CarriersFromThreshold(temp1, snrArray(j), thresholdLinear);
        carriersGroup2(i,j,:) = CarriersFromThreshold(temp2, snrArray(j), thresholdLinear);
    end
        
end

for i = 1:10
    for j = 1:numSNRs
        group1Sums(i,j) = sum(carriersGroup1(i,j,:) == 42);
        group2Sums(i,j) = sum(carriersGroup2(i,j,:) == 42);
        group1AtMax(i,j) = group1Sums(i,j) == 20459;
        group2AtMax(i,j) = group2Sums(i,j) == 16050;
    end
end

snrArray = 10*log10(snrArray);

for i = 1:10
    if mod(i,2)
        figure(5); hold on
        plot(snrArray, group1Sums(i,:));
        figure(6); hold on
        plot(snrArray, group2Sums(i,:));
    else 
        figure(7); hold on
        plot(snrArray, group1Sums(i,:));
        figure(8); hold on
        plot(snrArray, group2Sums(i,:));
    end
end
figure(1); grid on; legend(group1vars, 'Location', 'southeast'); title('Bob A1 - Sparse');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group1AtMax(1,:)), group1Sums(1, group1AtMax(1,:)), 'xk');
figure(2); grid on; legend(group1vars, 'Location', 'southeast'); title('Bob A1 - Heavy');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group1AtMax(2,:)), group1Sums(2, group1AtMax(2,:)), 'xk');
figure(3); grid on; legend(group2vars, 'Location', 'southeast'); title('Bob A2 - Sparse');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group2AtMax(1,:)), group2Sums(1, group2AtMax(1,:)), 'xk');
figure(4); grid on; legend(group2vars, 'Location', 'southeast'); title('Bob A2 - Heavy');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group2AtMax(2,:)), group2Sums(2, group2AtMax(2,:)), 'xk');
            