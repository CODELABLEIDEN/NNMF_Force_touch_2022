function [data] = process_EEG_fs(EEG, participant, options)
%% Preprocess EEG data and generate ERP or ERSP
%
% **Usage:** [data] = process_EEG(EEG, participant)
%        - process_EEG(..., 'aligned', 1)
%        - process_EEG(..., 'epoch_window_ms', [-2000 2000])
%
%  Input(s):
%   - EEG = EEG struct
%   - participant = string with participant ID/name
%   - options = struct with
%           - options.epoch_window_ms **optional** cell (1,2) = epoch window in ms (e.g. [-1000 500])
%           - options.epoch_window_baseline **optional** cell (1,2) = baseline window in MS (e.g. [-1000 -800])
%           - options.erp_data = load erp data (1) or ersp data (0)
%           - options.cycles **optional** double = [1 0.5] 0 for FFT or array for wavelet transform (See newtimef cycles)
%           - options.bandpass_upper **optional** = upper range bandpass filter
%           - options.bandpass_lower **optional** = lower range bandpass filter
%           - options.aligned  **optional** logical = Load aligned (1) or unaligned (0) data
%           - option.delay  **optional** = Known delay for participant (used for alignment correction, assumed aligned is 0)
%
%  Output(s):
%   - data = cell with generated erp or ersp
%       erp: data{1} = Participant;
%            data{2} = ERP based on trimmedmean leaving out top and bottom 20%
%            data{3} = ERP mean
%            data{4} = Epoched data channel x time x trial;
%            data{5} = Delay based on previous alignment model;
%       ersp: data{channel,1} = Participant;
%             data{channel,2} = ERSP powers;
%             data{channel,3} = Number of trials;
%             data{channel,4} = Real times;
%             data{channel,5} = Frequencies;
%             data{channel,6} = Channel number;
%             data{channel,7} = Time-frequency power for each trial;
%
% Author: R.M.D. Kock

data = {};
delay_model = 0;
EEG = gettechnicallycleanEEG(EEG,options.bandpass_upper,options.bandpass_lower);
[filtered, base,start_indices,mid_indices,end_indices] = preprocess_FS(EEG);
[EEG] = add_events(EEG,start_indices,length(start_indices),'FS_start');
[EEG] = add_events(EEG,mid_indices,length(mid_indices),'FS_mid');
% epoch around aligned taps
% if options.aligned_taps && ~(options.delay)
%     num_taps = size(find(EEG.Aligned.BS_to_tap.Phone == 1),2);
%     [EEG] = add_events(EEG,[find(EEG.Aligned.BS_to_tap.Phone == 1)],num_taps,'pt');
% elseif options.aligned_taps && options.delay
%     for ff = 1:size(EEG.Aligned.Phone.Blind,2)
%         EEG.Aligned.Phone.Model{1,ff} = EEG.Aligned.Phone.Blind{1,ff};
%         EEG.Aligned.Phone.Model{1,ff}(:,2) = EEG.Aligned.Phone.Model{1,ff}(:,2)+options.delay;
%     end
%     [Phone, ~, idx] = get_phone_data(EEG, 2);
%     num_taps = size(find(Phone == 1),2);
%     [EEG] = add_events(EEG,[find(Phone == 1)],num_taps,'pt');
% else
%     [Phone] = get_phone_data(EEG, 0);
%     num_taps = size(find(Phone == 1),2);
%     [EEG] = add_events(EEG,[find(Phone == 1)],num_taps,'pt');
%     [~, simple,delay_model] = decision_tree_alignment_edited(EEG, EEG.Aligned.BS_to_tap.BS, 1);
%     if ~simple
%         error('Selected a participant where model alignment wasnt successful')
%     end
% end
[EEG_epoched_start] = pop_epoch(EEG, {'FS_start'},options.epoch_window_ms/1000);
[EEG_epoched_mid] = pop_epoch(EEG, {'FS_mid'},options.epoch_window_ms/1000);
%% pre-process
% ERSP data baseline is removed during the fft analysis
% if taps are unaligned the true location of baseline is unknown so
% substract mean unstead
if options.erp_data && options.aligned_taps
    EEG_epoched_start = pop_rmbase(EEG_epoched_start, options.epoch_window_baseline);
    EEG_epoched_mid = pop_rmbase(EEG_epoched_mid, options.epoch_window_baseline);
    % elseif options.erp_data && ~options.aligned_taps
elseif ~options.aligned_taps
    avg_per_chan_n_trial = mean(EEG_epoched_start.data, 2);
    EEG_epoched_start.data = EEG_epoched_start.data - avg_per_chan_n_trial;
end
%% threshold EEG data
electrodes_to_reject = [1:62];
voltage_lower_threshold = -80; % In mV
voltage_upper_threshold = 80;
start_time = options.epoch_window_ms(1)/1000;
end_time = options.epoch_window_ms(2)/1000;
do_superpose = 0;
do_reject = 1;
try
    [EEG_epoched_start,idx_rej_trials_start] = pop_eegthresh(EEG_epoched_start, 1, electrodes_to_reject, voltage_lower_threshold, voltage_upper_threshold, start_time, end_time, do_superpose, do_reject);
    [EEG_epoched_mid, idx_rej_trials_mid] = pop_eegthresh(EEG_epoched_mid, 1, electrodes_to_reject, voltage_lower_threshold, voltage_upper_threshold, start_time, end_time, do_superpose, do_reject);
catch ME
    return
end
%% get BS data for validation
if options.delay
    BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
    ep_blind_bs = getepocheddata(zscore(BS),idx,[-3000 3000]);
end
%%
trials_start = size(EEG_epoched_start.epoch,2);
% trials_end = size(EEG_epoched_end.epoch,2);
% Only select participant if they have atleast 250 taps
if options.erp_data
    if (trials_start > 1)
        data{1} = participant;
        % ERP based on trimmedmean leaving out top and bottom 20%
        data{2} = trimmean(EEG_epoched_start.data(:,:,:),20,3);
        % erp
        data{3} = [mean(EEG_epoched_start.data(:,:,:),3,'omitnan')];
        data{4} = EEG_epoched_start.data;
        
        data{5} = trimmean(EEG_epoched_mid.data(:,:,:),20,3);
        data{6} = [mean(EEG_epoched_mid.data(:,:,:),3,'omitnan')];
        data{7} = EEG_epoched_mid.data;

        data{8} = start_indices;
        data{9} = mid_indices;
        data{10} = end_indices;
        data{11} = idx_rej_trials_start;
        data{12} = idx_rej_trials_mid;
    end
else
    data = num2cell(zeros(64,6));
    channels = [1:64];
    if (trials_start > 1)
        for chan_idx=1:length(channels)
            channel = channels(chan_idx);
            if options.aligned_taps
                [P,timesout,freqs, ~, PA] = pop_newtimef(EEG_epoched_mid, 1,  channel, options.epoch_window_ms, options.cycles, 'baseline', options.epoch_window_baseline, 'plotersp', 'off', 'plotphasesign', 'off', 'plotitc', 'off');
            else
                [P,timesout,freqs, ~, PA] = pop_newtimef(EEG_epoched_mid, 1,  channel, options.epoch_window_ms, options.cycles, 'plotersp', 'off', 'plotphasesign', 'off', 'plotitc', 'off');
            end
            data{channel,1} = participant;
            data{channel,2} = P;
            data{channel,3} = trials_start;
            data{channel,4} = timesout;
            data{channel,5} = freqs;
            data{channel,6} = channel;
            data{channel,7} = PA;
        end
    end
end
end