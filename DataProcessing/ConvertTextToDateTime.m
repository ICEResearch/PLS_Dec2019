tic;
clear; close all;
addpath('../Data');
addpath('../Data/LOSData');

names = ["Twitchell1", ...
    "Jensen2", ...
    "redd3", ...
    "Cheng8", ...
    "richmond9", ...
    "Harrison11", ...
    "Angerbauer12"];
tags = ["_empty", "_traffic"];

for i = 1:length(names)
    for j = 1:2
        eval(sprintf("freader = fopen('%s%s.txt', 'r');", names(i), tags(j)));
        date = '19-Feb-2020 ';
        A = fscanf(freader, '%s');
        B = reshape(A, [15, length(A)/15])';
        dates = repmat(date, [length(A)/15, 1]);
        C = [dates, B];
        D = datetime(C)';
        eval(sprintf("%s%s_videoTimes = D;", names(i), tags(j)));
    end
end
clearvars -except *videoTimes names tags;

for i = 1:length(names)
    for j = 1:2
        eval(sprintf("load %s%s.mat;", names(i), tags(j)));
        eval(sprintf("temp = isnat(%s%s_time);", names(i), tags(j)));
        idx = find(temp == 0, 1, 'last');
        eval(sprintf("%s%s_time = %s%s_time(1:idx);", names(i), tags(j), names(i), tags(j)));
        eval(sprintf("%s%s_time = unique(%s%s_time);", names(i), tags(j), names(i), tags(j)));
        clearvars -except *videoTimes names tags *_time i j;
    end
end

for i = 1:length(names)
    for j = 1:2
        eval(sprintf("temp = interp1(%s%s_time, 1:length(%s%s_time), %s%s_videoTimes, 'nearest');", ...
            names(i), tags(j), names(i), tags(j), names(i), tags(j)));
        middle = round(length(temp)/2);
        temp(isnan(temp(1:middle))) = 1;
        eval(sprintf("temp(isnan(temp)) = length(%s%s_time);", ...
            names(i), tags(j)));
        eval(sprintf("idx_%s%s = temp;", names(i), tags(j)));
    end
end
clear temp;

names2 = ["Twitchell1", "Jensen2", "Redd3", "Cheng8", "Richmond9", "Harrison11", "Angerbauer12"];
for i = 1:length(names2)
    if i == 2
        % Skipping Jensen for now as I don't have all of his data
    else
        for j = 1:2
            eval(sprintf("load %s%sLOS;", names2(i), tags(j)));
            eval(sprintf("%s%sLOS(1,1) = 1;", names2(i), tags(j)));
            eval(sprintf("temp = %s%sLOS;", names2(i), tags(j)));
            for k = 2:length(temp)
                eval(sprintf("temp(1,k) = idx_%s%s(temp(1,k));", names(i), tags(j)));
            end
            eval(sprintf("LOS_%s%s = temp;", names2(i), tags(j)));
            eval(sprintf("array = ones(1,length(%s%s_time));", names(i), tags(j)));
            for k = 1:2:length(temp)-1
                array(temp(1,k):temp(1,k+1)) = temp(2,k);
            end
            eval(sprintf("ArrayLOS_%s%s = array;", names2(i), tags(j)));
        end
    end
end


% save LOS.mat ArrayLOS*;

toc;