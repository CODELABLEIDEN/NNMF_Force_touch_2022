function [W, H] = stable_nnmf(basis_all,loadings_all, pp)
%%
numRep = size(basis_all(:,pp),1);
% this is the correlation matrix [or distance matrix]
% it holds the pairwise correlation between each of the repetitions D
% for chan=1:electrodes
distMat = zeros(numRep,numRep);
tmp_basis = basis_all(:,pp);
tmp_loading = loadings_all(:,pp);
% for each pair of Ds
for q = 1:numRep
    for p = q:numRep
        CORR = corr(tmp_basis{q,:},tmp_basis{p,:});
        distMat(q,p) = amariMaxCorr(CORR);  % find the best permutation invariant correaltion
        distMat(p,q) = distMat(q,p);  % ensure simmetric distance matrix
    end
end

% I take the median across rows
estStability = median(distMat, 1);

% I find the D with the best median correaltion
% this means I find the D with the max consensus across the pool of
% repetitions
[~, idx_best_D] = max(estStability);


%     % For the best D I find the corresponding H -> X = W * H;
%     H = mexLasso(X,D,param);
W = tmp_basis{idx_best_D,:};
H = tmp_loading{idx_best_D,:};
% end
end