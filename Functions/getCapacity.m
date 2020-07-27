function [frames, capacity_carrier, capacity_array] = getCapacity(data, SNR)
    % Adding a return value of capacity_carrier
    [~, carriers, ~] = size(data);
    
    % Trim off trailing zeros
    frames = max(find(data(1,1,:) ~= 0));
    capacity_carrier = zeros(carriers, frames);
    capacity_array = zeros(1, frames);

    for j = 1:carriers
        for k = 1:frames
            capacity_carrier(j, k) = (1.0/2.0)*log2(1 + SNR*data(1, j, k)); 
        end
    end
    for j = 1:frames
        capacity_array(1,j) = sum(capacity_carrier(:,j));
    end
end