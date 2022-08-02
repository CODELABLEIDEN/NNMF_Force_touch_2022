function [basis_all,loadings_all,train_err_all,test_err_all] = fs_nnmf(erp_ersp_data,EEG)
options.erp_data = 1;
electrodes = 62;
% electrodes = 1;
n_participants =  size(erp_ersp_data,1);

basis_all = cell(1,n_participants);
loadings_all = cell(1,n_participants);
train_err_all = cell(1,n_participants);
test_err_all = cell(1,n_participants);
preparatory_time = 1500:2100;

for pp =1:n_participants
    [chan] = sel_most_sensorimotor_chan(EEG,squeeze(trimmean(erp_ersp_data{pp,:}(:,preparatory_time,:),20,3)),1);
%     for chan=1:electrodes
        if options.erp_data
            non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,preparatory_time,:)), 'shift_local');
        else
            non_neg_data = make_eeg_nonneg(erp_ersp_data{pp,chan}, 'shift_local');
        end
        [W, H, train_err, test_err] = nnmf_cv(non_neg_data,'repetitions',2);
        basis_all{pp} = W;
        loadings_all{pp} = H;
        train_err_all{pp} = train_err;
        test_err_all{pp} = test_err;
%     end
end
save('basis_all.mat', 'basis_all')
save('loadings_all.mat', 'loadings_all')
save('train_err_all.mat', 'train_err_all')
save('test_err_all.mat', 'test_err_all')
end