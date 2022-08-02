function [files_grouped,A,parfor_time] = call_f_all_p_parallel_f(path,f, options)
%% General function that calls a function for all the participants in parallel
%
% **Usage:** [files_grouped,A,parfor_time] = call_f_all_p_parallel(path,f)
%   - call_f_all_p_parallel(..., 'cycles', [1 0.7])
%   - call_f_all_p_parallel(..., 'erp_data', 1)
%
%  Input(s):
%   - path = path to raw data
%   - f = function handle of function to be called
%   - options.start_idx **optional** double = start index of the loop
%   - options.end_idx **optional** double = end index of the loop
%   - options.epoch_window_ms **optional** cell (1,2) = epoch window in ms (e.g. [-1000 500])
%   - options.epoch_window_baseline **optional** cell (1,2) = baseline window in MS (e.g. [-1000 -800])
%   - options.erp_data = load erp data (1) or ersp data (0)
%   - options.cycles **optional** double = [1 0.5] 0 for FFT or array for wavelet transform (See newtimef cycles)
%   - options.bandpass_upper **optional** = upper range bandpass filter
%   - options.bandpass_lower **optional** = lower range bandpass filter
%   - options.aligned  **optional** logical = Load aligned (1) or unaligned (0) data
%   - option.delay  **optional** = Known delay for participant (used for alignment correction, assumed aligned is 0)
%
%  Output(s):
%   - files_grouped = names of files to read
%   - A = cell with generated data
%   - parfor_time = duration of function
%
% Requires:
%   - gen_set_file_names
%   - select_from_status_1.m
%   - select_from_status_2.m

% Author: R.M.D. Kock

arguments
    path char;
    f ; % function_handle or cell array of function handles
    options.start_idx (1,1) double = 1; % inclusive
    options.end_idx (1,1) double = 0; % inclusive
    options.epoch_window_ms (1,2) double = [-2000 2000];
    options.epoch_window_baseline (1,2) double = [-2000 -1500];
    options.erp_data logical = 1;
    options.cycles = [1 0.3];
    options.bandpass_upper = 45;
    options.bandpass_lower = 0.5;
    options.aligned_taps logical = 1;
    options.delay = 0;
    options.all = 1;
end
if options.all
    [files_grouped,folder] = gen_set_file_names(path,options.start_idx,options.end_idx);
else
    [files_grouped,folder] = gen_set_file_names(path,options.start_idx,options.end_idx, 'all', 0);
end
%%
A = {};
tic
for i=1:length(files_grouped)
    % file selection
    all_set_files = load(sprintf('%s/status_2.mat',folder{i}));
    all_set_files = all_set_files.all_set_files;
    eeg_name = load(sprintf('%s/status.mat',folder{i}));
    eeg_name = eeg_name.eeg_name;
    % select participants with EEG, Phone data. If curfew participants only select the first file
    [selected_1] = select_from_status_1(eeg_name);
    % add the .set behind the processed filename to get the file name
    selected_1 = cellfun(@(s) strcat(s, '.set'),selected_1,'UniformOutput',false);
    % select participants where there is BS data and alignment were successful
    %     [selected_2] = select_from_status_2(all_set_files);
    % select participants where all above criteria are met
    files_grouped{i} =  selected_1;
    num_files = length(files_grouped{i});
    
    if num_files > 1
        all_eeg_structs = [];
        for j=1:num_files
            EEG = pop_loadset(sprintf('%s/%s',folder{i}, files_grouped{i}{j}));
            if select_from_EEG_struct_3(EEG) && (size(EEG.Aligned.BS.Data,2) == 2)
                all_eeg_structs = [all_eeg_structs EEG];
            end
        end
        % check attys and length issue - make sure forcesensor data present
        A{i} = f(all_eeg_structs, sprintf('%s/%s',folder{i}, files_grouped{i}{1}), options);  
    elseif num_files
        EEG = pop_loadset(sprintf('%s/%s',folder{i}, files_grouped{i}{1}));
        % check attys and length issue - make sure forcesensor data present
        if mod(size(EEG.data,2), EEG.pnts) == 0 && ~(EEG.Attys) && (size(EEG.Aligned.BS.Data,2) == 2)
            A{i} = f(EEG, sprintf('%s/%s',folder{i}, files_grouped{i}{1}), options);
        end
    end
end
parfor_time = toc;
end