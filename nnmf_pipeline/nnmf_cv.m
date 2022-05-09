function [basis, loadings, train_err, test_err] = nnmf_cv(data,options)
arguments
    data (:,:) {mustBeNonnegative};
    options.repetitions {mustBePositive} = 3;
    options.n_ranks {mustBePositive} = 15;
    options.split_percent (1,1) double = 0.8;
    options.replicates (1,1) = 100;
    options.create_seed logical = 1;
end

% make sure k is not larger than the input data
if (min(size(data)) <= options.n_ranks)
    options.n_ranks = min(size(data)) - 1;
end

train_err = cell(options.repetitions,options.n_ranks);
test_err = cell(options.repetitions,options.n_ranks);
basis = cell(options.repetitions,options.n_ranks);
loadings = cell(options.repetitions,options.n_ranks);

for rep = 1:options.repetitions
    parfor k = 1:options.n_ranks
        % create mask
        mask = rand(size(data)) > (1 - options.split_percent);
        masked_nne = data .* mask;
        
        [W, H] = perform_nnmf(masked_nne, k, 'replicates', options.replicates, 'create_seed', options.create_seed);
        basis{rep,k} = W;
        loadings{rep,k} = H;
        % reconstruction
        recon = W * H;
        train_err{rep,k} = sum(((recon - data) .* mask) .^ 2, [1, 2]) / sum(mask, [1,2]);
        test_err{rep,k} = sum(((recon - data) .* ~mask) .^ 2, [1, 2]) / sum(~mask, [1,2]);
    end
end
end