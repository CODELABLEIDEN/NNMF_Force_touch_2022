function [res] = choose_best_rep(nnmf_mat,train_err_reshap,best_k_overall)
% overall best repetition with chosen k
[~, idx] = min(squeeze(train_err_reshap(:,best_k_overall,:)), [], 1, 'linear');
reshap = cat(3,nnmf_mat{:});
% select repitions with best k 
tmp = reshap(:,best_k_overall,:);
% flatten array
tmp = tmp(:);
res = reshape(tmp(idx), size(nnmf_mat));
end