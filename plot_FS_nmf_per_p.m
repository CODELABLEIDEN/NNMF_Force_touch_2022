function plot_FS_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp)
%% plot nmf per participant
figure;
tiledlayout(k,3+1)
for r=1:k
    %plot 1
    nexttile
    plot(time_range, basis{pp,chan}(:,r))
    xlabel('Latency from event (ms)')
    box off;
    [~,idx] = sort(loadings{pp,chan}(r,:));
    xline(0)
    %plot 2
    nexttile
    imagesc(time_range,[],zscore(squeeze(erp_data{pp,7}(chan,:,idx))',[],2));
    ylabel('Trials')
    xlabel('Latency from event (ms)')
    box off;
    colorbar
    xline(0)
    title(sprintf('Rank: %d',r))
    %plot 3
    nexttile
    trials_diffs = erp_data{pp,10}-erp_data{pp,8};
    trials_diffs(erp_data{pp,12}) = NaN;
    trials_diffs = rmmissing(trials_diffs);
    imagesc(trials_diffs(idx)')
    title('Duration per trial')
    ylabel('Trials')
    set(gca, 'XTick', [])
    colorbar
    box off;
    % plot erp
    nexttile
    if r == ceil(k/2)
        plot(time_range,erp_data{pp,2}(chan,:))
    else
        set(gca, 'visible', 'off')
    end
    box off;
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))
end