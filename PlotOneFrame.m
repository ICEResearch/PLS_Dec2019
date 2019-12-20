clear; close all
warning('off','all')
%% Radio Setup
plutoradiosetup();
rx = sdrrx('Pluto');
rx.RadioID = 'usb:0';
rx.CenterFrequency = 1250e6;
rx.BasebandSampleRate = 20e6;
rx.SamplesPerFrame = 32*64;
rx.OutputDataType = 'double';
rx.ShowAdvancedProperties = true;

frame = rx();
Nfft = 128;
pwelchoutput = pwelch(frame,boxcar(Nfft),0,Nfft,'twosided');
fftshifted = fftshift(pwelchoutput);
dbOutput = 10*log10(abs(fftshifted));
figure(1);
stem(-Nfft/2:Nfft/2-1,dbOutput);
grid on;
ax = gca;
ax.Children.BaseValue = -100;
ax.XLim = [-Nfft/2 Nfft/2];
ax.YLim = [-100 0];
xlabel('Carrier Indices');
ylabel('Signal Strength (dB)');


%%
for idx = 1:1000
frame = rx();
pwelchoutput = pwelch(frame,boxcar(Nfft),0,Nfft,'twosided');
fftshifted = fftshift(pwelchoutput);
ax.Children.YData = 10*log10(fftshifted);
drawnow;
end