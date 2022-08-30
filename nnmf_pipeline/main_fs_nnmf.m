function [basis_all, loadings_all] = main_fs_nnmf(erp_ersp_data, EEG, preparation, options)
arguments
    erp_ersp_data;
    EEG;
    preparation;
    options.repetitions = 1000;
    options.save_path = 'res'
end

n_participants =  size(erp_ersp_data,1);
if preparation    
    load('/home/s1815458/fs_nnmf_pipeline/preparation_cv_res/test_err_all.mat')
else
    load('/home/s1815458/fs_nnmf_pipeline/consolidation_cv_res/test_err_all.mat')
end

if preparation
    selected_time = 1500:2100;
else
    selected_time = 2100:2500;
end

basis_all = cell(options.repetitions,n_participants);
loadings_all = cell(options.repetitions,n_participants);

for pp =1:n_participants
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data{pp,:}(:,selected_time,:),20,3)),preparation);
    k = select_best_k(test_err_all, pp);
    non_neg_data = make_eeg_nonneg(squeeze(erp_ersp_data{pp,:}(chan,selected_time,:)), 'shift_local');
    for rep = 1:options.repetitions
        [W, H] = perform_nnmf(non_neg_data, k);
        basis_all{rep,pp} = W;
        loadings_all{rep,pp} = H;
    end
    basis = basis_all{:,pp};
    loading = loadings_all{:,pp};
    save(sprintf('%s/basis_all_%d.mat',options.save_path,pp), 'basis')
    save(sprintf('%s/loadings_all_%d.mat',options.save_path,pp), 'loading')
end
save(sprintf('%s/basis_all.mat',options.save_path), 'basis_all')
save(sprintf('%s/loadings_all.mat',options.save_path), 'loadings_all')
end