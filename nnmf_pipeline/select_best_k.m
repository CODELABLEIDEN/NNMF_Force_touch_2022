function [all_ks] = select_best_k(test_err_all, pp)
if ~pp
    all_ks = [];
    for pp=1:length(test_err_all)
        x = cell2mat(test_err_all{pp});
        [~,k] = min(mean(x,1));
        all_ks = [all_ks k+1];
    end
else
    x = cell2mat(test_err_all{pp});
    [~,k] = min(mean(x,1));
    all_ks = k+1;
end
end