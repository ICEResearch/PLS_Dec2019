function scaledData = ScaleAvgNoiseToOne(data, noiseOnOddCarriers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    [x, y, z] = size(data);
    if z > 1
        numDataSets = x;
        numCarriers = y;
        numFrames = z;
    else
        numDataSets = 1;
        numCarriers = x;
        numFrames = y;
    end
    for i = 1:numDataSets
        for j = 1:numFrames
            if numDataSets == 1
                if noiseOnOddCarriers
                    nonzeroData = nonzeros(data(:,j));
                    % noiseAvg excludes the center phantom noise subcarrier
                    % noiseAvg2 does not exlude the center noise carrier
                    % for calculating the noise average
                    noiseAvg = mean(nonzeroData([1:2:31 35:2:end],1));
                    %noiseAvg = mean(nonzeroData(1:2:end,1));
                else
                    nonzeroData = nonzeros(data(:,j));
                    noiseAvg = mean(nonzeroData(2:2:end,1));
                end
                scaledData(:,j) = data(:,j) ./ noiseAvg;
            else
                if noiseOnOddCarriers
                    noiseAvg = mean(data(i,1:2:numCarriers,j));
                else
                    noiseAvg = mean(data(i,2:2:numCarriers,j));
                end
                scaledData(i,:,j) = data(i,:,j) ./ noiseAvg;
            end
        end
    end
    
end

