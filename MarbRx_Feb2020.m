% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function used to gather data for the PLS High Traffic project
% This connects to a radio, and then gathers data continuously between two
% times. The data and time stamps are stored and then saved at the end.
% 
% Made Feb 10, 2020
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear; close all; clc;

%%%%% USER INPUT %%%%%
startTime = "16-Jan-2020 17:10:01";
endTime = "16-Jan-2020 17:11:31";
arrayName = '[Lastname][RadioNumber] eg. Norman9';
arraySize = 100e3; % Enough for four mins + extra for safety reasons
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
while string(datetime + seconds(1)) < startTime
end
    % Data Collection
disp('Started at ' + string(datetime));
count = 1;
while datetime < endTime % Collects data and stores the time of each frame
    dataArray(count,:) = rx();
    timeArray(count) = datetime;
    count = count + 1;
end
    % Variable assignment and saving
disp('Finished collecting data at, ' + string(datetime)' + ', now saving the files.');

dataName = string(arrayName) + "_data";
timeName = string(arrayName) + "_time";
eval(sprintf("%s = dataArray;",dataName));
eval(sprintf("%s = timeArray;",timeName));

save(arrayName + '.mat',dataName, timeName); % Saves data and time array with custom name into a single variable
