function [small_times] = jid_small_durations(fs1s, pp)
all_times  = fs1s{pp,8};
all_times(fs1s{pp,11})  = NaN;
all_times = rmmissing(all_times);

[durations] = calculate_fs_durations(fs1s,pp);
isequal(length(durations),length(all_times))

small_idx = durations < 20;
small_times = all_times(small_idx);

figure;

si = cell2mat(cellfun(@(x) find(all_times == x), num2cell(sort(small_times)), 'UniformOutput', false));

si_tmp = [];
si_tmp(1,:) = si;
si_tmp(2,:) = si+1;
si_tmp(3,:) = si+2;
si_tmp = si_tmp(:);
si_sel = unique(all_times(si_tmp(si_tmp<max(si))));
[jid, bin_edges,xi] = taps2JID(si_sel, 'Bins', 50);
imagesc(xi(:,1), xi(:,2),jid, [0,4])
set(gca, 'YDir', 'normal')
title(sprintf('Subject %d',pp))
colorbar

end