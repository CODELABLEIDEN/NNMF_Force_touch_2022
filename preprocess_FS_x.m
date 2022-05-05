function [res] = preprocess_FS_x(EEG,p, o)
%% Preprocess force sensor data and prepare bendsensor data
%
% **Usage:** [filtered, BS, base] = preprocess_FS(EEG)
%
% Input(s):
%   - EEG = EEG struct from one participant
%   - bandpass_upper_range = int maximum frequency range used in the bandpass filter
%
% Output(s):
%   - filtered = preprocessed forcesensor data
%   - BS = preprocessed BS dataset
%   - base = value when there is no force on the sensor
%
% Requires:
%   - getcleanedbsdata.m
%   - remove_inactive_bs.m
%
% Author: R.M.D. Kock

%% get force sensor data
data = EEG.Aligned.BS.Data(:,2);
% add some padding
data = [NaN; data; NaN];
%% remove noise values
% base is the value when there is no force on the sensor
% In the raw dataset base is between -1 and -0.8
% set all the values between this range to -1.
base = -1;
for i=1:size(data,1)
    if data(i,1)< -0.8 && data(i+1,1)< -0.8 && data(i-1,1)< -0.8
        data(i,1) = base;
    end
end
%% Remove nans 
% OJO
missing = isnan(data);
EEG.data = EEG.data(~missing);
% remove the padding
data = rmmissing(data);
%% find peaks that are not noise

[pulse_width,initcros,finalcros] = pulsewidth(data);
start_idx = initcros(pulse_width>5);
end_idx = finalcros(pulse_width>5);
filtered = zeros(length(data),1);
indices = [];
start_indices = [];
end_indices = [];
mid_indices = [];
for j=1:size(start_idx)
    ii = round(start_idx(j)):round(end_idx(j));
    indices = [indices, ii];
    start_indices = [start_indices, round(start_idx(j))];
    end_indices = [end_indices, round(end_idx(j))];
    mid_indices = [mid_indices, round((end_idx(j)+start_idx(j))/2)];
end
%% get filtered data
% instead of a matrix of zeroes get a matrix with default base value
filtered = filtered + base;
% only select the signals in indices
filtered(indices) = data(indices);
%%
res{1} = p;
res{2} = filtered;
res{3} = start_indices;
res{4} = mid_indices;
res{5} = end_indices;
end