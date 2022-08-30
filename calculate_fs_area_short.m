function [areas,count] = calculate_fs_area_short(fs1s,pp, options)
arguments
    fs1s;
    pp;
    options.start logical= 1;
    options.range = 10;
end

if options.start
    removed_trials_idx = 11;
else
    removed_trials_idx = 12;
end
[fs_filtered] = fs_filter_noise(fs1s{pp,13});
end_idx = fs1s{pp,10};
end_idx(fs1s{pp,removed_trials_idx}) = NaN;
end_idx = rmmissing(end_idx);
start_idx  = fs1s{pp,8};
start_idx(fs1s{pp,removed_trials_idx}) = NaN;
start_idx = rmmissing(start_idx);
areas = zeros(length(start_idx),1);

count=0;
for trial=1:length(start_idx)
    if end_idx(trial)-start_idx(trial) < options.range
        options.range = ceil((end_idx(trial)-start_idx(trial)) * 50 / 100);
        count = count+1;
    end
    selected_duration = start_idx(trial)+options.range;
    areas(trial) = trapz(fs_filtered(start_idx(trial):selected_duration));
end
