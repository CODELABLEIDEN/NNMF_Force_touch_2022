function [jid, xi,si] = plot_jid_FS(trial_times, k)
figure; 
tiledlayout(1,k)
for r=1:k
si = cell2mat(cellfun(@(x) find(trial_times{r,4} == x), num2cell(sort(trial_times{r,3})), 'UniformOutput', false));

si_tmp = [];
si_tmp(1,:) = si;
si_tmp(2,:) = si+1;
si_tmp(3,:) = si+2; 
si_tmp = si_tmp(:);
x = trial_times{r,4};
si_sel = unique(x(si_tmp(si_tmp<max(si))));
[jid, bin_edges,xi] = taps2JID(si_sel, 'Bins', 50);
nexttile
imagesc(xi(:,1), xi(:,2),jid, [0,4])
set(gca, 'YDir', 'normal')
title(sprintf('rank %d',r))

[~,max_jid_idx] = max(jid, [],'all', 'linear');
[r,c] =ind2sub(size(jid),max_jid_idx)
end
colorbar
end