%% path to raw data
processed_data_path = '/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG';
%%
addpath(genpath('/home/ruchella/variable_activation'))
addpath(genpath('/home/ruchella/imports'))
addpath(genpath('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022'))
addpath(genpath(processed_data_path), '-end')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
EEG = pop_loadset('/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG/DS01/13_09_01_03_19.set');
%% generate erp data around forcesensor
unique_name = 'fs4s'; aligned = 1; erp_data = 1; bandpass_upper = 3;
gen_checkpoints_FS(unique_name,bandpass_upper, aligned, erp_data, 'epoch_window_ms', [-2000 2000], 'epoch_window_baseline', [-2000 -1500]);
%% load all split files erp
load_str = 'fs4s3';
data_name = 'A';
fs1s = load_checkpoints_fs('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs4s3',load_str,data_name, 'split_trials', 1, 'time_range', 2500, 'index', 4);
%% GLM one-sample ttest FS
paired = 0;
tf = 0;
tmp = cat(3, fs1s{:,2});
% one sample ttest for ERP around attributable movements
[LIMO_path_am] = run_t_tests_and_clustering(sprintf('fs_limo_%d',50), paired, tf, tmp(1:62,:,:), 'all_chan', 0);
%% plot GLM
load('one_sample_ttest_parameter_1_fs_limo_50.mat');
load('mask_fs_limo_50.mat');
paired = 0;
tf = 0;
[mean_vals, sig_t, sig_m] = prepare_data_for_plotting(one_sample, mask, paired, tf);
create_topoplot(mean_vals, EEG, 'jet' ,tf);
%%
create_topoplot(sig_t, EEG, 'cool' ,tf, [-10 10]);
%% LIMO percentage selection analysis 
for percentage= 10:10:100
    paired = 1;
    tf = 0;
    [erp_all] = prepare_erp_data_fs(fs1s,stable_loadings, stable_basis, 'percentage', percentage);
    [LIMO_path] = run_t_tests_and_clustering(sprintf('erp_percent_%d',percentage), paired, tf, erp_all, 'all_chans', 0);
end
%%
load(sprintf('one_sample_ttest_parameter_1_erp_percent_%d.mat',percentage));
load(sprintf('mask_erp_percent_%d.mat',percentage));
paired = 0;
tf = 0;
[mean_vals, sig_t, sig_m] = prepare_data_for_plotting(one_sample, mask, paired, tf);
create_topoplot(mean_vals, EEG, 'jet' ,tf);
%%
create_topoplot(sig_t, EEG, 'cool' ,tf, [-10 10]);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% perform erp nmf --> performed on ALICE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% nnmf erp crossvalidation
erp_ersp_data = fs1s(11,4);
[basis_all,loadings_all,train_err_all,test_err_all] = main_fs_nnmf_cv(erp_ersp_data,EEG);
%% run nnmf erp
save_path = '/home/ruchella/variable_activation/nnmf_pipeline';
erp_ersp_data = fs1s(11:12,4);
preparation =1;
[basis_all, loadings_all] = main_fs_nnmf(erp_ersp_data, EEG, preparation, 'repetitions', 10, 'save_path', save_path);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% load nnmf results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load basis and loadings
preparation = 1;
if preparation
    load('/home/ruchella/variable_activation/results/preparation/basis_all.mat')
    load('/home/ruchella/variable_activation/results/preparation/loadings_all.mat')
else
    load('/home/ruchella/variable_activation/results/consolidation/basis_all.mat')
    load('/home/ruchella/variable_activation/results/consolidation/loadings_all.mat')
end
%% perform stable nnmf
basis_all_pps = [];
basis = {};
loadings = {};
for pp=1:size(basis_all,2)
    [W, H] = stable_nnmf(basis_all,loadings_all, pp);
    basis{pp} = W;
    loadings{pp} = H;
    basis_all_pps = cat(2,basis_all_pps,W);
end
%% save stable basis and loadings
save('stable_basis.mat', 'basis')
save('stable_loadings.mat', 'loadings')
%% data dictionary
pps_in_cluster = zeros(size(basis_all_pps,2),1);
ranks_in_cluster = zeros(size(basis_all_pps,2),1);
count = 1;
for pp=1:size(stable_loadings,2)
    n_ranks = size(stable_loadings{pp},1);
    pps_in_cluster(count:count+n_ranks-1) = pp;
    ranks_in_cluster(count:count+n_ranks-1) = 1:n_ranks;
    count = count+n_ranks;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cluster results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% choose optimal k
% elbow method
nClusters=10; % pick/set number of clusters your going to use
totSum=zeros(nClusters-1,1);  % preallocate the result
for k=2:nClusters
    [~,~,sumd]=kmeans(basis_all_pps', k);
    totSum(k)=sum(sumd);
end
figure;
tiledlayout(2,1)
nexttile
plot(totSum)
xlim([2,10])
title('Elbow method')
nexttile
evaluation = evalclusters(basis_all_pps',"kmeans","silhouette","KList",1:10);
plot(evaluation)
title('Silhouette method')
%% silhoutte method
optimal_ks = zeros(1000,1);
optimal_ys = zeros(1000,size(basis_all_pps,2));
for rep=1:1000
    evaluation = evalclusters(basis_all_pps',"kmeans","silhouette","KList",1:10);
    optimal_ks(rep) = evaluation.OptimalK;
    optimal_ys(rep,:) = evaluation.OptimalY;
end

selected_k = mode(optimal_ks);
%% precomputed variables
preparation = 1;
if preparation
    load('/home/ruchella/variable_activation/results/preparation/stable_basis.mat')
    load('/home/ruchella/variable_activation/results/preparation/stable_loadings.mat')
    load('/home/ruchella/variable_activation/results/preparation/basis_all_pps.mat')
    load('/home/ruchella/variable_activation/results/preparation/cluster_res.mat')
    selected_k = 7;
else
    load('/home/ruchella/variable_activation/results/consolidation/stable_basis.mat')
    load('/home/ruchella/variable_activation/results/consolidation/stable_loadings.mat')
    selected_k = 2;
end
%% actually perform kmeans
cluster_res = {};
numreps = 1000;
ssqs = zeros(numreps,1);
for rep=1:numreps
    [cluster_res_tmp, C, sumd] = kmeans(basis_all_pps', selected_k);
    cluster_res{rep} = cluster_res_tmp;
    ssqs(rep) = sum(sumd);
end
[~,idx] = min(ssqs);
cluster_res = cluster_res{idx};
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% LIMO t-tests analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% prepare for LIMO t-tests
preparation = 1;
if preparation
    selected_time = 1500:2100;
    time_range = -500:100;
else
    selected_time = 2100:2500;
    time_range = 100:500;
end
%%
eeg_mods = {};
electrodes = 62;
for k=1:selected_k
    count = 1;
    for i=1:size(cluster_res,1)
        if cluster_res(i) == k
            pp = pps_in_cluster(i);
            r = ranks_in_cluster(i);
            W = stable_basis{pp};
            H = stable_loadings{pp};
            
            mod = cell(electrodes,1);
            erp_ersp_data = fs1s{pp,4};
            [sorted_H,idx] = sort(H(r,:), options.order);
            sorted_trials = erp_ersp_data(:,:,idx);
            n_trials = size(sorted_trials,3);
            sel_trials = ceil(n_trials*options.percentage/100);
            
            for chan=1:electrodes
                mod{chan} = limo_glm(squeeze(erp_ersp_data(chan,:,1:sel_trials))',full(sorted_H(1:sel_trials))', 0, 0, 0, 'IRLS', 'TIME');
            end
            eeg_mods{k,count} = mod;
            count = count+1;
        end
    end
end
%% LIMO level 2 analysis
tf = 0;
paired = 1;
for clus=1:size(eeg_mods,1)
    cluster1 = eeg_mods(clus,~cellfun('isempty', eeg_mods(clus,:)));
    select_betas = cellfun(@(x) cellfun(@(pp) pp.betas,x,'UniformOutput',false),cluster1,'UniformOutput',false);
    clus_size = length(cluster1);
    limo_dat = zeros(62,4000,clus_size);
    for pp=1:clus_size
        limo_dat(:,:,pp) = cell2mat(select_betas{pp});
    end
    [LIMO_path] = run_t_tests_and_clustering(sprintf('clus%d',clus), paired, tf, limo_dat, 'significance_threshold', 0.05, 'all_chans', 0);
end
%% plot limo level 2
make_movie = 1;
for clus=1:size(eeg_mods,1)
    [f, f2] = plot_clusters(basis_all_pps',cluster_res,selected_k,pps_in_cluster,time_range, 'start_row', clus, 'end_row', clus);
    close(f2)
    load(sprintf('one_sample_ttest_parameter_1_clus%d.mat',clus))
    load(sprintf('mask_clus%d.mat',clus))
    paired = 0;
    tf = 0;
    [mean_vals, sig_t] = prepare_data_for_plotting(one_sample, mask, paired, tf);
%     h = create_topoplot(sig_t, EEG, 'cool' ,tf, [-10 10]);
    
    if sum(mask, 'all') && make_movie
        number_timestamps = [1:10:1000 1000:3000 3000:10:4000];
        real_timestamps = number_timestamps-2000;
        mean_lims = [-0.5 0.5];
        t_lims = [-10 10];
        mean_plot_title = sprintf('Brain activity (%sV)',char(181));
        Figures_postanalysis_movie(EEG,mean_vals,sig_t, number_timestamps,real_timestamps, sprintf('cluster_prep_%d',clus),mean_plot_title,mean_lims, t_lims)
    end
    %     saveas(f, sprintf('cluster_prep_%d.svg',clus))
    %     saveas(h, sprintf('erp_limo_%d.svg',clus))
end
%% LIMO level 1 analysis
cluster_model = {};
for k=1:selected_k
    count = 1;
    for i=1:size(basis_all_pps,2)
        features = [];
        if cluster_res(i) == k
            pp = pps_in_cluster(i);
            r = ranks_in_cluster(i);
            
            erp_ersp_data = fs1s{pp,4};
            W = stable_basis{pp};
            H = stable_loadings{pp};
            [sorted_loads,idx] = sort(H(r,:), 'descend');
%             [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
%             [trial_times] = trial_idx(H,fs1s,size(W,2),time_range,chan,pp);
            [stats, features(:,1), features(:,2), features(:,3), features(:,4), features(:,5), features(:,6), features(:,7)] = behavior_stats(H,fs1s,r,pp);
            mod = reg_model(features,sorted_loads,'type', 0);
%             figure; 
%             tiledlayout(2,3)
%             nexttile
%             scatter(sorted_loads, features(:,1))
%             nexttile
%             scatter(sorted_loads, features(:,2))
%             nexttile
%             scatter(sorted_loads, features(:,3))
%             nexttile
%             scatter(sorted_loads, features(:,4))
%             nexttile
%             scatter(sorted_loads, features(:,5))
%             nexttile
%             scatter(sorted_loads, features(:,6))
            
            % durations
            cluster_model{k,1,count} = mod{1};
            % force
            cluster_model{k,2,count} = mod{2};
            % areas
            cluster_model{k,3,count} = mod{3};
            % areas_short
            cluster_model{k,4,count} = mod{4};
            % before
            cluster_model{k,5,count} = mod{5};
            % next
            cluster_model{k,6,count} = mod{6};
            % all
            cluster_model{k,7,count} = mod{7};
            count = count+1;
        end
    end
end
%% LIMO level 2 analysis + cluster correction
% order durations, force, areas, areas_short
for clus =1:selected_k
    cluster = cell2mat(cluster_model(clus,:,:));
    [LIMO_path] = run_t_tests_and_clustering(sprintf('cluster_prep_%d',clus), 0, 0, cluster);
end
%% 
for clus =1:selected_k
    load(sprintf('one_sample_ttest_parameter_1_cluster_prep_%d',clus))
    one_sample(:,:,5)
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% plot electrode location
% plot_elec_location(chan, EEG.chanlocs)
time_range = [-2000:1999];
run_n =3;
%% plot clusters FS
for kclus=1:selected_k
    [f, f2] = plot_clusters(basis_all_pps',cluster_res,selected_k,pps_in_cluster,time_range, 'start_row',kclus, 'end_row', kclus);
    set(f,'position',[500,500,400,150])
    set(f2,'position',[500,500,150,150])
    h = plot_erp_clusters(fs1s,cluster_res,stable_loadings,selected_k,pps_in_cluster,ranks_in_cluster, EEG,'start_row',kclus, 'end_row', kclus);
    set(h,'position',[500,500,400,150])
    saveas(f, sprintf('cluster_prep_%d.svg',kclus))
    saveas(f2, sprintf('hist_prep_%d.svg',kclus))
    saveas(h, sprintf('erp_clus_prep_%d.svg',kclus))
end
% plot_clusters(basis_all_pps',cluster_res,best_k_overall,best_k_overall,chan,time_range, 'start_row',1, 'end_row', 5)
%%
f = plot_clusters(basis_all_pps',cluster_res,selected_k,pps_in_cluster,time_range);
%% plot 1 pp erp FS
% plot nmf results all participants
for pp=1:size(fs1s,1)
% for pp=4:4
    W = stable_basis{pp};
    H = full(stable_loadings{pp});
    erp_ersp_data = fs1s{pp,4};
    [chan] = sel_most_prevalent_chan(EEG,erp_ersp_data,preparation);
                
    best_k_overall = size(H,1);
    [trial_times] = trial_idx(H',fs1s,best_k_overall,time_range,chan,pp,'percentage', 30);
    
    %     plot_FS_nmf_per_p(basis,loadings,fs1s,best_k_overall,time_range,chan,pp);
    plot_sel_trials(W,H,fs1s,best_k_overall,time_range,chan,pp, 'percentage', 30, 'order', 'descend');
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
    %     plot_behavior_no_sel(loadings,fs1s,selected_k,trial_times,chan,pp)
end
%%
[trials_diff] = plot_FS_nmf_per_p(basis,loadings,fs1s,selected_k,time_range,chan,pp);
%%
plot_nmf_all_participants(basis,time_range,chan, 'erp_data', cat(3,fs1s{:,2}))
%% calculated correlation between top x percentage erp and basis
corrmatrix = [];

for percentage =1:10
    for k=1:selected_k
        count = 1;
        for clus=1:size(cluster_res,1)
            if cluster_res(clus) == k
                pp = pps_in_cluster(clus);
                r = ranks_in_cluster(clus);
                W = stable_basis{pp};
                H = full(stable_loadings{pp});
                
                erp_ersp_data = fs1s{pp,4};
                [chan] = sel_most_prevalent_chan(EEG,erp_ersp_data,preparation);
                [~,idx] = sort(H(r,:), 'descend');
                
                sorted_trials = squeeze(erp_ersp_data(chan,selected_time,idx));
                n_trials = size(sorted_trials,2);
                sel_trials = ceil(n_trials*percentage*10/100);
                erp = squeeze(trimmean(sorted_trials(:,1:sel_trials),20,2));
                
                basis_r = W(:,r);
                CORR = corrcoef(zscore(erp),basis_r');
                corrmatrix(k,percentage,count) = CORR(2);
                count = count+1;
            end
        end
    end
end
%%
pps = [];
for k=1:selected_k
    count = 1;
    for clus=1:size(cluster_res,1)
        if cluster_res(clus) == k
            pp = pps_in_cluster(clus);
            pps(k,percentage,count) = pp;
            count = count+1;
        end
    end
end
%% plot correlation matrix 
figure;
tiledlayout(7,1)
for i=1:selected_k
    nexttile
    res = zeros(10,25) -0.1;
    clus1 = squeeze(corrmatrix(i,:,:));
    clus1(clus1 == 0) = nan;
    corrs = rmmissing(clus1,2);
    
    tmp = squeeze(pps(i,:,:));
    tmp(tmp == 0) = nan;
    pp_tmp = rmmissing(tmp,1);
    
    res(:,pp_tmp) = corrs.^2;
    imagesc(res, [-0.1,1])
    colorbar
    cmap = colormap('jet');
    cmap(1,:) = 1;
    colormap(cmap)
    set(gca, 'visible', 'off')
%     set(gca, 'FontSize', 18)
%     ylabel('Percentage')
%     xlabel('Subject')
%     title(sprintf('Cluster %d',i))
end
%%
med_percentage = zeros(10,1);
med_sel_trials_n = zeros(10,1);
for r=1:10
    med_percentage(r) = median(corrmatrix(:,r,:), 'all');
    med_sel_trials_n(r) = median(cellfun(@(x) ceil(size(x,3)*r*10/100),fs1s(:,4)));
end
figure; plot(med_percentage); yyaxis right; plot(med_sel_trials_n);
legend('Median correlation', 'Number of trials', 'Location', 'southoutside')