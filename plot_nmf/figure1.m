%% select electrode and plot selected electrode
erp_ersp_data = fs1s{4,4};
[chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
elecs = zeros(1,64);
elecs(chan)=1;
figure; topoplot(elecs, EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')
%% lines trials method figure
figure;
n_trials_plot = 1:20;
set(gca, 'LineWidth', 2)
strips(erp_ersp_data(chan,selected_time,n_trials_plot), 601)
set(gca, 'visible', 'off')
% grid on
% xticks(1:601)
% h=gca; 
% h.XAxis.TickLength = [0 0];
% h.YAxis.TickLength = [0 0];
% yticklabels(flip(n_trials_plot))
% xticklabels(-500:100:100)

%% spectrogram trials method figure
figure;
imagesc(time_range, 1:size(erp_ersp_data,3),squeeze(erp_ersp_data(chan,selected_time,:))')
colorbar
h=gca; 
h.XAxis.TickLength = [0 0];
h.YAxis.TickLength = [0 0];
box off
set(gca, 'FontSize', 18)
y2 = ylim;
ylim([1 y2(2)])
%%
% for pp=1:size(fs1s,1)
pp=4;
    for r=1:size(stable_basis{pp},2)
        W = stable_basis{pp}(:,r);
        min_w = floor(min(full(stable_basis{pp}), [],'all'));
        max_w = ceil(max(full(stable_basis{pp}), [],'all'));
        H = stable_loadings{pp}(r,:);
        min_h = floor(min(full(stable_loadings{pp}), [],'all'));
        max_h = ceil(max(full(stable_loadings{pp}), [],'all'));
        f1 = figure;
        plot(W', 'LineWidth', 4)
        set(gca, 'visible', 'off')
        saveas(f1,sprintf('/home/ruchella/variable_activation/results/figures/nnmf/line_pp_%d_rank_%d.svg',pp,r))
        
        f2 = figure;
        imagesc(W',[min_w max_w])
        xline(500, 'r--')
        set(gca, 'visible', 'off')
        saveas(f2,sprintf('/home/ruchella/variable_activation/results/figures/nnmf/meta_erp_pp_%d_rank_%d.svg',pp,r))
        
        f3 = figure;
        imagesc(H',[min_h max_h])
        set(gca, 'visible', 'off')
        saveas(f3,sprintf('/home/ruchella/variable_activation/results/figures/nnmf/meta_trials_pp_%d_rank_%d.svg',pp,r))
        close(f1)
        close(f2)
        close(f3)
    end
% end
%% plot lineplots erp with all trials per pp
for pp=1:size(fs1s,1)
    erp_ersp_data = fs1s{pp,4};
    n_trails = size(erp_ersp_data,3);
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
%     x = squeeze(trimmean(erp_ersp_data(:,:,:),20,3));
%     h = create_topoplot(x, EEG, 'jet',0, 'lims', [-5,5]);
    
    
    f = figure;
    plot(time_range,squeeze(erp_ersp_data(chan,selected_time,:)), 'Color', [0, 0, 0, 0.1])
    set(gca, 'FontSize', 18)
    lims = ylim;
    rectangle('Position', [-500 lims(1) 600 lims(2)+abs(lims(1))-0.00001], 'FaceColor', [0 0 1  alpha], 'EdgeColor', 'none')
    
    ylabel(sprintf('ERP trials (%sV)', (char(181))))
    yyaxis right
    plot(time_range, squeeze(trimmean(erp_ersp_data(chan,selected_time,:),20,3)), 'b', 'LineWidth', 2)
    ylabel(sprintf('Average ERP (%sV)', (char(181))))
    xline(0, '--', 'LineWidth', 2)
    box off;
    g=gca;
    g.YAxis(2).Color = 'b';
    xlabel('Latency from touch iniation (ms)')
    set(gca, 'FontSize', 18)
    title(sprintf('Subject: %d - Number of trials: %d',pp,n_trails), 'FontSize', 15)
    saveas(f,sprintf('/home/ruchella/variable_activation/results/figures/erps/pp_%d.svg',pp))
    print(sprintf('/home/ruchella/variable_activation/results/figures/erps/pp_%d.pdf',pp),'-dpdf');
    close(f)
end
%% plot topoplots erp
% set(0,'DefaultFigureWindowStyle','docked')
for pp=1:size(fs1s,1)
% for pp=1:1
    erp_ersp_data = fs1s{pp,4};
    tmp_erp_data = squeeze(trimmean(erp_ersp_data(:,:,:),20,3));
    h = create_topoplot(tmp_erp_data, EEG, 'jet',0, [-5 5]);
    saveas(h,sprintf('/home/ruchella/variable_activation/results/figures/topoplot_erps/topo_pp_%d.svg',pp))
    print(sprintf('/home/ruchella/variable_activation/results/figures/topoplot_erps/topo_pp_%d.pdf',pp),'-dpdf');
    close(h)
end
%% plot average FS Shape
epoched_fs = [];
for pp=1:size(fs1s,1)
    [fs_filtered] = fs_filter_noise(fs1s{pp,13});
    start_idx  = fs1s{pp,8};
    start_idx(fs1s{pp,removed_trials_idx}) = NaN;
    start_idx = rmmissing(start_idx);
    epoched_fs_tmp = getepocheddata(fs_filtered, start_idx, [-100 300]);
    [durations] = calculate_fs_durations(fs1s,pp);
    similar_durations = durations >= 200 & durations <=220;
    epoched_fs = cat(1,epoched_fs,epoched_fs_tmp(similar_durations,:));
end
average_fs_shape = mean(epoched_fs, 1);
figure; plot([-100:300],average_fs_shape, 'k', 'LineWidth', 2)
xline(0);
box off;
xlabel('Latency from touch initiation (ms)')
ylabel('Force (V)')
set(gca, 'FontSize', 18)