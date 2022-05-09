%% hierarchical clustering manual
% zz = squeeze(z(:,1,:))';
% Y = pdist(z);
Y = pdist(z,@(Xi,Xj) dtwdist(Xi,Xj));
Z = linkage(Y);
% dendrogram(Z)

maxclust = 10;
T = cluster(Z, 'maxclust', maxclust, 'Criterion', 'distance');
% T = cluster(Z, 'cutoff', 1, 'Criterion', 'distance');
maxclust = length(unique(T));
%% hierarchical clustering
T = clusterdata(z,15);
figure;
tiledlayout(5,1)
for i=1:5
    nexttile
    for clus =1:length(T)
        if T(clus) == i
            hold on
            plot([-1500:999],squeeze(z(clus,:)))
            xline(0)
        end
    end
end