function [cluster_res,cluster_centroid,ssqs] = cluster_nnmf(basis_all_pps, selected_k)
cluster_res = {};
cluster_centroid = {};
numreps = 1000;
ssqs = zeros(numreps,1);
for rep=1:numreps
    [cluster_res_tmp, C, sumd] = kmeans(basis_all_pps', selected_k);
    cluster_res{rep} = cluster_res_tmp;
    cluster_centroid{rep} = C;
    ssqs(rep) = sum(sumd);
end
[~,idx] = min(ssqs);
cluster_res = cluster_res{idx};
end