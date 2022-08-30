function plot_sel_trials(basis,loadings,erp_data,k,time_range,chan,pp, options)
arguments
    basis;
    loadings;
    erp_data;
    k;
    time_range;
    chan;
    pp;
    options.percentage = 20;
    options.order = 'descend'; 
    options.start logical = 1;
end
figure;
tiledlayout(3,k)

if options.start
    erp_idx_trials = 4;
else
    erp_idx_trials = 7;
end

nexttile([1,k])
plot(time_range, zscore(trimmean(squeeze(erp_data{pp,erp_idx_trials}(chan,time_range+2000,:)),20, 2)));
hold on
l(1) = plot(nan,nan, 'Color', 'b');
l(2) = plot(nan,nan, 'Color', [0, 0, 0]);
l(3) = plot(nan,nan, 'Color',  [1, 0, 0]);
l(4) = plot(nan,nan, 'Color',  '#7E2F8E');
legend(l,{'ERP all trials', sprintf('Sorted top %d %% trials',options.percentage), sprintf('ERP sorted top %d %% trials',options.percentage), 'NNMF'})
box off

for r=1:k
    [~,idx] = sort(loadings(r,:), options.order);
    sorted_trials = erp_data{pp,erp_idx_trials}(chan,time_range+2000,idx);
    n_trials = size(sorted_trials,3);
    sel_trials = ceil(n_trials*options.percentage/100);
    nexttile([2,1])
%     plot(time_range, zscore(squeeze(sorted_trials(:,:,1:sel_trials))), 'Color', [0, 0, 0, 0.1])
%     hold on
%     plot(time_range, zscore(trimmean(squeeze(sorted_trials(:,:,1:sel_trials)),20,2)), 'Color', [1, 0, 0])
%     plot(time_range, zscore(basis(:,r)), 'Color',  '#7E2F8E', 'LineWidth', 3);
    
    plot(time_range,trimmean(squeeze(sorted_trials(:,:,1:sel_trials)),20,2), 'Color', [1, 0, 0])
    yyaxis right
    plot(time_range, basis(:,r), 'Color',  '#7E2F8E', 'LineWidth', 3);
    box off
    title(sprintf('Rank : %d',r))
end
sgtitle(sprintf('Electrode: %d -- Subject : %d -- n trials : %d',chan, pp, sel_trials))
end