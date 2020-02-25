clear; close all;

% load DonutProcessed_amp.mat;
load JensenProcessed_amp.mat
% dataVars = ["Angerbauer3", "Giullian1", "Jensen12", "Norman11"];
dataVars = "Jensen1";
% dataVars = ["Angerbauer3", "Jensen1", "Redd11", "Norman12"];
[~, numFiles] = size(dataVars);
% FIXME need to average over time periods to get the same size arrays

framesPerSecond = 4;
timeToCheck = 1/framesPerSecond;

for i = 1:numFiles
%     eval(sprintf('load DonutRawData/%s_amp_time.mat; time(i,:) = %s_amp_time;', ...
%         dataVars(i), dataVars(i)));
    eval(sprintf('load DonutRawData/%s_amp_time.mat; temp = %s_amp_time;', ...
        dataVars(i), dataVars(i)));
    eval(sprintf('tempdata = %s;', dataVars(i)));
    idxStart = find(tempdata(:,1) > 0, 1, 'first');
    idxEnd = find(tempdata(:,1) > 0, 1, 'last');
    starttime = temp(1);
    idx = 1;
    iteration = 1;
    for j = 1:idxEndOfData(i)
        if temp(j) > starttime + seconds(timeToCheck)
            carrier = 1;
            for k = idxStart:2:idxEnd
                data(i,carrier,iteration) = mean(tempdata(k,idx:j-1));
                carrier = carrier + 1;
            end
            idx = j;
            iteration = iteration + 1;
            starttime = temp(j);
        end
    end
end

% FIXME I am here

%% Capacity Variables
[dataSets, carriers, frames] = size(data);
snr = 10;
capacity_perCarrier = zeros(dataSets,carriers,frames);
capacity = zeros(dataSets,frames);

%% Capacity Calculation
for i = 1:dataSets
    for j = 1:carriers
        for k = 1:frames
            capacity_perCarrier(i,j,k) = (1.0/2.0)*log2(1 + data(i,j,k) * snr);
        end
    end
end
for i = 1:dataSets
    for j = 1:frames
        capacity(i,j) = sum(capacity_perCarrier(i,:,j));
    end
end
