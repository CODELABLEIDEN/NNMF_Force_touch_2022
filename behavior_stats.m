function [stats,durations, force, areas, areas_short, sort_start_dist, sort_next_trial, idx] = behavior_stats(loadings,fs1s,r,pp)
stats = struct();
n_trials = size(loadings, 2);
sel_trials = n_trials * 20/100;
% for r=1:best_k_overall
    [sorted_loads,idx] = sort(loadings(r,:), 'descend');
    fs1s(:,13) = cellfun(@(fspp) fspp+1, fs1s(:,13), 'UniformOutput', false);
%     [sorted_loads,idx_ascend] = sort(loadings(r,:), 'ascend');
    start_i = [fs1s{pp,8} 0];
    end_i = [0 fs1s{pp,10}];
    start_distance = round(start_i - end_i);
    start_distance(end) = median(start_distance);
    start_distance(1) = median(start_distance);
    start_distance(start_distance > 15000) = median(start_distance);
    
    next_trial = [start_distance(2:end) 0];
    sort_start_dist = start_distance(idx);
    sort_next_trial = next_trial(idx);
    
    trials_diffs = calculate_fs_durations(fs1s,pp);
    durations = ((trials_diffs(idx)));
%     stats.duration_top = median(durations(1:sel_trials));
%     stats.duration_bottom = median(durations(end-sel_trials+1:end));
%     stats.duration_med = median(durations);
    
    % check effect of force
    force = calculate_fs_force(fs1s,pp);
    force = ((force(idx)));
%     stats.force_top = median(force(1:sel_trials));
%     stats.force_bottom = median(force(end-sel_trials+1:end));
%     stats.force =  median(force);
    
    [areas] = calculate_fs_area_full(fs1s,pp);
    areas = ((areas(idx)));
%     stats.areas_top = median(areas(1:sel_trials));
%     stats.areas_bottom = median(areas(end-sel_trials+1:end));
%     stats.areas = median(areas);
    
    [areas_short] = calculate_fs_area_short(fs1s,pp);
    areas_short = ((areas_short(idx)));
%     stats.areas_short_top = median(areas_short(1:sel_trials));
%     stats.areas_short_bottom = median(areas_short(end-sel_trials+1:end));
%     stats.areas_short = median(areas_short);
% end
end