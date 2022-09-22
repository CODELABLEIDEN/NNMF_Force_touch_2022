function [force] = calculate_fs_force(fs1s,pp, options)
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

% [fs_filtered] = fs_filter_noise(fs1s{pp,13});
trials = fs1s{pp,8};
trials(fs1s{pp,removed_trials_idx}) = NaN;
trials = rmmissing(trials);
force = zeros(size(trials)); 
for trial=1:length(trials)
    force(trial) = max(fs1s{pp,13}(trials(trial):trials(trial)+5));
end
end