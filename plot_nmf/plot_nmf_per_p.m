function plot_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp,options)
arguments
    basis;
    loadings;
    erp_data;
    k;
    time_range;
    chan;
    pp;
    options.start_row = 1;
    options.end_row = k;
end
%% plot nmf per participant
figure;
tiledlayout(options.end_row-options.start_row+1,2)

for r=options.start_row:options.end_row
    %plot 1
    nexttile
    plot(time_range, basis{pp,chan}(:,r))
    xlabel('Latency from event (ms)')
    box off;
    [~,cluster_res] = sort(loadings{pp,chan}(r,:));
    xline(0)
    %plot 2
    nexttile
    %     imagesc(time_range,[],zscore(squeeze(erp_data{pp,chan})',[],2));
    imagesc(time_range,[],zscore(squeeze(erp_data{pp}(chan,:,cluster_res))',[],2));
    ylabel('Trials')
    xlabel('Latency from event (ms)')
    box off;
    colorbar
    xline(0)
    title(sprintf('Rank: %d',r))
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))
end