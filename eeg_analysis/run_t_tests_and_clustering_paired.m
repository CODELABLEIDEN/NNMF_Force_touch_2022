function [LIMO_paths] = run_t_tests_and_clustering_paired(unique_name, paired, tf, data1, data2, options)
%% Creates a placeholder cell with the datasets of all participants for plotting of results
%
% **Usage:** [erp_data, ams, nams] = preprocess_erp_data(erp_data, paired, min_num_trials)
%
% Input(s):
%   - unique_name = folder name to save the data and also added as a suffix to the file names
%   - paired (logical) = 1 if paired ttest is used and 0 if one sample ttest
%   - tf (logical) = 1 if time frequency analysis and 0 if erp analysis
%   - data1 = data for t test
%   - data2 (optional only required if paired is 1) = data for paired samples t test
%   - significance_threshold (name value argument default : 0.05) = threshold for bootstrap significance testing
%   - bootstrap (name value argument default : 1000) = number of bootstraps to perform
%   - channeighbstructmat (name value argument default will load the file if present on path) = struct with information on what electrodes are neighbors with each other
%   - expected_chanlocs (name value argument default will load the file if present on path) = struct expected channel locations
%
% Output(s):
%   - LIMO_path = path where data is saved
%
% Author: R.M.D. Kock, Leiden University

arguments
    unique_name char;
    paired logical;
    tf logical;
    data1 ;
    data2 = [];
    options.significance_threshold double = 0.05;
    options.bootstrap = 2;
    options.channeighbstructmat = [];
    options.expected_chanlocs = [];
    options.all_chans logical = 1;
end

%% load the necessary files if not provided and given they are on path
if isempty(options.channeighbstructmat)
    try
        load('channeighbstructmat.mat');
        if options.all_chans
            options.channeighbstructmat = channeighbstructmat;
        else
            options.channeighbstructmat = channeighbstructmat(1:62,1:62);
        end
        
    catch
        disp('Provide channeighbstructmat as name value pair argument or add file to path')
        return
    end
end
if isempty(options.expected_chanlocs)
    try
        load('expected_chanlocs.mat');
        if options.all_chans
            options.expected_chanlocs = expected_chanlocs;
        else
            options.expected_chanlocs = expected_chanlocs(1:62);
        end
        
    catch
        disp('Provide expected_chanlocs as name value pair argument or add file to path')
        return
    end
end
%% prepare limo_struct
LIMO = struct();
LIMO.Analysis = 'Time';
LIMO.Level = 2;
LIMO.data.chanlocs = options.expected_chanlocs;
LIMO.data.neighbouring_matrix = options.channeighbstructmat;
LIMO.data.data = path;
LIMO.data.data_dir = path;
LIMO.data.sampling_rate = 1000;
LIMO.design.bootstrap = options.bootstrap;
LIMO.design.tfce = 0;
LIMO.design.name = 't-test';
LIMO.design.electrode = [];
LIMO.design.X = [];
LIMO.design.method = 'Trimmed Mean';

%% create a space to save the files
if ~exist(unique_name, 'dir')
    mkdir(unique_name)
end
try
    cd(unique_name)
catch
    warning(sprintf('Folder with name %s already exists, will not rewrite'), unique_name)
    return
end
% set save directory as the folder created
LIMO.dir = pwd();

%% run analysis
% run paired samples t-test
LIMO_paths = limo_random_robust(3, data1, data2, 1, LIMO);
%%
split_path = split(LIMO_paths, '/');
event = split_path{end};
significance_threshold = 0.05;
load(sprintf('%s/paired_samples_ttest_parameter_1.mat',LIMO_paths));
load(sprintf('%s/H0/H0_paired_samples_ttest_parameter_1',LIMO_paths));
one_sample = paired_samples;
H0_one_sample = H0_paired_samples;

% F values
M = squeeze(one_sample(:, :, 4)) .^ 2;
% P values
P = squeeze(one_sample(:, :, 5));

% F values under h0
bootM = squeeze(H0_one_sample(:,:,1,:)) .^ 2;
% P values under h0
bootP = squeeze(H0_one_sample(:,:,2,:));
[mask,cluster_p] = limo_cluster_correction(M,P,bootM,bootP,options.channeighbstructmat,2,significance_threshold);

save('mask.mat','mask')
save('cluster_p.mat','cluster_p')
% run one sample t-test
%% save results of clustering and rename

rename_add_suffix(LIMO_paths, unique_name)
% return to previous directory
cd('../')
end
