function [elecs,selection,h] = electrode_selection(EEG, plot,sensorimotor)
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
X = round([EEG.Orignalchanlocs.X],4);
Z = round([EEG.Orignalchanlocs.Z],4);

if sensorimotor
    sel_right = Y>=0;
    sel_motor = X<0.8 & X>-0.8;
    sel_top = Z>-0.3;
    
    selection = sel_motor & sel_top & sel_right;
else
    % 3 rings;
%     sel_motor = X<1 & X>-1;
%     sel_top = Z>0.1;
    % 2 rings
    sel_motor = X<0.8 & X>-0.8;
    sel_top = Z>0.4;
    
    selection = sel_motor & sel_top;
end

if plot
    h = figure; topoplot(selection, EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off', 'colormap', 'jet')
end

elecs = elecs(selection);
end