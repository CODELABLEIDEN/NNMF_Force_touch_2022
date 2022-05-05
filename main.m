%% load the files
% path to raw data
processed_data_path = '/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG';
%%
addpath(genpath('/home/ruchella/variable_activation'))
addpath(genpath('/home/ruchella/imports'))
addpath(genpath('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022'))
addpath(genpath(processed_data_path), '-end')
%%
EEG = pop_loadset('/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG/DS01/13_09_01_03_19.set');
%% generate erp data
unique_name = 'fs3hz1s'; aligned = 1; erp_data = 1; bandpass_upper = 3;
gen_checkpoints_FS(unique_name,bandpass_upper, aligned, erp_data, 'epoch_window_ms', [-2000 2000], 'epoch_window_baseline', [-2000 -1500]);
%%
unique_name = 'erspfs3hz1s'; aligned = 1; erp_data = 0; bandpass_upper = 45;
gen_checkpoints_FS(unique_name,bandpass_upper, aligned, erp_data, 'epoch_window_ms', [-2000 2000], 'epoch_window_baseline', [-2000 -1500]);
%% load all split files erp
load_str = 'fs3hz1s';
data_name = 'A';
fs1s = load_checkpoints_fs('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs3hz1s3',load_str,data_name, 'split_trials', 1, 'time_range', 2500, 'index', 4);
%%
load_str = 'erspfs3hz1s';
data_name = 'A';
fsersp = load_checkpoints_fs('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_erspfs3hz1s45',load_str,data_name, 'split_trials', 0, 'time_range', 200, 'index', 4);
%%
% load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs3hz3/fs.mat')
load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs3hz1s3/fs1s.mat')
%% nnmf
channels = 64;
time_range = 2500;
k = 5;
basis = cell(size(fs1s,1),channels);
loadings = cell(size(fs1s,1),channels);
for pp =1:size(fs1s,1)
    tmp_pp = fs1s{pp,7};
    for chan=1:channels
        tmp_pp_chan = squeeze(tmp_pp(chan,:,:));
        local_min = abs(ceil(min(tmp_pp_chan,[], 'all')));
        [H,W] = nnmf(tmp_pp_chan+local_min,k);
        basis{pp,chan} = zscore(H);
        loadings{pp, chan} = zscore(W);
    end
end
%%
figure;
tiledlayout(size(fs1s,1)/4, 4)
for pp =1:size(fs1s,1)
    nexttile;
    plot([-1500:999], basis{pp,16})
end
%% hierarchical clustering manual
% zz = squeeze(z(:,1,:))';
% Y = pdist(z);
Y = pdist(z,@(Xi,Xj) dtwdist(Xi,Xj));
Z = linkage(Y);
% dendrogram(Z)

maxclust = 10;
T = cluster(Z, 'maxclust', maxclust, 'Criterion', 'distance');
% T = cluster(Z, 'cutoff', 1, 'Criterion', 'distance');
maxclust = length(unique(T));
%% hierarchical clustering
T = clusterdata(z,15);
figure;
tiledlayout(5,1)
for i=1:5
    nexttile
    for clus =1:length(T)
        if T(clus) == i
            hold on
            plot([-1500:999],squeeze(z(clus,:)))
            xline(0)
        end
    end
end
%% kmeans clustering
kclus = 5;
chan = 16;
idx = kmeans(z, kclus);
z = cat(2,basis{:,chan})';
participants = repelem([1:size(basis,1)],5);
%%
figure;
tiledlayout(kclus,3)
for i=1:kclus
    nexttile([1,2])
    participants_in_clus = [];
    for clus =1:length(idx)
        if idx(clus) == i
            hold on
            plot([-2000:1999],squeeze(z(clus,:)))
            xline(0)
            participants_in_clus = [participants_in_clus participants(clus)];
        end
    end
    xlabel('Latency from event (ms)')
    ylabel('Normalized')
    title(sprintf('Cluster %d',i))
    nexttile
    histogram(participants_in_clus, length(participants_in_clus), 'BinMethod', 'integer')
    ylim([0 2])
    xlim([0,17])
    xlabel('Participant')
    ylabel('Frequency')
    box off;
end
sgtitle(sprintf('Channel : %d', chan))
%% get difference between start/end time
f = @preprocess_FS_x;
[files_grouped,A,parfor_time] = call_f_all_p_parallel(processed_data_path,f, 'start_idx', 1, 'end_idx',30, 'all', 0);

idx = cellfun(@isempty, A);
AA = A(~idx);
xx = cat(1,AA{:});
% trial_diffs = xx{1,5}-xx{1,3};
%%
pp=3;
chan = 16;
figure;
tiledlayout(k,3+1)
% nexttile
% set(gca, 'visible', 'off')
% nexttile
% plot([-2000:1999],fs1s{pp,2}(chan,:))
% box off;
% nexttile
% set(gca, 'visible', 'off')
for r=1:k
    %plot 1
    nexttile
    plot([-1999:2000], basis{pp,chan}(:,r))
    xlabel('Latency from event (ms)')
    box off;
    [~,idx] = sort(loadings{pp,chan}(r,:));
    xline(0)
    %plot 2
    nexttile
    imagesc([-1999:2000],[],zscore(squeeze(fs1s{pp,7}(chan,:,idx))',[],2));
    ylabel('Trials')
    xlabel('Latency from event (ms)')
    box off;
    colorbar
    xline(0)
    title(sprintf('Rank: %d',r))
    %plot 3
    nexttile
    trials_diffs = fs1s{pp,10}-fs1s{pp,8};
    trials_diffs(fs1s{pp,12}) = NaN;
    trials_diffs = rmmissing(trials_diffs);
    imagesc(trials_diffs(idx)')
    title('Duration per trial')
    ylabel('Trials')
    set(gca, 'XTick', [])
    colorbar
    box off;
    % plot erp
    nexttile
    if r == ceil(k/2)
        plot([-2000:1999],fs1s{pp,2}(chan,:))
    else
        set(gca, 'visible', 'off')
    end
    box off;
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))
%%
figure;
selection = zeros(1,64);
selection(chan) = 1;
topoplot(selection, EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')