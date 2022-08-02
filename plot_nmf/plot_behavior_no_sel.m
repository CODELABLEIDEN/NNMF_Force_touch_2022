
function plot_behavior_no_sel(loadings,fs1s,best_k_overall,trial_times,chan,pp)
    % plot
figure;
tiledlayout(best_k_overall,1)
for r=1:best_k_overall
    [sorted_loads,idx] = sort(loadings{chan,pp}(r,:), 'descend');
    
    % duration
    trials_diffs = fs1s{pp,10}-fs1s{pp,8};
    trials_diffs(fs1s{pp,12}) = NaN;
    trials_diffs = rmmissing(trials_diffs);
    durations = trials_diffs(idx);
    
    
    % check effect of force
    force = fs1s{pp,13}(trial_times{r,3});
    
    % area
    end_idx = fs1s{pp,10};
    end_idx(fs1s{pp,12}) = NaN;
    end_idx = rmmissing(end_idx);
    start_idx  = fs1s{pp,8};
    start_idx(fs1s{pp,12}) = NaN;
    start_idx = rmmissing(start_idx);
    areas = zeros(length(start_idx),1);

    for trial=1:length(start_idx)
        areas(trial) = trapz(fs1s{pp,13}(start_idx(trial):end_idx(trial)));
    end 
    areas = areas(idx);
    
    nexttile
    plot(zscore(durations))
    hold on 
    plot(zscore(force))
    plot(zscore(areas))
    plot(zscore(idx))
    title(sprintf('Rank %d', r))
    sgtitle(sprintf('Subject %d - Electrode %d', pp, chan))
end
legend('duration', 'force', 'area', 'trial num', 'Location' ,'southoutside')
end