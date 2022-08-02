%% path to raw data
processed_data_path = '/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG';
%%
addpath(genpath('/home/ruchella/variable_activation'))
addpath(genpath('/home/ruchella/imports'))
addpath(genpath('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022'))
addpath(genpath(processed_data_path), '-end')
%%
EEG = pop_loadset('/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG/DS01/13_09_01_03_19.set');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% generate erp data around forcesensor
unique_name = 'fs4s'; aligned = 1; erp_data = 1; bandpass_upper = 3;
gen_checkpoints_FS(unique_name,bandpass_upper, aligned, erp_data, 'epoch_window_ms', [-2000 2000], 'epoch_window_baseline', [-2000 -1500]);
%%
unique_name = 'erspfs3hz1s'; aligned = 1; erp_data = 0; bandpass_upper = 45;
gen_checkpoints_FS(unique_name,bandpass_upper, aligned, erp_data, 'epoch_window_ms', [-2000 2000], 'epoch_window_baseline', [-2000 -1500]);
%% load all split files erp
load_str = 'fs3hz1s';
data_name = 'A';
fs1s = load_checkpoints_fs('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs3hz1s3',load_str,data_name, 'split_trials', 1, 'time_range', 2500, 'index', 4);
%%
load_str = 'fs4s3';
data_name = 'A';
fs1s = load_checkpoints_fs('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs4s3',load_str,data_name, 'split_trials', 1, 'time_range', 2500, 'index', 4);
%%
load_str = 'erspfs3hz1s';
data_name = 'A';
fsersp = load_checkpoints_fs('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_erspfs3hz1s45',load_str,data_name, 'split_trials', 0, 'time_range', 200, 'index', 4);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% perform erp nmf %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load FS erp data
load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022//erp_fs4s3/fs_loaded.mat')
%% nnmf erp
erp_ersp_data = fs1s(11,4);
[basis_all,loadings_all,train_err_all,test_err_all] = fs_nnmf(erp_ersp_data,EEG);
%% run nnmf
[basis, loadings, best_k_overall,test_err_reshap,train_err_reshap] = run_nnmf_n_cluster(fs1s(:,7));
%%
n_participants = 16;
electrodes = 64;
erp_ersp_data = fs1s(:,7);
best_k_overall = 5;
for pp = 1:n_participants
    for chan=1:electrodes
        non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,:,:)), 'shift_local');
        [W, H] = perform_nnmf(non_neg_data, best_k_overall, 'repetitions', 1, 'create_seed', 0);
        basis{chan,pp} = zscore(W);
        loadings{chan,pp} = zscore(H);
    end
end
%% kmeans clustering erp
best_k_overall = 5;
chan = 16;
% plot clusters FS
[cluster_res] = k_means_cluser_nmf(basis,best_k_overall, chan);
%% plot results
% plot electrode location
% plot_elec_location(chan, EEG.chanlocs)
%
time_range = [-2000:1999];
run_n =3;
%%
% plot clusters FS
plot_clusters(basis,cluster_res,best_k_overall,best_k_overall,chan,time_range, 'start_row',1, 'end_row', 5)
savefig(sprintf('fs_k%d_r%d_e%d_all_clus',best_k_overall,run_n,chan))
% plot_clusters(basis(8:68,:)',cluster_res,kclus,best_k_overall,chan,time_range, 'start_row',6, 'end_row', 10)
%% plot 1 pp erp FS
% plot nmf results all participants
chan = 16;
% for pp=1:size(basis,2)
for pp=1:5
    [trial_times] = trial_idx(loadings,fs1s,best_k_overall,time_range,chan,pp,'percentage', 100);
    
%     plot_FS_nmf_per_p(basis,loadings,fs1s,best_k_overall,time_range,chan,pp);
%     plot_sel_trials(basis,loadings,fs1s,best_k_overall,time_range,chan,pp, 'percentage', 100, 'order', 'descend');
    %     savefig(sprintf('fs_k%d_r%d_e%d_p%d',kclus,run_n,chan,pp))
    
    % check if selected trials vary across ranks
%         figure; tiledlayout(best_k_overall,1); 
%         for r=1:best_k_overall; nexttile; 
%             plot(trial_times{r,2});
%         end
%     figure; imagesc(cell2mat(trial_times(:,1)));
%     title(sprintf('Subject %d',pp))
%     yticks([1:best_k_overall])
%     ylabel('Rank')
%     xlabel('Trial')
    
    
%     figure; imagesc(cell2mat(force_r)')
%     hcb = colorbar;
%     title(sprintf('Subject %d',pp))
%     yticks([1:best_k_overall])
%     ylabel('Rank')
%     xlabel('Trial')
%     title(hcb, 'Force')
    
    
    % explore effect of movement type
%     figure;
%     tiledlayout(best_k_overall,1)
%     for r=1:best_k_overall
%         nexttile
%         ep_blind_bs = getepocheddata(nanzscore(fs1s{pp,14}),[trial_times{r,3}],[-2000 1999]);
%         plot(time_range, ep_blind_bs')
%         title(sprintf('rank %d',r))
%     end
    
    % check effect of jid
%     [jid, xi,si] = plot_jid_FS(trial_times,best_k_overall);
    plot_behavior_no_sel(loadings,fs1s,best_k_overall,trial_times,chan,pp)
end
%%
[trials_diff] = plot_FS_nmf_per_p(basis,loadings,fs1s,best_k_overall,time_range,chan,pp);
%%
plot_nmf_all_participants(basis,time_range,chan, 'erp_data', cat(3,fs1s{:,2}))
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% perform ersp nmf %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load ersp
load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_erspfs3hz1s45/fsersp.mat');
[ersp, selected,participants_fs] = prepare_ersp_data_fs(fsersp);
%% ersp nmf
[basis_alpha, loadings_alpha, best_k_alpha] = run_nnmf_n_cluster(squeeze(ersp(:,:,1)), 'erp_data', 0);
[basis_beta, loadings_beta, best_k_beta] = run_nnmf_n_cluster(squeeze(ersp(:,:,2)), 'erp_data', 0);
[basis_gamma, loadings_gamma, best_k_gamma] = run_nnmf_n_cluster(squeeze(ersp(:,:,3)), 'erp_data', 0);
%% kmeans clustering ersp
best_k_overall = 5; chan = 1;
[clusters_alpha] = k_means_cluser_nmf(basis_alpha,best_k_overall, chan);
[clusters_beta] = k_means_cluser_nmf(basis_beta,best_k_overall, chan);
[clusters_gamma] = k_means_cluser_nmf(basis_gamma,best_k_overall, chan);
%%
time_range = [-100:99];
plot_clusters(basis_alpha,clusters_alpha,best_k_overall,best_k_alpha,chan,time_range)
plot_clusters(basis_beta,clusters_beta,best_k_overall,best_k_beta,chan,time_range)
plot_clusters(basis_gamma,clusters_gamma,best_k_overall,best_k_gamma,chan,time_range)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot ersp average around fs
[ersp_all] = prepare_ersp_data(fsersp);
figure;
imagesc(fsersp{1,4},[],squeeze(mean(ersp_all(16,:,:,:),4)), [-2 2]);
colormap('jet');
xline(0, '--', 'LineWidth', 2);
ylabel('Frequency')
xlabel('Mid point forcesensor tap')
title('Average ersp across all participants')
box off;
colorbar;
set(gca, 'fontSize',15)
%% plot 1 pp tap
pp = 1;
chan = 16;
plot_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% JIDs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
tiledlayout(1,k)
for r=1:k
    si = cell2mat(cellfun(@(x) find(trial_times{r,3} == x), num2cell(sort(trial_times{r,2})), 'UniformOutput', false));
    
    si_tmp = [];
    si_tmp(1,:) = si;
    si_tmp(2,:) = si+1;
    si_tmp(3,:) = si+2;
    si_tmp = si_tmp(:);
    si_sel = x(si_tmp(si_tmp<=max(si)));
    [jid, bin_edges,xi] = taps2JID(si_sel);
    nexttile
    imagesc(xi(:,1), xi(:,2),jid, [0,4])
    set(gca, 'YDir', 'normal')
    
end
colorbar