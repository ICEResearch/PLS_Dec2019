clear; close all;
load ProcessedResultsFeb2020.mat;

[numSets, numCarriers, numFrames] = size(data);
numBins = 100;
dB = true;

index = 1;
if dB
    for i = 1:numSets
        data(i,:,1:idxEndOfData(i)) = 10*log10(data(i,:,1:idxEndOfData(i)));
    end
end
for i = 1:2:numSets
    figure(index);
    subplot(2,1,1);
    histogram(data(i,:,1:idxEndOfData(i)), numBins);
    axes(i) = gca;
    title("Without Traffic");
    ylabel("Count");
    subplot(2,1,2);
    histogram(data(i+1,:,1:idxEndOfData(i+1)), numBins);
    axes(i+1) = gca;
    title("With Traffic");
    xlabel("Magnitude (dB)");
    ylabel("Count");
    index = index + 1;
    sgtitle(extractBefore(names(i),"_"));
end
ylims = cell2mat(get(axes, 'Ylim'));
xlims = cell2mat(get(axes, 'Xlim'));

yNew = [min(ylims(:,1)) max(ylims(:,2))];
set(axes, 'Ylim', yNew)

xNew = [min(xlims(:,1)) max(xlims(:,2))];
set(axes, 'Xlim', xNew)