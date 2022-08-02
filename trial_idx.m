function [trial_times] = trial_idx(loadings,erp,k,time_range,chan,pp, options)
arguments
    loadings;
    erp;
    k;
    time_range;
    chan;
    pp;
    options.percentage = 20;
    options.order = 'descend'; 
end

n_trials = size(loadings{chan,pp}(1,:),2);
sel_trials = ceil(n_trials*options.percentage/100);
trial_times = {};

for r=1:k
    all_trials = zeros(1,n_trials);
    [~,idx] = sort(loadings{chan,pp}(r,:), options.order);
    all_trials(idx(1:sel_trials)) = 1;
    % binary rank selection of trials (1 the trial was selected for this rank)
    trial_times{r, 1} = all_trials;
    
    % get midpoint indices of all forcesensor trials
    trials = erp{pp,9};
    trials(erp{pp,12}) = NaN;
    trials = rmmissing(trials);
    
    % create binary time
    all_trial_times = zeros(1,length(erp{pp,13}));
    times_ms = trials(idx(1:sel_trials));
    all_trial_times(times_ms) = 1;
    
    % binary trials in full time period
    trial_times{r, 2} = all_trial_times;
    % ms selected trials
    trial_times{r, 3} = times_ms;
    % timing of all trials
    trial_times{r, 4} = trials;  
    trial_times{r, 5} = idx;
    trial_times{r, 6} = sel_trials;    
end
end