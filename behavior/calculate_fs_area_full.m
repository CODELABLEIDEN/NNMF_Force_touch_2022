function [areas] = calculate_fs_area_full(fs1s,pp, options)
arguments
    fs1s;
    pp;
    options.start logical= 1;
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

for trial=1:length(start_idx)
    areas(trial) = trapz(fs_filtered(start_idx(trial):end_idx(trial)));
end