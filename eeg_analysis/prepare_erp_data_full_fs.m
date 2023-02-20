function [erp_all] = prepare_erp_data_full_fs(fs1s,loadings, basis, options)
arguments
    fs1s;
    loadings;
    basis;
    options.percentage = 30;
    options.order = 'descend';
    options.start logical = 1;
    options.pp_start = 1;
    options.pp_end = [];
end
if isempty(options.pp_end)
    options.pp_end = size(fs1s,1);
end

if options.start
    erp_idx_trials = 4;
else
    erp_idx_trials = 7;
end
erp_all = [];
count = 1;
for pp=options.pp_start:options.pp_end
    k = size(loadings{pp},1);
    for r=1:k
        [~,idx] = sort(loadings{pp}(r,:), options.order);
        sorted_trials = fs1s{pp,erp_idx_trials}(:,:,idx);
        n_trials = size(sorted_trials,3);
        sel_trials = ceil(n_trials*options.percentage/100);
        erp = trimmean(sorted_trials(1:62,:,1:sel_trials),20,3);
        erp_all(:,:,count) = erp;
        count = count +1;
    end
end
end