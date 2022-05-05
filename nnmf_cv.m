channels = 64;
time_range = 2500;

split = 0.8;
repetitions = 3;
n_ranks = 15;

basis = cell(size(fs1s,1),channels, repetitions, n_ranks);
loadings = cell(size(fs1s,1),channels, repetitions, n_ranks);
train_err = zeros(size(fs1s,1),channels, n_ranks,repetitions);
test_err = zeros(size(fs1s,1),channels, n_ranks,repetitions);

parfor pp =1:size(fs1s,1)
    tmp_pp = fs1s{pp,7};
    for chan=1:channels
        for rep = 1:repetitions
            for r = 1:n_ranks
                tmp_pp_chan = squeeze(tmp_pp(chan,:,:));
                local_min = abs(ceil(min(tmp_pp_chan,[], 'all')));
                shifted_ma = tmp_pp_chan+local_min;
                
                mask = rand(size(shifted_ma)) > (1 - split);
                masked_a = shifted_ma .* mask;
            
                % seed NMF
                opt = statset('MaxIter',100);
                [W0, H0] = nnmf(masked_a,r,'Replicates',100, 'Options',opt, 'Algorithm','mult');
                
                % actual NMF
                opt = statset('Maxiter',1000);
                [W, H] = nnmf(masked_a, r,'W0',W0,'H0',H0, 'Options',opt, 'Algorithm','als', 'Replicates',100);
                
                basis{pp,chan, rep, r} = zscore(H);
                loadings{pp, chan, rep, r} = zscore(W);
                
                % reconstruction 
                recon_a = W * H;
                train_err(pp, chan, r, rep) = sum(((recon_a - shifted_ma) .* mask) .^ 2, [1, 2]) / sum(mask, [1,2]);
                test_err(pp, chan, r, rep) = sum(((recon_a - shifted_ma) .* ~mask) .^ 2, [1, 2]) / sum(~mask, [1,2]);  
            end
        end
    end
end
