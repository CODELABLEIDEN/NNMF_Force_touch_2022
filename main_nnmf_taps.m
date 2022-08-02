%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% erp taps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load preformatted erp data
data_path = '/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_aligned_3';
load_str = 'alignederp3';
data_name = 'A';
time_range = 4000;
[load_data] = load_checkpoints_fs(data_path, load_str,data_name, 'split_trials', 1, 'time_range', time_range, 'index', 4);
%%
load('/media/Storage/User_Specific_Data_Storage/ruchella/EEGsynclib_Mar_2022/erp_aligned_3/processed/aligned_erp3_all_trials.mat')
%%
best_k_overall = 10;
channels = 64;
k = 10;
% basis = cell(size(aligned,1),channels);
% loadings = cell(size(aligned,1),channels);

basis_all = cell(channels,69);
loadings_all = cell(channels,69);
train_err_all = cell(channels,69);
test_err_all = cell(channels,69);

count = 1;
for i=1:length(all_files)
    tmp = load(sprintf('%s/%s',data_path,all_files{i}));
    disp(sprintf('%s/%s',data_path,all_files{i}))
    if ~(isempty(fieldnames(tmp))) &&  ~isempty(tmp.(data_name))
        tmp = tmp.(data_name)(~cellfun(@isempty ,tmp.(data_name)));
        for pp=1:length(tmp)
            erp_pp = tmp{pp}{1,4};
            parfor chan=1:channels
                non_neg_data = make_eeg_nonneg(squeeze(erp_pp(chan,:,:)), 'shift_local');
                [W, H] = perform_nnmf(non_neg_data, best_k_overall, 'replicates', 1, 'create_seed', 0);
                basis_all{chan,count} = W;
                loadings_all{chan,count} = H;
%                 train_err_all{chan,count} = train_err;
%                 test_err_all{chan,count} = test_err;
            end
            count = count + 1;
        end
    end
end
%% cluster taps
kclus = 10;
chan = 16;

z = cat(2,basis_all{chan,8:68})';
participants = repelem([1:size(basis_all,1)],5);

cluster_res = kmeans(z, kclus);
%%
time_range = [-2000:1999];
chan = 16;
% plot clusters
plot_clusters(basis_all(:,8:68),cluster_res,kclus,best_k_overall,chan,time_range, 'start_row',1, 'end_row', 5);
%%
W = cat(2,basis_all{chan,8:68})';
H = cat(2,loadings_all{chan,8:68})';
pp = 1;
chan = 16;
plot_nmf_per_p(basis_all(:,8:68),loadings_all(:,8:68),load_data(8:68),k,time_range,chan,pp, 'start_row',1, 'end_row', 5)
%%
plot_FS_nmf_per_p(basis,loadings,fs1s,best_k_overall,time_range,chan,pp)
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% JIDS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
taps = EEG.Aligned.Phone.Blind{1,2}(:,2);
[jid, bin_edges, xi] = taps2JID(taps');

itis = diff(taps);
[jid, bin_edges, xi] = iti2JID(itis);
%%
figure; imagesc(xi(:,1), xi(:,2),jid)
set(gca, 'YDir', 'normal')
colorbar