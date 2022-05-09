function plot_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp)
%% plot nmf per participant
figure;
tiledlayout(k,2)

for r=1:k
    %plot 1
    nexttile
    plot(time_range, basis{pp,chan}(:,r))
    xlabel('Latency from event (ms)')
    box off;
    [~,cluster_res] = sort(loadings{pp,chan}(r,:));
    xline(0)
    %plot 2
    nexttile
    imagesc(time_range,[],zscore(squeeze(erp_data{pp,chan})',[],2));
    ylabel('Trials')
    xlabel('Latency from event (ms)')
    box off;
    colorbar
    xline(0)
    title(sprintf('Rank: %d',r))
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))
end