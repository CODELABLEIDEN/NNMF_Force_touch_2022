function [best_k_overall,best_ks] = choose_best_k(test_err, train_err)
% average over all repetitions
te = mean(test_err, 1);
tr = mean(train_err, 1);

% minimum across k's
[~, best_ks] = min(te, [], 2); 
best_ks = squeeze(best_ks);
best_k_overall = mode(best_ks);
end