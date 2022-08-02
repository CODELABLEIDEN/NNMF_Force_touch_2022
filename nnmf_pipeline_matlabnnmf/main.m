%% fake eeg data
% shape electrodes x trials x time x participant(s)
data = rand(62,40,100,10);
%% remove negativity of eeg data
non_neg_data = make_eeg_nonneg(data, 'shift_local');
%% perform cross validation nnmf for every participant and channel
electrodes =  size(data,1);
n_participants =  size(data,4);

basis_all = cell(electrodes,n_participants);
loadings_all = cell(electrodes,n_participants);
train_err_all = cell(electrodes,n_participants);
test_err_all = cell(electrodes,n_participants);

for elec=1:electrodes
    for pp=1:n_participants
        [basis, loadings, train_err, test_err] = nnmf_cv(squeeze(non_neg_data(elec,:,:,pp)), 'replicates', 1);
        basis_all{elec,pp} = basis;
        loadings_all{elec,pp} = loadings;
        train_err_all{elec,pp} = train_err;
        test_err_all{elec,pp} = test_err;
    end
end
%% choose best k
train_err_reshap = cell2mat(cat(3,train_err_all{:}));
test_err_reshap = cell2mat(cat(3,test_err_all{:}));

[best_k_overall]  = choose_best_k(test_err_reshap, train_err_reshap);

%% get nmf data with chosen best k
[basis] = choose_best_rep(basis_all,train_err_reshap,best_k_overall);
[loadings] = choose_best_rep(loadings_all,train_err_reshap,best_k_overall);