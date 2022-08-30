%% prepare data
fs = EEG.Aligned.BS.Data(:,2);
fs(isnan(fs)) = -0.9;
fs_noise = fs(fs < -0.8);
%%
Fs = 1000;
L = length(fs_noise);
Y = fft(fs_noise);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
P1(1) = 0;

plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
%%
fc = 0.5;
Wn = (2/Fs)*fc;
%%
b = fir1(2,Wn,'high');
fs_filtered = filter(b,1,fs);
%%
fs_filtered = lowpass(fs, 0.05,1000);
%%
figure; 
plot(fs)
hold on
plot(fs_filtered)