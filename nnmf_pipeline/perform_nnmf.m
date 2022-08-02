function [W,H] = perform_nnmf(non_neg_data, k)
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
%
% Author: 
%

arguments
    non_neg_data {mustBeNonnegative};
    k {mustBePositive};
end

%% settings NNMF
lambda = 0;        % sparsity control for the coefficients alpha
gamma1 = 0;        % sparsity control on the dictionary patterns 

param.mode = 2;
param.K=k;
param.lambda=lambda;
param.numThreads=-1;
param.batchsize=min(1024,size(non_neg_data,2));
param.posD = true;   % positive dictionary
param.iter = 500;  % number of iteration
param.modeD = 0;
param.verbose = 0; % print out update information?
param.posAlpha = 1; % positive coefficients
param.gamma1 = gamma1; % penalizing parameter on the dictionary patterns

D0 = dictLearnInit(non_neg_data, k);
param.D = D0;

W = mexTrainDL(non_neg_data, param);
for kidx = 1:k
    W(:,kidx) = W(:,kidx)/max(W(:,kidx));
end
H = mexLasso(non_neg_data,W,param);

end