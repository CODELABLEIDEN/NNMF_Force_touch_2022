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
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% perform erp nmf %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load FS erp data
load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_fs3hz1s3/fs1s.mat')
%% nnmf erp
electrodes = 64;
n_participants =  size(fs1s,1);

basis_all = cell(electrodes,n_participants);
loadings_all = cell(electrodes,n_participants);
train_err_all = cell(electrodes,n_participants);
test_err_all = cell(electrodes,n_participants);

for pp =1:size(fs1s,1)
    tmp_pp = fs1s{pp,7};
    for chan=1:electrodes
        non_neg_data = make_eeg_nonneg(squeeze(tmp_pp(chan,:,:)), 'shift_local');
        [basis, loadings, train_err, test_err] = nnmf_cv(non_neg_data, 'replicates', 1,'create_seed', 0);
        basis_all{chan,pp} = basis;
        loadings_all{chan,pp} = loadings;
        train_err_all{chan,pp} = train_err;
        test_err_all{chan,pp} = test_err;
    end
end
%% Select best results
% choose best k
train_err_reshap = cell2mat(cat(3,train_err_all{:}));
test_err_reshap = cell2mat(cat(3,test_err_all{:}));

[best_k_overall]  = choose_best_k(test_err_reshap, train_err_reshap);
% choose best repition
[basis] = choose_best_rep(basis_all,train_err_reshap,best_k_overall);
[loadings] = choose_best_rep(loadings_all,train_err_reshap,best_k_overall);
%% kmeans clustering erp
kclus = 15;
chan = 16;
[cluster_res] = k_means_cluser_nmf(basis,kclus, chan);
%% plot clusters FS
plot_clusters(z,cluster_res,kclus,chan,participants,time_range)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% perform ersp nmf %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load ersp
load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_erspfs3hz1s45/fsersp.mat');
[ersp, selected,participants_fs] = prepare_ersp_data_fs(fsersp);
%% ersp nmf
channels = 64;
k = 5;
basis_ersp = cell(size(ersp,1),channels);
loadings_ersp = cell(size(ersp,1),channels);
for pp = 1:size(ersp,1)
    for chan=1:channels
        tmp_pp_chan = ersp{pp,chan,2};
        local_min = abs(ceil(min(tmp_pp_chan,[], 'all')));
        [H,W] = nnmf(tmp_pp_chan+local_min,k);
        basis_ersp{pp,chan} = zscore(H);
        loadings_ersp{pp, chan} = zscore(W);
    end
end
%% kmeans clustering ersp
kclus = 5;
chan = 16;

[clusters_ersp] = k_means_cluser_nmf(basis_ersp,kclus, chan);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot nmf results all participants
plot_nmf_all_participants(basis(8:23,:),[-2000:1999],chan, 'erp_data', x)
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
%% plot clusters FS
plot_clusters(z,cluster_res,kclus,chan,participants,time_range)
%% plot 1 pp erp FS
pp = 1;
chan = 16;
plot_FS_nmf_per_p(basis,loadings,fs1s,k,time_range,chan,pp)
%% plot 1 pp tap
pp = 1;
chan = 16;
plot_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp)
%% plot electrode location
plot_elec_location(chan, EEG)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% erp taps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load preformatted erp data
data_path = '/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_aligned_3';
load_str = 'alignederp3';
data_name = 'A';
folder_contents = dir(data_path);
files = {folder_contents.name};
all_files = files(cellfun(@(x) contains(x, load_str),files));
load_data = {};
%%
channels = 64;
k = 5;
% basis = cell(size(aligned,1),channels);
% loadings = cell(size(aligned,1),channels);
count = 1;
for i=1:length(all_files)
    tmp = load(sprintf('%s/%s',data_path,all_files{i}));
    disp(sprintf('%s/%s',data_path,all_files{i}))
    if ~(isempty(fieldnames(tmp))) &&  ~isempty(tmp.(data_name))
        tmp = tmp.(data_name)(~cellfun(@isempty ,tmp.(data_name)));
        for pp=1:length(tmp)
            erp_pp = tmp{pp}{1,4};
            parfor chan=1:channels
                tmp_pp_chan = squeeze(erp_pp(16,:,:));
                local_min = abs(ceil(min(tmp_pp_chan,[], 'all')));
                [H,W] = nnmf(tmp_pp_chan+local_min,k);
                basis{count,chan} = zscore(H);
                loadings{count, chan} = zscore(W);
            end
            count = count + 1;
        end
    end
end
%% cluster taps
kclus = 5;
chan = 16;

z = cat(2,basis{8:68,chan})';
participants = repelem([1:size(basis,1)],5);

cluster_res = kmeans(z, kclus);
%%
[~, cluster_res] = min(squeeze(test_err(:,:,15,:)), [], 3, 'linear');
x = squeeze(loadings(:,:,:,15));
x = x(:);
b = reshape(x(cluster_res), [16, 64])