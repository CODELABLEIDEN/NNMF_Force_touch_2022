% options.bandpass_upper = 3;
% options.bandpass_lower = 0.5;
% EEG = gettechnicallycleanEEG(EEG,options.bandpass_upper,options.bandpass_lower);
% [filtered, base,start_indices,mid_indices,end_indices,BS] = preprocess_FS(EEG);
% [EEG] = add_events(EEG,start_indices,length(start_indices),'FS_start');
% [EEG_epoched_start] = pop_epoch(EEG, {'FS_start'},options.epoch_window_ms/1000);
% erp = trimmean(EEG_epoched_start.data(:,:,:),20,3);
%%
EEG.chanlocs = EEG.chanlocs(1:62);
% start
erp = squeeze(mean(fs1s{pp,:}(1:62,:,:),3));
% mid
% erp = fs1s{pp,5};

timepoints = [1500 1750 1800 1900 2000 2250 2500 2750];
figure; tiledlayout(2,length(timepoints));
for time=1:length(timepoints)
    nexttile;
    topoplot(erp(:,timepoints(time)), EEG.chanlocs);
    title(sprintf('ERP - %d ms', timepoints(time)-2000))
end
for time=1:length(timepoints)
    nexttile;
    topoplot(laplacian_perrinX(erp(:,timepoints(time)), [EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]), EEG.chanlocs);
    title(sprintf('Laplacian ERP - %d ms', timepoints(time)-2000))
end
% start
sgtitle('Start FS')
% mid
% sgtitle('Mid FS')
%%
x = zeros(64, 4000, 25);
for i=1:size(fs1s,1)
    x(:,:,i) = fs1s{i,3};
end
erp = trimmean(x, 20,3);
%% 
figure;
range_time = [1:size(erp,2)];
extreme = max(abs(floor(min(erp,[],'all'))), ceil(max(erp,[],'all')));
mean_lims = [-extreme, extreme];

v = VideoWriter(sprintf('%s.avi', 'laplacian'));
v.FrameRate = 30;
open(v)

for i = range_time
    tiledlayout(1,2);
    ax1 = nexttile;
    topoplot(erp(:,i), EEG.chanlocs , 'whitebk', 'on', 'electrodes', 'off', 'maplimits', mean_lims, 'colormap', colormap('jet'));
%     title(mean_plot_title);
    freezeColors;
    colorbar(ax1, 'Location', 'eastoutside', 'limits', mean_lims);

    % topoplot
    hold off;
    ax2 = nexttile;
    topoplot(laplacian_perrinX(erp(:,i), [EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]), EEG.chanlocs, 'whitebk', 'on', 'electrodes', 'off', 'maplimits', [-30 30],  'colormap', colormap('jet'));
    title([{'Laplacian'}]);
    %colorbar
    hold on 
    ax2 = colorbar('Location', 'eastoutside', 'limits', [-30 30]);
    
    sgtitle(sprintf('%d ms', i-(max(range_time/2))), 'FontSize', 40);
    set(gcf,'color','w');
    M =getframe(gcf);
    writeVideo(v,M);
    clf;
%     idx = idx + 1;
end
close(v);