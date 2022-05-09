function plot_clusters(basis,cluster_res,kclus,r,chan,time_range)
z = cat(2,basis{:,chan})';
participants = repelem([1:size(basis,1)],r);

figure;
tiledlayout(kclus,3)
for i=1:kclus
    nexttile([1,2])
    participants_in_clus = [];
    for clus =1:length(cluster_res)
        if cluster_res(clus) == i
            hold on
            plot(time_range,squeeze(z(clus,:)))
            xline(0)
            participants_in_clus = [participants_in_clus participants(clus)];
        end
    end
    xlabel('Latency from event (ms)')
    ylabel('Normalized')
    title(sprintf('Cluster %d',i))
    nexttile
    histogram(participants_in_clus, length(participants_in_clus), 'BinMethod', 'integer')
    ylim([0 2])
    xlim([0,17])
    xlabel('Participant')
    ylabel('Frequency')
    box off;
end
sgtitle(sprintf('Channel : %d', chan))
end