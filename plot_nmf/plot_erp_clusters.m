function f = plot_erp_clusters(fs1s,cluster_res,stable_loadings,kclus,pps_in_cluster,ranks_in_cluster, EEG,options)
arguments
    fs1s;
    cluster_res;
    stable_loadings;
    kclus;
    pps_in_cluster;
    ranks_in_cluster;
    EEG;
    options.start_row = 1;
    options.end_row = kclus;
    options.preparation = 1;
    options.percentage = 20;
end
if options.preparation
    selected_time = 1500:2100;
    time_range = -500:100;
else
    selected_time = 2100:2500;
    time_range = 100:500;
end

f =figure;
tiledlayout(options.end_row-options.start_row+1,1)
for i=options.start_row:options.end_row
    nexttile
    for clus =1:length(cluster_res)
        if cluster_res(clus) == i
            hold on
            pp = pps_in_cluster(clus);
            r = ranks_in_cluster(clus);
            erp_ersp_data = fs1s{pp,4};
            H = full(stable_loadings{pp});
            
            [chan] = sel_most_prevalent_chan(EEG,erp_ersp_data,options.preparation);
            %             plot(time_range,erp_ersp_data(chan,:), 'Color', [0 0 0 0.5])
            [~,idx] = sort(H(r,:), 'descend');
            sorted_trials = squeeze(erp_ersp_data(chan,selected_time,idx));
            n_trials = size(sorted_trials,2);
            sel_trials = ceil(n_trials*options.percentage/100);
            erp = squeeze(trimmean(sorted_trials(:,1:sel_trials),20,2));
            plot(time_range, zscore(erp), 'Color', [0 0 0 0.5]);
        end
    end
    xline(0)
%     set(gca, 'FontSize', 18)
    %     xlabel('Latency from event (ms)')
    %     ylabel('Normalized')
    %     title(sprintf('Cluster %d',i))
    set(gca, 'visible', 'off')
end
end