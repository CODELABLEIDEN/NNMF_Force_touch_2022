function plot_clusters(basis,cluster_res,kclus,pps,time_range, options)
arguments
    basis;
    cluster_res;
    kclus;
    pps;
    time_range;
    options.start_row = 1;
    options.end_row = kclus;
end
% z = cat(2,basis{chan,:})';
% participants = repelem([1:size(basis,2)],r);

figure;
tiledlayout(options.end_row-options.start_row+1,3)
for i=options.start_row:options.end_row
    nexttile([1,2])
    participants_in_clus = [];
    for clus =1:length(cluster_res)
        if cluster_res(clus) == i
            hold on
            plot(time_range,squeeze(basis(clus,:)))
            xline(0)
            participants_in_clus = [participants_in_clus pps(clus)];
        end
    end
    xlabel('Latency from event (ms)')
    ylabel('Normalized')
    title(sprintf('Cluster %d',i))
    nexttile
    histogram(participants_in_clus, length(participants_in_clus), 'BinMethod', 'integer');
    ylim([0 3])
    xlim([0,length(unique(pps))])
    xlabel('Participant')
    ylabel('Frequency')
    box off;
end
end