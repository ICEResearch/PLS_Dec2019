function [capacityPerCarrier, capacityPerFrame] = CalculateCapacity(dataIn, snr)
% This function takes previously processed data and computes the capacity
% per channel use at each input frame. It has two outputs.
% capacityPerCarrier is necessary if secrecy capacity will later be
% calculated, and capacityPerFrame is what can be plotted to show the
% number of bits per channel use at each frame.

% data should be an input array of dimensions
% (x, y, z) -> (dataSet, carriers, frames)
% or if there is only one set then (x, y) -> (carriers, frames)

% snr stands for Signal to Noise Ratio, and is previously determined or
% selected.

[numSets, numCarriers, numFrames] = size(dataIn);
if numFrames == 1
    numFrames = numCarriers;
    numCarriers = numSets;
    numSets = 1;
    data(1,:,:) = dataIn;
else
    data = dataIn;
end
capacityPerCarrier = zeros(numSets, numCarriers, numFrames);
capacityPerFrame = zeros(numSets, numFrames);

for i = 1:numSets
    for j = 1:numCarriers
        for k = 1:numFrames
            capacityPerCarrier(i,j,k) = (1.0 / 2.0) * ...
                log2(1 + data(i,j,k) * snr);
        end
    end
end
for i = 1:numSets
    for j = 1:numFrames
        capacityPerFrame(i,j) = sum(capacityPerCarrier(i,:,j));
    end
end

capacityPerCarrier = squeeze(capacityPerCarrier);
capacityPerFrame = squeeze(capacityPerFrame);

end

