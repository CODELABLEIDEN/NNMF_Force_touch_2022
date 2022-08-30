function [s] = plot_behavior_no_sel(loadings,fs1s,best_k_overall,trial_times,chan,pp)
    % plot
figure;
tiledlayout(best_k_overall,1)
n_trials = size(loadings, 2);
sel_trials = n_trials * 20/100;
for r=1:best_k_overall
    [sorted_loads,idx] = sort(loadings(r,:), 'descend');
%     [sorted_loads,idx_ascend] = sort(loadings(r,:), 'ascend');
    
    trials_diffs = calculate_fs_durations(fs1s,pp);
    durations = trials_diffs(idx);
    s(r).duration_top = median(durations(1:sel_trials));
    s(r).duration_bottom = median(durations(end-sel_trials+1:end));
    s(r).duration_med = median(durations);
    
    % check effect of force
    force = fs1s{pp,13}(trial_times{r,4});
    force = force(idx);
    s(r).force_top = median(force(1:sel_trials));
    s(r).force_bottom = median(force(end-sel_trials+1:end));
    s(r).force =  median(force);
    
    [areas] = calculate_fs_area_full(fs1s,pp);
    areas = areas(idx);
    s(r).areas_top = median(areas(1:sel_trials));
    s(r).areas_bottom = median(areas(end-sel_trials+1:end));
    s(r).areas = median(areas);
    
    [areas_short,count] = calculate_fs_area_short(fs1s,pp);
    areas_short = areas_short(idx);
    s(r).areas_short_top = median(areas_short(1:sel_trials));
    s(r).areas_short_bottom = median(areas_short(end-sel_trials+1:end));
    s(r).areas_short = median(areas_short);
    
    
    nexttile
    plot(zscore(durations))
    hold on 
    plot(zscore(force))
    plot(zscore(areas))
    plot(zscore(areas_short))
    plot(zscore(idx))
    title(sprintf('Rank %d', r))
    sgtitle(sprintf('Subject %d - Electrode %d', pp, chan))
end
legend('duration', 'force', 'area', 'area_short', 'trial num', 'Location' ,'southoutside')
end