function [basis_all,loadings_all,train_err_all,test_err_all] = main_fs_nnmf_cv(erp_ersp_data,EEG,preparation,save_path, repetitions)
arguments
    erp_ersp_data;
    EEG struct;
    preparation logical = 1;
    save_path char = 'res';
    repetitions = 100;
end

options.erp_data = 1;
% electrodes = 1;
n_participants =  size(erp_ersp_data,1);

basis_all = cell(1,n_participants);
loadings_all = cell(1,n_participants);
train_err_all = cell(1,n_participants);
test_err_all = cell(1,n_participants);
if preparation
    selected_time = 1500:2100;
else
    selected_time = 2100:2500;
end


for pp =1:n_participants
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data{pp,:}(:,selected_time,:),20,3)),preparation);
    %     for chan=1:electrodes
    if options.erp_data
        non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,selected_time,:)), 'shift_local');
    else
        non_neg_data = make_eeg_nonneg(erp_ersp_data{pp,chan}, 'shift_local');
    end
    
    [W, H, train_err, test_err] = nnmf_cv(non_neg_data,'repetitions',repetitions);
    basis_all{pp} = W;
    loadings_all{pp} = H;
    train_err_all{pp} = train_err;
    test_err_all{pp} = test_err;
    %     end
    save(sprintf('%s/basis_all_%d.mat',save_path,pp), 'W')
    save(sprintf('%s/loadings_all_%d.mat',save_path,pp), 'H')
    save(sprintf('%s/train_err_all_%d.mat',save_path,pp), 'train_err')
    save(sprintf('%s/test_err_all_%d.mat',save_path,pp), 'test_err')
end
save(sprintf('%s/basis_all.mat',save_path), 'basis_all')
save(sprintf('%s/loadings_all.mat',save_path), 'loadings_all')
save(sprintf('%s/train_err_all.mat',save_path), 'train_err_all')
save(sprintf('%s/test_err_all.mat',save_path), 'test_err_all')
end