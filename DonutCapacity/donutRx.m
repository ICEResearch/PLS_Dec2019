% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function used to gather data for the Capacity vs Distance project
% This connects to a radio, and then gathers data continuously between two
% times. The data and time stamps are stored and then saved at the end.
% 
% Made Jan 3, 2020
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear; close all; clc;

%%%%% USER INPUT %%%%%
startTime = "16-Jan-2020 17:10:01";
endTime = "16-Jan-2020 17:11:31";
arrayName = 'Jensen1_noamp';
arraySize = 30e3;
%%%%%%%%%%%%%%%%%%%%%%
dataArray = zeros(arraySize, 2048); % 6400 ~= 1 minute
timeArray = NaT(1, arraySize);

    % Radio setup 
plutoradiosetup();
rx = sdrrx('Pluto');
rx.RadioID = 'usb:0';
rx.CenterFrequency = 1250e6;
rx.BasebandSampleRate = 20e6;
rx.SamplesPerFrame = 32*64;
rx.OutputDataType = 'double';
rx.ShowAdvancedProperties = true;

    % Ignore data to account for buffer
for ignore = 1:10
    junk = rx();
end

    % Wait to start until the correct time
while string(datetime) < startTime
end

beep
pause(1)
beep
disp("Starting at " + string(datetime));

count = 1;
while datetime < endTime
    dataArray(count,:) = rx();
    timeArray(count) = datetime;
    count = count + 1;
end
disp('Finished collecting data, now saving the files.');
beep

dataName = string(arrayName) + "_data";
timeName = string(arrayName) + "_time";
eval(sprintf("%s = dataArray;",dataName));
eval(sprintf("%s = timeArray;",timeName));

save(dataName + '.mat',dataName); % Saves data array with custom name
save(timeName + '.mat',timeName); % Saves data array with custom name
