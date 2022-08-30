function  plot_FS_nmf_per_p(basis,loadings,erp_data,k,time_range,chan,pp, options)
arguments 
    basis;
    loadings;
    erp_data;
    k  (1,1) ;
    time_range;
    chan (1,1);
    pp (1,1) ;
    options.start (1,1) logical = 1;
    options.plot_erp (1,1) logical = 0;
    options.rows_k (1,1) = k;
    options.start_k (1,1) = 1;
end
%% plot nmf per participant
figure;
if options.rows_k > 5
    options.rows_k = 5;
end

if options.start
    erp_idx_trials = 4;
    erp_idx = 2;
else
    erp_idx_trials = 7;
    erp_idx = 3;
end

if options.plot_erp
    tiledlayout(options.rows_k,3+1)
else
    tiledlayout(options.rows_k,3)
end
for r=options.start_k:options.rows_k
    %plot 1 : basis for each rank
    nexttile
    plot(time_range, basis(:,r))
    xlabel('Latency from event (ms)')
    box off;
    xline(0)
    
    %plot 2: Plot erp all trials
    [~,idx] = sort(loadings(r,:), 'descend');
    nexttile
    imagesc(time_range,[],zscore(squeeze(erp_data{pp,erp_idx_trials}(chan,time_range+2000,idx))',[],2));
    ylabel('Trials')
    xlabel('Latency from event (ms)')
    box off;
    colorbar
    xline(0)
    title(sprintf('Rank: %d',r))
    
    %plot 3 durations per trials
    nexttile
    [durations] = calculate_fs_durations(erp_data,pp);
    imagesc(durations(idx)')
    title('Duration per trial')
    ylabel('Trials')
    set(gca, 'XTick', [])
    colorbar
    box off;
    % plot erp average
    if options.plot_erp
        nexttile
        if r == ceil(k/2)
            plot(time_range,erp_data{pp,erp_idx}(chan,:))
        else
            set(gca, 'visible', 'off')
        end
        box off;
    end
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))
end