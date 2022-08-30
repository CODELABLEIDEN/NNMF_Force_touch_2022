options.order = 'descend';
duration_rel = {};
% for percent=10:10:100
for pp=1:1
    %             figure;
    %             tiledlayout(1,best_k_overall)
    for r=1:best_k_overall
        [sorted_loads,idx] = sort(loadings{chan,pp}(r,:), options.order);
        trials_diffs = fs1s{pp,10}-fs1s{pp,8};
        trials_diffs(fs1s{pp,12}) = NaN;
        trials_diffs = rmmissing(trials_diffs);
        durations = trials_diffs(idx);
        %             duration_rel{r,percent,pp,1} = sorted_loads;
        %             duration_rel{r,percent,pp,2} = durations;
        sel_trials = ceil(length(durations)*options.percentage/100);
        %                     nexttile
        %                     scatter(sorted_loads(1:sel_trials), durations(1:sel_trials))
        %             duration_rel{r,percent,pp,3} = median(durations(1:sel_trials));
    end
    %     end
end
%%
figure;
t = tiledlayout(1,best_k_overall);
for r=1:best_k_overall
    med_duration = cell2mat(squeeze(duration_rel(r,:,:,3)));
    nexttile
    imagesc(med_duration);
    title(sprintf('rank %d',r))
    yticklabels([10:10:100])
end

colormap('jet')
ylabel(t, 'Percentage');
xlabel(t, 'Subjects');
colorbar;
%% durations
all_durations = {};
for pp=1:size(fs1s,1)
    durations = fs1s{pp,10}-fs1s{pp,8};
    durations(fs1s{pp,11}) = NaN;
    durations = rmmissing(durations);
    all_durations{pp} = durations;
end
d=cat(1,[all_durations{:}]);
cutoff = quantile(d(d<3000), 0.9);
%%
% preparation_time = 1500:2100;
n_participants = size(fs1s,1);
durations = {};
for pp=1:n_participants
%     [most_sensorimotor] = sel_most_sensorimotor_chan(EEG,fs1s{pp,3}(:,idx),sensorimotor);
    [sorted_durations, idx] = sort(all_durations{pp});
    sorted_trials = squeeze(fs1s{pp,4}(16,:,idx));
    percentage = 30;
    time_range = [-2000:1999];
    
    durations{pp,1} = sorted_durations;
    durations{pp,2} = sorted_trials;
    
    figure;
    tiledlayout(2,2)
    top_med_durations = median(sorted_durations(:,1:ceil(length(idx)*(percentage/100))));
    nexttile;
    % plot(time_range,sorted_trials(:,1:ceil(length(idx)*(percentage/100))), 'color', [0 0 0 0.2])
    hold on;
    plot(time_range,mean(sorted_trials(:,1:ceil(length(idx)*(percentage/100))),2), 'r')
    xline(300)
    title(sprintf('Top %d percent durations - Median %d',percentage,top_med_durations))
    
    nexttile;
    bottom_med_durations = median(sorted_durations(length(idx)-ceil(length(idx)*(percentage/100)):end));
    % plot(time_range,sorted_trials(:,length(idx)-ceil(length(idx)*(percentage/100)):end), 'color', [0 0 0 0.2])
    hold on;
    plot(time_range,mean(sorted_trials(:,length(idx)-ceil(length(idx)*(percentage/100)):end),2), 'r')
    xline(300)
    title(sprintf('Bottom %d percent durations - Median %d',percentage,round(bottom_med_durations)))
    sgtitle(sprintf('Subject %d', pp))
    
    nexttile([1,2]);
    histogram(sorted_durations)
end
%%
all_d = cat(1,[durations{:,1}]);
all_erps = cat(1,[durations{:,2}]);
[sorted,idxs] = sort(all_d, 'descend');
figure
plot([-2000:1999],mean(all_erps(:,idxs(sorted > 10 & sorted < 200)),2));
hold on
plot([-2000:1999],mean(all_erps(:,idxs(sorted >= 300)),2));
legend({sprintf('Duration < 200 n=%d',length(idxs(sorted > 10 & sorted < 200))), sprintf('Durations > 300 n=%d',length(idxs(sorted >= 300)))})
xline(300)
title('ERP ch 16')