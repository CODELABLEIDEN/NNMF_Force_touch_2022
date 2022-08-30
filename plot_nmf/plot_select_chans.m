figure; 
tiledlayout(4,2)

selected_time = 1500:2100;
all_channels_prep = zeros(25,1);
for pp=1:25 
    erp_ersp_data = fs1s{pp,4};
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),1);
    all_channels_prep(pp) = chan;
end

nexttile([3,1])
h = histogram(all_channels_prep, 64);
h.BinLimits = [0, 64];
ylim([0,18])
title('Prep')


selected_time = 2100:2500;
all_channels_cons = zeros(25,1);
for pp=1:25 
    erp_ersp_data = fs1s{pp,4};
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),0);
    all_channels_cons(pp) = chan;
end
nexttile([3,1])
h = histogram(all_channels_cons, 64);
h.BinLimits = [0, 18];
ylim([0,20])
title('Cons')

nexttile
topoplot(unique(all_channels_prep), EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')
%
nexttile
topoplot(unique(all_channels_cons), EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')
%%
