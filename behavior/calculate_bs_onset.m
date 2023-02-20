function [bs_onset,changepoints] = calculate_bs_onset(fs1s, pp, options)
arguments
    fs1s;
    pp;
    options.start logical= 1;
    options.range = 10;
    options.start_epoch_window = -500;
    options.MaxNumChanges = 4;
    options.plot_fig = 0;
end

if options.start
    removed_trials_idx = 11;
else
    removed_trials_idx = 12;
end

options.start_epoch_window = -500;
end_epoch_window = abs(options.start_epoch_window);

start_idx  = fs1s{pp,8};
start_idx(fs1s{pp,removed_trials_idx}) = NaN;
start_idx = rmmissing(start_idx);

epoched_bs = getepocheddata(fs1s{pp,14}, start_idx, [options.start_epoch_window end_epoch_window]);
changepoints = zeros(size(epoched_bs,1),1);

for event=1:size(epoched_bs,1)
    ipt = findchangepts(epoched_bs(event,:),'MaxNumChanges',options.MaxNumChanges,'Statistic','std');
    if isempty(ipt)
        findchangepts(epoched_bs(event,:),'MaxNumChanges',options.MaxNumChanges,'Statistic','std')
        ipt = [0];
    end
    changepoints(event) = ipt(1);
    if options.plot_fig
        figure; plot([options.start_epoch_window:end_epoch_window],epoched_bs, 'Color', [0 0 0 0.2]);
        hold on;
        plot([options.start_epoch_window:end_epoch_window],trimmean(epoched_bs,20,1), 'LineWidth', 2)
        xline(0);
        figure;
        findchangepts(epoched_bs(event,:),'MaxNumChanges',options.MaxNumChanges,'Statistic','std')
        xline(end_epoch_window)
        xlim([1 end_epoch_window*2])
    end
end
bs_onset = end_epoch_window - changepoints;
sel = bs_onset > 0;
base = median(bs_onset(sel));
bs_onset(bs_onset < 0) = base;