% Created by Kalin Norman for use in the RMCodingAttempt.m file
function [carriersAboveThreshold] = CarriersFromThreshold(data,snr,threshold)
% Finds the number of carriers above the specified threshold

[carriers, frames] = size(data);
carriersAboveThreshold = zeros(1, frames);
for frame = 1:frames
    numCarriers = 0;
    if isnan(data(1, frame))
        numCarriers = nan;
    else
        for carrier = 1:carriers
            if data(carrier, frame) * snr >= threshold
                numCarriers = numCarriers + 1;
            end
        end
    end
    carriersAboveThreshold(frame) = numCarriers;
end
end