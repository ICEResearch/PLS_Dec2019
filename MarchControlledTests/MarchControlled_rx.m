% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function used to gather data for some controlled experiments with LOS
% This connects to a radio, and then gathers data continuously between two
% times. The data and time stamps are stored and then saved at the end.
% 
% Made March 23, 2020
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear; close all; clc;

%%%%% USER INPUT %%%%%
startTime = "23-Mar-2020 17:00:00";  % Remember to include the appropriate time offset
endTime = "23-Mar-2020 17:04:00";  
arrayName = 'LastnameRadionumber'; % e.g., 'Jensen8'
%%%%%%%%%%%%%%%%%%%%%%

arraySize = 60e3; % Enough for four mins + extra for safety reasons

dataArray = zeros(arraySize, 2048); % 6400 ~= 1 minute
timeArray = NaT(1, arraySize);
capacity = zeros(1,arraySize);

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

Nfft = 128;
snr = 10;
figure();

    % Wait to start until the correct time
while string(datetime + seconds(1)) < startTime
end
    % Data Collection
disp('Started at ' + string(datetime));
count = 0;
while datetime <= endTime % Collects data and stores the time of each frame
    count = count + 1;
    % Collect radio and time data
    radioFrame = rx();
    timeArray(count) = datetime;
    dataArray(count,:) = radioFrame;
    % Base processing (pwelch and fftshift)
    pwelchOutput = pwelch(radioFrame,boxcar(Nfft),0,Nfft,'twosided');
    shiftedOutput = fftshift(pwelchOutput);
    signalCarriers = shiftedOutput(2:2:Nfft);
    % Capacity calculations (only using signal carriers)
    capacity = zeros(1,frames);
    for i = 1:Nfft/2
        capacity(count) = capacity(count) + (1.0/2.0)*log2(1 + signalCarriers(i) * snr);
    end
    plot(capacity);
    ylim([0 100]);
    drawnow;
end
    % Variable assignment and saving
disp('Finished collecting data at, ' + string(datetime)' + ', now saving the files.');

dataArray = dataArray(1:count,:);
timeArray = timeArray(1:count);
capacity = capacity(1:count);

dataName = string(arrayName) + "_data";
timeName = string(arrayName) + "_time";
eval(sprintf("%s = dataArray;",dataName));
eval(sprintf("%s = timeArray;",timeName));

eval(sprintf("save %s.mat %s %s %s -v7.3;", arrayName, dataName, timeName, capacity)); % Saves data and time array with custom name into a single variable

%%
% NOTE - If you have an error while saving, adjust the variable names to
% match the ones you used and run the following lines IN THE COMMAND
% WINDOW:
%
% save Jensen8_data.mat Jensen8_data -v7.3;
% save Jensen8_time.mat Jensen8_time -v7.3;
%%%%%%%%%%%%%%