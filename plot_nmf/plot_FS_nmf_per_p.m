function [trials_diffs] = plot_FS_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp, options)
arguments 
    basis;
    loadings;
    erp_data;
    k  (1,1) ;
    time_range;
    chan (1,1);
    pp (1,1) ;
    options.plot_erp (1,1) logical = 0;
    options.rows (1,1) = k;
    options.start (1,1) = 1;
end
%% plot nmf per participant
figure;
if options.rows > 5
    options.rows = 5;
end

if options.plot_erp
    tiledlayout(options.rows,3+1)
else
    tiledlayout(options.rows,3)
end
for r=options.start:options.rows
    %plot 1
    nexttile
    plot(time_range, basis{chan,pp}(:,r))
    xlabel('Latency from event (ms)')
    box off;
    [~,idx] = sort(loadings{chan,pp}(r,:), 'descend');
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
    if options.plot_erp
        % plot erp
        nexttile
        if r == ceil(k/2)
            plot(time_range,erp_data{pp,2}(chan,:))
        else
            set(gca, 'visible', 'off')
        end
        box off;
    end
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))
% if options.rows >= 5
%     plot_FS_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp, 'start',options.rows)
% end
end