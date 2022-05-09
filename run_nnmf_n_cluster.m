function [basis, loadings, cluster_res] = run_nnmf_n_cluster(erp_ersp_data)
%% nnmf erp
% electrodes = 64;
electrodes = 1;
n_participants =  size(erp_ersp_data,1);

basis_all = cell(electrodes,n_participants);
loadings_all = cell(electrodes,n_participants);
train_err_all = cell(electrodes,n_participants);
test_err_all = cell(electrodes,n_participants);

for pp =1:size(erp_ersp_data,1)
    tmp_pp = erp_ersp_data{pp,7};
    for chan=1:electrodes
        non_neg_data = make_eeg_nonneg(squeeze(tmp_pp(chan,:,:)), 'shift_local');
        [basis, loadings, train_err, test_err] = nnmf_cv(non_neg_data, 'replicates', 1,'repetitions',2,'create_seed', 0);
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
% plot_clusters(z,cluster_res,kclus,chan,participants,time_range)
end