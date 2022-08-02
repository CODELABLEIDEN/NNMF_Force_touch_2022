function [basis, loadings, train_err, test_err] = nnmf_cv(data,options)
arguments
    data (:,:) {mustBeNonnegative};
    options.repetitions {mustBePositive} = 3;
    options.n_ranks {mustBePositive} = 10;
    options.split_percent (1,1) double = 0.8;
    options.replicates (1,1) = 100;
    options.create_seed logical = 1;
    options.z_score logical = 1;
end

% make sure k is not larger than the input data
if (min(size(data)) <= options.n_ranks)
    options.n_ranks = min(size(data)) - 1;
end

train_err = cell(options.repetitions,options.n_ranks-1);
test_err = cell(options.repetitions,options.n_ranks-1);
basis = cell(options.repetitions,options.n_ranks-1);
loadings = cell(options.repetitions,options.n_ranks-1);

for rep = 1:options.repetitions
    for k = 2:options.n_ranks
        % create mask
        mask = rand(size(data)) > (1 - options.split_percent);
        masked_nne = data .* mask;
        
        [W, H] = perform_nnmf(masked_nne, k, 'replicates', options.replicates, 'create_seed', options.create_seed);
        if options.z_score
            basis{rep,k-1} = zscore(W);
            loadings{rep,k-1} = zscore(H);
        else
            basis{rep,k-1} = W;
            loadings{rep,k-1} = H;
        end
        % reconstruction
        recon = W * H;
        train_err{rep,k-1} = sum(((recon - data) .* mask) .^ 2, [1, 2]) / sum(mask, [1,2]);
        test_err{rep,k-1} = sum(((recon - data) .* ~mask) .^ 2, [1, 2]) / sum(~mask, [1,2]);
    end
end
end