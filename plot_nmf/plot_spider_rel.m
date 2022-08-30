function plot_spider_rel(H,fs1s,trial_times,pp)
figure; 

data = zeros(size(H,1),4);
for r=1:size(H,1)
    [stats] = behavior_stats(H,fs1s,trial_times,r,pp);
    data(r,1) = stats.duration_top;
    data(r,2) = stats.force_top;
    data(r,3) = stats.areas_top;
    data(r,4) = stats.areas_short_top;
end
% min_area = min(floor(min(data(:,3))), floor(min(data(:,4))));
% max_area = max(ceil(max(data(:,3))), ceil(max(data(:,4))));
limits = [floor(min(data(:,1))) ceil(max(data(:,1))); floor(min(data(:,2))) ceil(max(data(:,2))); floor(min(data(:,3))) ceil(max(data(:,3))); floor(min(data(:,4))) ceil(max(data(:,4)))]';
nexttile
spider_plot(data, 'AxesLabels', {'duration', 'force', 'areas', 'areas short'}, 'AxesLimits', limits, 'FillOption', 'on')
end