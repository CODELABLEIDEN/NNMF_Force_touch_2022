%%
EEG = pop_loadset('/media/Storage/User_Specific_Data_Storage/ruchella/Feb_2022_BS_to_tap_classification_EEG/DS01/13_09_01_03_19.set');
EEG.chanlocs = EEG.chanlocs(1:62);
%%
paired = 0;
tf = 0;
erp = cat(3,fs1s{:,3});
erp = erp(1:62,:,:);
[LIMO_path_am] = run_t_tests_and_clustering('fs', paired, tf, erp, 'all_chans', 0);
%%
load('mask_fs.mat')
load('one_sample_ttest_parameter_1_fs.mat')
[mean_vals, sig_t] = prepare_data_for_plotting(one_sample, mask, paired, tf);
number_timestamps = [1:10:500 500:3000 3000:10:4000];
real_timestamps = number_timestamps-2000;
mean_lims = [-1 1];
t_lims = [-10 10];
mean_plot_title = sprintf('Brain activity (%sV)',char(181));
Figures_postanalysis_movie(EEG, mean_vals,sig_t, number_timestamps,real_timestamps, 'fs_erp',mean_plot_title, mean_lims, t_lims)