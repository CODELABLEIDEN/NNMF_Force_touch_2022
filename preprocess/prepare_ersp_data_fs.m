function [ersp, selected,participants] = prepare_ersp_data_fs(load_data)
%% Creates a placeholder cell with the datasets of all participants for plotting of results
%
% **Usage:** [erp_data, ams, nams] = preprocess_erp_data(erp_data, paired, min_num_trials)
%
% Input(s):
%   - load_data = cell placeholder cell with the data of the participants
%
% Output(s):
%   - ersp = ersp data formatted w
%   - selected = selected participants
%   - participants = participants names
%

arguments
    load_data cell;
end

time_size = size(load_data{1,2},2);
channels = 64;
freq_size = 40;

selected = load_data([load_data{:,3}]>0,:);
num_participants = size(selected,1)/channels;
reshaped_load_data = reshape(selected(:,7), [channels, num_participants]);
participants = reshape(selected(:,1), [channels, num_participants]);
participants = participants(1,:);
beta_band = [12:30];
alpha_band = [8:11];
gamma_band = [31:40];
% ersp = zeros(channels, freq_size, time_size, num_participants);
for band=1:3
    if band == 1
        % alpha band
        freqs = [8:11];
    elseif band == 2
        % beta band
        freqs = [12:30];
    else
        % gamma band
        freqs = [31:40];
    end
    for pp=1:num_participants
        for chan=1:channels
            x = reshaped_load_data{chan, pp};
            z = squeeze(mean(x(freqs,:,:),1));
            % concat each cell of timexfreq for each participant along 3rd dimension
            %         tmp = cat(4, reshaped_load_data{chan, :});
            ersp{pp,chan, band} = z;
        end
    end
end
end