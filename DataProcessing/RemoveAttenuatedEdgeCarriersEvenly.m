function goodData = RemoveAttenuatedEdgeCarriersEvenly(data, noiseOnOddCarriers, numTrimOnEachSide)
    % Removes the edge carriers of a waveform that are attenuated by
    % hardware. Does this by trimming off a provided number of signal carriers
    % from each side (also trims off the appropriate number of noise
    % carriers)

    [carriers, frames] = size(data);
    
    % Need to remove equal number of noise and signal carriers, from both
    % sides. Use a mask to remove the attenuated data while not affecting
    % the 'good' carriers
    lowCarrier = 2*numTrimOnEachSide+1;
    highCarrier = carriers - 2*numTrimOnEachSide;
    keepCarriers = zeros(carriers, frames);
    keepCarriers(lowCarrier:highCarrier, :) = 1;
    
    goodData = keepCarriers .* data;
 
    % Plots an example showing which carriers were kept, allowing for
    % visual verification of the result the code found
    stem(data(:,1));
    hold on
    maskedData = zeros(carriers,1);
    maskedData(lowCarrier:highCarrier,1) = data(lowCarrier:highCarrier,1);
    stem(maskedData, 'MarkerFaceColor','k');
    title({'Result from RemoveAttenuatedEdges.m', ...
        'Plot values are in dB for visual clarity'});
    hold off
        
    % Masks the original data with zeros for everything that is
    % attentuated, leaving the 'good' carriers untouched
    keepCarriers = zeros(carriers,frames);
    keepCarriers(lowCarrier:highCarrier,:) = 1;
    goodData = keepCarriers .* data;
end

