% load all of the repetitions in the same tensor
% Dhat = zeros(d,K,numRep);
% for L = 1:numRep
%     Dhat(:,:,L) = D;
% end
%%
basis_per_c = cellfun(@(x) x(:,best_k_overall-1),basis_all,'UniformOutput',false);
basis_all_reshap = cellfun(@(x) cat(3,x{:}),basis_per_c,'UniformOutput',false);
%%
numRep = size(basis_all_reshap{1,1},3);
% this is the correlation matrix [or distance matrix]
% it holds the pairwise correlation between each of the repetitions D
for chan=1:electrodes
    distMat = zeros(numRep,numRep);
    tmp = basis_all_reshap{chan};
    % for each pair of Ds
    for q = 1:numRep
        for p = q:numRep
            CORR = corr(tmp(:,:,q),tmp(:,:,p));
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
%     W = D;
end