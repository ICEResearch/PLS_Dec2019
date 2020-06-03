% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function used to gather data for the PLS High Traffic project
% This connects to a radio, and then gathers data continuously between two
% times. The data and time stamps are stored and then saved at the end.
% 
% Made Feb 10, 2020
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear; close all; clc;

%%%%% USER INPUT %%%%%
startTime = "03-Jun-2020 13:30:00";  % Remember to include the appropriate time offset
endTime = "03-Jun-2020 13:34:00";  
arrayName = 'LastnameRadionumber_noTraffic'; % e.g., 'Jensen8'
highTraffic = false; % all lower case - true / false
%%%%%%%%%%%%%%%%%%%%%%
% if highTraffic == true
%     arrayName = append(arrayName,'_traffic');
% else
%     arrayName = append(arrayName,'_empty');
% end

arraySize = 100e3; % Enough for four mins + extra for safety reasons

dataArray = zeros(arraySize, 2048); 
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

eval(sprintf("save %s.mat %s %s -v7.3;", arrayName, dataName, timeName)); % Saves data and time array with custom name into a single variable

%%
% NOTE - If you have an error while saving, adjust the variable names to
% match the ones you used and run the following lines IN THE COMMAND
% WINDOW:
%
% save Jensen8_data.mat Jensen8_data -v7.3;
% save Jensen8_time.mat Jensen8_time -v7.3;
%%%%%%%%%%%%%%