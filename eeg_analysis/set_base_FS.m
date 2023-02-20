function [data] = set_base_FS(data)
%% set NANs to no force
missing = isnan(data);
data(missing) = -1;
% EEG.data = EEG.data(~missing);
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
% remove the padding
data = rmmissing(data);
end