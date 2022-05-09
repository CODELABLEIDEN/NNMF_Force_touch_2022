function plot_nnmf_erp_per_pp_chan(data,basis,k,time_range)
arguments 
    data;
    basis; 
    k (1,1) {mustBePositive}; 
    time_range ;
end
pp=3;
chan = 16;
figure;
tiledlayout(k,2)

for r=1:k
    %plot 1
    nexttile
    plot(time_range, basis{chan,pp}(:,r))
    xlabel('Latency from event (ms)')
    box off;
    [~,idx] = sort(loadings{chan,pp}(r,:));
    xline(0)
    %plot 2
    nexttile
    imagesc(time_range,[],zscore(squeeze(data(chan,:,idx,pp))',[],2));
    ylabel('Trials')
    xlabel('Latency from event (ms)')
    box off;
    colorbar
    xline(0)
    title(sprintf('Rank: %d',r))
end
sgtitle(sprintf('Subject: %d - Electrode: %d',pp, chan))