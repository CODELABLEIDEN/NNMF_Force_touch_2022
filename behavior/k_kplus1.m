%% Regression on behavioral features (level 1)
cluster_model = {};
for k=1:1
    count = 1;
    for i=1:size(basis_all_pps,2)
        features = [];
        if cluster_res(i) == k
            pp = pps_in_cluster(i);
            r = ranks_in_cluster(i);
            
            erp_ersp_data = fs1s{pp,4};
            W = stable_basis{pp};
            H = stable_loadings{pp};
            %             [sorted_loads,idx] = sort(H(r,:), 'descend');
            %             [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
            BINS = 50;
            MIN_H = 1.5;
            MAX_H = 5;
            bandwidth = 0.1;
            
            H = full(H);
            dt_dt = [H(r,1:end-1)', H(r,2:end)'];
            
            gridx = linspace(MIN_H, MAX_H, BINS);
            bin_edges = 10 .^ gridx;
            
            [x1, x2] = meshgrid(gridx, gridx);
            x1 = x1(:);
            x2 = x2(:);
            xi = [x1 x2];
            
            jid = reshape(ksdensity(dt_dt,xi, 'Bandwidth', bandwidth), BINS, BINS);
            figure; imagesc(xi(:,1), xi(:,2),jid)
            set(gca, 'YDir', 'normal')
            title(sprintf('Subject %d',pp))
            colorbar
        end
    end
end
%%
set(0,'DefaultFigureWindowStyle','docked')
count = 1;
for pp=1:size(fs1s,1)
    erp_ersp_data = fs1s{pp,4};
    W = stable_basis{pp};
    H = stable_loadings{pp};
    fig = figure;
    tiledlayout(1,size(H,1));
    for r=1:size(H,1)
        nexttile;
        scatter(H(r,1:end-1), H(r,2:end))
        xlim([floor(min(H, [], 'all')) ceil(max(H, [], 'all'))]);
        ylim([floor(min(H, [], 'all')) ceil(max(H, [], 'all'))]);
        clus = cluster_dict(cluster_res(count));
        title({sprintf('Rank : %d',r),sprintf('Cluster : %s',clus{1})},'FontSize',13)
        axis square
        count = count+1;
        box off;
        set(gca,'FontSize',15);
    end
    
    sgtitle(sprintf('Subject %d' ,pp),'FontSize',18)
    saveas(fig, sprintf('/home/ruchella/variable_activation/results/figures/k_kplus1/s%d',pp), 'svg')
    print(sprintf('/home/ruchella/variable_activation/results/figures/k_kplus1/s%d',pp),'-dpdf','-fillpage')
end
