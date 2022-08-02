function [basis, loadings,best_k_overall,test_err_reshap,train_err_reshap] = run_nnmf_n_cluster(erp_ersp_data, options)
arguments
    erp_ersp_data;
    options.erp_data logical = 1;
end
%% nnmf erp
electrodes = 64;
% electrodes = 1;
n_participants =  size(erp_ersp_data,1);

basis_all = cell(electrodes,n_participants);
loadings_all = cell(electrodes,n_participants);
train_err_all = cell(electrodes,n_participants);
test_err_all = cell(electrodes,n_participants);

for pp =1:n_participants
    for chan=1:electrodes
        if options.erp_data
            non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,:,:)), 'shift_local');
        else
            non_neg_data = make_eeg_nonneg(erp_ersp_data{pp,chan}, 'shift_local');
        end
        [W, H, train_err, test_err] = nnmf_cv(non_neg_data, 'replicates', 1,'repetitions',2,'create_seed', 0);
        basis_all{chan,pp} = W;
        loadings_all{chan,pp} = H;
        train_err_all{chan,pp} = train_err;
        test_err_all{chan,pp} = test_err;
    end
end
%% Select best results
% choose best k
train_err_reshap = cell2mat(cat(3,train_err_all{:}));
test_err_reshap = cell2mat(cat(3,test_err_all{:}));

[best_k_overall]  = choose_best_k(test_err_reshap, train_err_reshap);
%%
% for pp = 1:n_participants
%     for chan=1:electrodes
%         if options.erp_data
%             non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,:,:)), 'shift_local');
%         else
%             non_neg_data = make_eeg_nonneg(erp_ersp_data{pp,chan}, 'shift_local');
%         end
%         [W, H] = perform_nnmf(non_neg_data, best_k_overall, 'replicates', 1);
%         basis{chan,pp} = zscore(W);
%         loadings{chan,pp} = zscore(H);
%     end
% end
end