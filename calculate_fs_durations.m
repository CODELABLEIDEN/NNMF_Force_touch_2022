function [durations] = calculate_fs_durations(fs1s,pp, options)
arguments
    fs1s;
    pp;
    options.start logical= 1;
end
durations = fs1s{pp,10}-fs1s{pp,8};
if options.start
    durations(fs1s{pp,11}) = NaN;
else
    durations(fs1s{pp,12}) = NaN;
end
durations = rmmissing(durations);
end