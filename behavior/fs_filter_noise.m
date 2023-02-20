function [fs_filtered] = fs_filter_noise(fs)
fs(isnan(fs)) = 0;
fs_filtered = lowpass(fs, 0.05,1000);
end