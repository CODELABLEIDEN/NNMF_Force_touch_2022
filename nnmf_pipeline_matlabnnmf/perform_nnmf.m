function [W,H,D] = perform_nnmf(data, k,options)
%% Perform nmf on ERSP data
%
% **Usage:**
%   - [W,H,D,train_err,test_err] = perform_nmf(data, k,options)
%   - perform_nmf(..., 'split', 0.8)
%
%  Input(s):
%   - data = preprocessed ersp data shape: channels x frequencies x time x participants
%   - k = rank of factors
%   - options.split_percent **optional** = train test split percentage
%   - options.replicates **optional** = number of replicates for nnmf algorithm (see nnmf function documentation)
%
%
%  Output(s):
%   - H = Basis/H contains frequency information shape: channels x k x frequencies x participants
%   - W = Loadings/W contains time information shape: channels x time x k x participants
%   - D = Root mean square residual shape: channels x participants
%
% Author: Enea Ceolini, R.M.D. Kock
%

arguments
    data {mustBeNonnegative};
    k {mustBePositive};
    options.replicates (1,1) = 100;
    options.create_seed logical = 1;
end

if options.create_seed
    % seeding NMF
    opt = statset('MaxIter',100);
    [W0, H0] = nnmf(data, k,'Replicates',options.replicates, 'Algorithm','mult');
    
    % actual NMF
    opt = statset('Maxiter',1000);
    [W, H, D] = nnmf(data, k,'W0',W0,'H0',H0, 'Algorithm','als', 'Replicates',options.replicates);
else
    opt = statset('Maxiter',1000);
    [W, H, D] = nnmf(data, k, 'Algorithm','als', 'Replicates',options.replicates);
end
end