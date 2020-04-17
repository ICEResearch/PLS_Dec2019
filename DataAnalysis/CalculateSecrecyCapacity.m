function [secCapacityPerCarrier, secCapacityPerFrame] = ...
    CalculateSecrecyCapacity(bobCapacity,eveCapacity)
% This function calculates the secrecy capacity using the
% capacityPerCarrier data that can be obtained through the use of the
% CalculateCapacity function. The data should be split previously into
% Bob's data and Eve's data

[bobCarriers, bobFrames] = size(bobCapacity);
[eveSets, eveCarriers, eveFrames] = size(eveCapacity);
if eveFrames == 1
    eveFrames = eveCarriers;
    eveCarriers = eveSets;
    eveSets = 1;
    eveData(1,:,:) = eveCapacity;
else
    eveData = eveCapacity;
end
bobData = bobCapacity;

if bobCarriers ~= eveCarriers
    disp('ERROR in CalculateSecrecyCapacity, bobCarriers ~= eveCarriers.');
    disp('Please ensure that the two data sets have an equal number of');
    disp('carriers and try again.');
    return
end
if bobFrames ~= eveFrames
    disp('ERROR in CalculateSecrecyCapacity, bobFrames ~= eveFrames.');
    disp('Please ensure that the two data sets have an equal number of');
    disp('frames and try again.');
    return
end

secCapacityPerCarrier = zeros(eveSets, eveCarriers, eveFrames);

for i = 1:eveSets
    for j = 1:eveCarriers
        for k = 1:eveFrames
            secCapacityPerCarrier(i,j,k) = ...
                max(bobData(i,j,k) - eveData(i,j,k), 0);
        end
    end
end

secCapacityPerFrame = zeros(eveSets, eveFrames);

for i = 1:eveSets
    for j = 1:eveFrames
        secCapacityPerFrame = sum(secCapacityPerCarrier(i,:,j));
    end
end

secCapacityPerCarrier = squeeze(secCapacityPerCarrier);
secCapacityPerFrame = squeeze(secCapacityPerFrame);
            
end

