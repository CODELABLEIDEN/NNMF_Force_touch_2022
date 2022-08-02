function [elecs,selection] = right_hem_elecs(EEG, plot)
%% Select the left hemisphere possible sensorimotor area electrodes
%
% **Usage:** [elecs,selection] = right_hem_elecs(EEG, plot)
%
%  Input(s):
%   - EEG = EEG struct
%   - plot logical = plot the selected electrodes
%
%  Output(s):
%   - elecs = Numbers for selected electrodes
%   - selection = logical array of number of electrodes
%
% Author: R.M.D. Kock
% 

elecs = 1:64;

Y = round([EEG.Orignalchanlocs.Y],4);
sel_right = Y>=0;

X = round([EEG.Orignalchanlocs.X],4);
sel_motor = X<0.8 & X>-0.8;

Z = round([EEG.Orignalchanlocs.Z],4);
sel_top = Z>-0.3;

selection = sel_motor & sel_right & sel_top;

if plot
    figure; topoplot(selection, EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')
end

elecs = elecs(selection);
end