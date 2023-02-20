%% calculated correlation between top x percentage erp and basis
corrmatrix = [];
preparation=1;
for percentage =1:10
    for k=1:selected_k
        count = 1;
        for clus=1:size(cluster_res,1)
            if cluster_res(clus) == k
                pp = pps_in_cluster(clus);
                r = ranks_in_cluster(clus);
                W = stable_basis{pp};
                H = full(stable_loadings{pp});
                
                erp_ersp_data = fs1s{pp,4};
                [chan] = sel_most_prevalent_chan(EEG,erp_ersp_data,preparation);
                [~,idx] = sort(H(r,:), 'descend');
                
                sorted_trials = squeeze(erp_ersp_data(chan,selected_time,idx));
                n_trials = size(sorted_trials,2);
                sel_trials = ceil(n_trials*percentage*10/100);
                erp = squeeze(trimmean(sorted_trials(:,1:sel_trials),20,2));
                
                basis_r = W(:,r);
                CORR = corrcoef(zscore(erp),basis_r');
                corrmatrix(k,percentage,count) = CORR(2);
                count = count+1;
            end
        end
    end
end
%%
pps = [];
for k=1:selected_k
    count = 1;
    for clus=1:size(cluster_res,1)
        if cluster_res(clus) == k
            pp = pps_in_cluster(clus);
            pps(k,1:10,count) = pp;
            count = count+1;
        end
    end
end
%% plot correlation matrix 
figure;
tiledlayout(7,1)
for i=1:selected_k
    nexttile
    res = zeros(10,23) -0.1;
    clus1 = squeeze(corrmatrix(i,:,:));
    clus1(clus1 == 0) = nan;
    corrs = rmmissing(clus1,2);
    
    tmp = squeeze(pps(i,:,:));
    tmp(tmp == 0) = nan;
    pp_tmp = rmmissing(tmp,2);
    
    res(:,pp_tmp(1,:)) = corrs.^2;
    imagesc(res, [-0.1,1])
    colorbar
    cmap = colormap('jet');
    cmap(1,:) = 1;
    colormap(cmap)
    set(gca, 'visible', 'off')
%     set(gca, 'FontSize', 18)
%     ylabel('Percentage')
%     xlabel('Subject')
%     title(sprintf('Cluster %d',i))
end
%%
med_percentage = zeros(10,1);
med_sel_trials_n = zeros(10,1);
for r=1:10
    med_percentage(r) = median(corrmatrix(:,r,:), 'all');
    med_sel_trials_n(r) = median(cellfun(@(x) ceil(size(x,3)*r*10/100),fs1s(:,4)));
end
figure; plot(med_percentage); yyaxis right; plot(med_sel_trials_n);
legend('Median correlation', 'Number of trials', 'Location', 'southoutside')