function [basis_all,loadings_all,train_err_all,test_err_all] = fs_nnmf2(erp_ersp_data,EEG,sensorimotor)
options.erp_data = 1;
electrodes = 62;
% electrodes = 1;
n_participants =  size(erp_ersp_data,1);

basis_all = cell(1,n_participants);
loadings_all = cell(1,n_participants);
train_err_all = cell(1,n_participants);
test_err_all = cell(1,n_participants);
if sensorimotor
    selected_time = 1500:2100;
else
    selected_time = 2100:2500;
end


for pp =1:n_participants
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data{pp,:}(:,selected_time,:),20,3)),sensorimotor);
    %     for chan=1:electrodes
    if options.erp_data
        non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,selected_time,:)), 'shift_local');
    else
        non_neg_data = make_eeg_nonneg(erp_ersp_data{pp,chan}, 'shift_local');
    end
    [W, H, train_err, test_err] = nnmf_cv(non_neg_data,'repetitions',100);
    basis_all{pp} = W;
    loadings_all{pp} = H;
    train_err_all{pp} = train_err;
    test_err_all{pp} = test_err;
    %     end
    save(sprintf('res2/basis_all_%d.mat',pp), 'W')
    save(sprintf('res2/loadings_all_%d.mat',pp), 'H')
    save(sprintf('res2/train_err_all_%d.mat',pp), 'train_err')
    save(sprintf('res2/test_err_all_%d.mat',pp), 'test_err')
end
save('res2/basis_all.mat', 'basis_all')
save('res2/loadings_all.mat', 'loadings_all')
save('res2/train_err_all.mat', 'train_err_all')
save('res2/test_err_all.mat', 'test_err_all')
end