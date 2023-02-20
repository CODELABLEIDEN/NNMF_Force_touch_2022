durations = [];
for pp=1:size(fs1s,1)
    duration = calculate_fs_durations(fs1s,pp);
    durations = [durations duration];
end
population_avg_duration = median(durations)