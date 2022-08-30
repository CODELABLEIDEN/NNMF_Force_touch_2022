% get data
for pp=5
    erp_ersp_data = fs1s{pp,4};
    [W, H] = stable_nnmf(basis_all,loadings_all, pp);
    %%
    k = size(W,2);
    if preparation
        selected_time = 1500:2100;
        topotimes = [1500:100:2100];
        time_range = -500:100;
    else
        selected_time = 2100:2500;
        topotimes = [2100:100:2500];
        time_range = 100:500;
    end
    %%
    percentage = 20;
    %%
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
%     [durations] = calculate_fs_durations(fs1s,pp);
    [trial_times] = trial_idx(H,fs1s,k,time_range,chan,pp);
    [stats, durations, force, areas, areas_short, idx] = behavior_stats(H,fs1s,trial_times,r,pp);
    
    %%
%     plot_FS_nmf_per_p(W,H,fs1s,k,time_range,chan,pp);
%     plot_sel_trials(W,H,fs1s,k,time_range,chan,pp, 'percentage', percentage, 'order', 'descend');
%     %%
%     figure;
%     tiledlayout(k,length(topotimes))
%     n_trials = size(H,2);
%     for r=1:k
%         [sorted, idx] = sort(H(r,:), 'descend');
%         sel_trials = ceil(n_trials*50/100);
%         for time=topotimes
%             nexttile
%             erp = trimmean(fs1s{pp,4}(:,time, idx(1:sel_trials)),20,3);
%             maplims = [-ceil(max(min(erp),max(erp))), ceil(max(min(erp),max(erp)))];
%             topoplot(erp, EEG.chanlocs, 'maplimits', maplims)
%             title(sprintf('%d ms',time-2000))
%         end
%     end
%     
% 
%     % check if selected trials vary across ranks
%     figure; tiledlayout(k,1);
%     for r=1:k
%         nexttile;
%         plot(trial_times{r,2});
%     end
%     figure; 
%     imagesc(cell2mat(trial_times(:,1)));
%     title(sprintf('Subject %d',pp))
%     yticks([1:k])
%     ylabel('Rank')
%     xlabel('Trial')
%     
%     
% %     figure; 
% %     imagesc(cell2mat(force_r)')
% %     hcb = colorbar;
% %     title(sprintf('Subject %d',pp))
% %     yticks([1:best_k_overall])
% %     ylabel('Rank')
% %     xlabel('Trial')
% %     title(hcb, 'Force')
%     
%     
%     % explore effect of movement type
%     figure;
%     tiledlayout(k,1)
%     for r=1:k
%         nexttile
%         ep_blind_bs = getepocheddata(nanzscore(fs1s{pp,14}),[trial_times{r,3}],[-500 100]);
%         plot(time_range, ep_blind_bs')
%         title(sprintf('rank %d',r))
%     end
%     
%     % check effect of jid
%     [jid, xi,si] = plot_jid_FS(trial_times,k);
%     
%     % overall patterns
%     [s] = plot_behavior_no_sel(H,fs1s,k,trial_times,chan,pp);
end