function [cluster_res] = k_means_cluser_nmf(basis,kclus, chan)
z = cat(2,basis{chan,:})';
cluster_res = kmeans(z, kclus);
end