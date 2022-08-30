options.order = 'descend'; options.percentage = 20;
corrmatrix = zeros([size(basis), best_k_overall]);
for chan=1:size(basis,1)
    for pp=1:size(basis,2)
        for r=1:best_k_overall
            [sorted_loads,idx] = sort(loadings{chan,pp}(r,:), options.order);
            sorted_trials = fs1s{pp,7}(chan,:,idx);
            n_trials = size(sorted_trials,3);
            sel_trials = ceil(n_trials*options.percentage/100);                      
            x = trimmean(squeeze(sorted_trials(:,:,1:sel_trials)),20,2);
            y = basis{chan,pp}(:,r);
            corrmatrix(chan,pp,r) = corr(x,y);
        end
    end
end
%%
% trials_diffs = fs1s{pp,10}-fs1s{pp,8};
% trials_diffs(fs1s{pp,12}) = NaN;
% trials_diffs = rmmissing(trials_diffs);
% durations = trials_diffs(idx);
%%
figure; 
t = tiledlayout(1,best_k_overall);
for r=1:best_k_overall
    nexttile
    imagesc(squeeze(corrmatrix(:,:,r)), [0,1]);
    title(sprintf('rank %d',r))
end

colormap('jet')
ylabel(t, 'Electrodes');
xlabel(t, 'Subjects');
colorbar;