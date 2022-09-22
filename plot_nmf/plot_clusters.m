function [f, f2] = plot_clusters(basis,cluster_res,kclus,pps,time_range, options)
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

f =figure;
tiledlayout(options.end_row-options.start_row+1,1)
for i=options.start_row:options.end_row
    nexttile
    participants_in_clus = [];
    for clus =1:length(cluster_res)
        if cluster_res(clus) == i
            hold on
            plot(time_range,squeeze(basis(clus,:)), 'Color', [0 0 0 0.5])
            participants_in_clus = [participants_in_clus pps(clus)];
        end
    end
%     set(gca, 'FontSize', 13)
    xline(0)
%     xlabel('Latency from event (ms)')
%     ylabel('Normalized')
%     title(sprintf('Cluster %d',i))
    set(gca, 'visible', 'off')
    f2 = figure;
    
    histogram(participants_in_clus, length(participants_in_clus), 'BinMethod', 'integer');
    ylim([0 2])
    xlim([0,25+1])
    xticks(0:5:25+1)
    yticks(0:2)
%     xlabel('Participant')
%     ylabel('Frequency')
    box off;
    set(gca, 'FontSize', 13)
%     set(gca, 'visible', 'off')
end
end