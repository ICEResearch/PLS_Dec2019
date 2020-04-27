%% Created by Kalin Norman
% April 24, 2020

%% Actual File
close all; clear;
GaussianSecrecyCapacity; % Run secrecy capacity file to get necessary variables
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
carriersGroup1 = zeros(8, numSNRs, 20459);
carriersGroup2 = zeros(8, numSNRs, 16050);
for i = 1:8
    if mod(i,2)
        bob1 = squeeze(closestIdxBobData_A_1(1,:,:));
        bob2 = squeeze(closestIdxBobData_A_2(1,:,:));
    else
        bob1 = squeeze(closestIdxBobData_A_1(2,:,:));
        bob2 = squeeze(closestIdxBobData_A_2(2,:,:));
    end
    eve1 = squeeze(closestIdxEveData_A_1(i,:,:));
    eve2 = squeeze(closestIdxEveData_A_2(i,:,:));
    for j = 1:numSNRs
        carriersGroup1(i,j,:) = SecCapFromThreshold(bob1, eve1, snrArray(j), thresholdLinear);
        carriersGroup2(i,j,:) = SecCapFromThreshold(bob2, eve2, snrArray(j), thresholdLinear);
    end
        
end

for i = 1:8
    for j = 1:numSNRs
        group1Avgs(i,j) = mean(carriersGroup1(i,j,:));
        group2Avgs(i,j) = mean(carriersGroup2(i,j,:));
    end
end

snrArray = 10*log10(snrArray);

for i = 1:8
    if mod(i,2)
        figure(1); hold on
        plot(snrArray, group1Avgs(i,:));
        figure(3); hold on
        plot(snrArray, group2Avgs(i,:));
    else 
        figure(2); hold on
        plot(snrArray, group1Avgs(i,:));
        figure(4); hold on
        plot(snrArray, group2Avgs(i,:));
    end
end
figure(1); grid on; legend(groupEveVars, 'Location', 'southeast'); title('Bob A1 - Sparse');
ylabel('Avg Secrecy Capacity (Bits)'); xlabel('SNR');
figure(2); grid on; legend(groupEveVars, 'Location', 'southeast'); title('Bob A1 - Heavy');
ylabel('Avg Secrecy Capacity (Bits)'); xlabel('SNR');
figure(3); grid on; legend(groupEveVars, 'Location', 'southeast'); title('Bob A2 - Sparse');
ylabel('Avg Secrecy Capacity (Bits)'); xlabel('SNR');
figure(4); grid on; legend(groupEveVars, 'Location', 'southeast'); title('Bob A2 - Heavy');
ylabel('Avg Secrecy Capacity (Bits)'); xlabel('SNR');

function [secCap] = SecCapFromThreshold(bob,eve,snr,threshold)
% Finds the number of carriers above the specified threshold

[carriers, frames] = size(bob);
secCap = zeros(1, frames);
for frame = 1:frames
    numCarriers = 0;
    if isnan(bob(1, frame))
        numCarriers = nan;
    else
        for carrier = 1:carriers
            bobCarrier = bob(carrier, frame) * snr >= threshold;
            eveCarrier = eve(carrier, frame) * snr >= threshold;
            if bobCarrier && ~eveCarrier
                numCarriers = numCarriers + 1;
            end
        end
    end
    secCap(frame) = numCarriers;
end
end