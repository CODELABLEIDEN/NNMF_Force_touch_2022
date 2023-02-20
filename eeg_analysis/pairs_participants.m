x = zeros(selected_k,size(fs1s,1));
for clus=1:selected_k
    pps = unique(pps_in_cluster(find(cluster_res == clus)));
    x(clus,pps) = pps;
end
figure; imagesc(x)
cmap = colormap();
cmap(1,:) = [ 1 1 1];
colormap(cmap)
%%
y = x>0;
cluster_combos = nchoosek(1:selected_k, 2);
n_matching_clusters = zeros(size(cluster_combos,1),1);
matching_participants = zeros(size(cluster_combos,1),size(fs1s,1));
for combo=1:size(cluster_combos,1)
    matching_participants(combo,:) = y(cluster_combos(combo,1),:) & y(cluster_combos(combo,2),:);
    n_matching_clusters(combo) = sum(matching_participants(combo,:));
end
pos_pairs = cluster_combos(n_matching_clusters> 10,:);
%% LIMO paired t-test
percentage = 30;
[~,idx] =max(n_matching_clusters);
clus=1;
sel = pps_in_cluster(cluster_res == clus);
matching = ismember(sel,find(matching_participants(idx,:)>0));
selection = sel(matching);
ranks_sel = ranks_in_cluster(cluster_res == clus);
ranks_sel = ranks_sel(matching);
[v, w] = unique( selection, 'stable' );
duplicate_indices = setdiff( 1:numel(selection), w );
selection(duplicate_indices) = [];
ranks_sel(duplicate_indices) = [];
stable_loadings_sel = stable_loadings(selection);
% stable_basis_sel = stable_basis(selection);
selected_pps = fs1s(selection,:);
[data1] = prepare_erp_data_fs(selected_pps,stable_loadings_sel,ranks_sel, 'percentage', percentage);

clus=3;
sel = pps_in_cluster(cluster_res == clus);
matching = ismember(sel,find(matching_participants(idx,:)>0));
selection = sel(matching);
[v, w] = unique( selection, 'stable' );
duplicate_indices = setdiff( 1:numel(selection), w );
ranks_sel = ranks_in_cluster(cluster_res == clus);
ranks_sel = ranks_sel(matching);
selection(duplicate_indices) = [];
ranks_sel(duplicate_indices) = [];
stable_loadings_sel = stable_loadings(selection);
% stable_basis_sel = stable_basis(selection);
selected_pps = fs1s(selection,:);
[data2] = prepare_erp_data_fs(selected_pps,stable_loadings_sel,ranks_sel, 'percentage', percentage);
%% run LIMO
[LIMO_path] = run_t_tests_and_clustering_paired('paired_erp_fs', 1, 0, data1, data2, 'all_chans', 0);
%% plot
EEG.chanlocs = EEG.chanlocs(1:62);
load('mask_paired_erp_fs.mat')
load('paired_samples_ttest_parameter_1_paired_erp_fs.mat')
paired = 1;
tf = 0;
[mean_vals, sig_t] = prepare_data_for_plotting(paired_samples, mask, 0, tf);
real_timestamps = [-500 -250 -100 0];
number_timestamps = real_timestamps+(size(mean_vals,2)/2);
h = create_topoplot(sig_t, EEG, 'cool' ,tf, [-10 10],number_timestamps,real_timestamps);
saveas(h, sprintf('paired_cons_%d.svg',clus))

real_timestamps = [0 150 500 750];
number_timestamps = real_timestamps+(size(mean_vals,2)/2);
h = create_topoplot(sig_t, EEG, 'cool' ,tf, [-10 10],number_timestamps,real_timestamps);
saveas(h, sprintf('paired_prep_%d.svg',clus))
%% movie
load('mask_paired_erp_fs.mat')
load('paired_samples_ttest_parameter_1_paired_erp_fs.mat')
paired = 1;
tf = 0;
[mean_vals_erp, sig_t_erp] = prepare_data_for_plotting(paired_samples, mask, 0, tf);
t_lims = [-10 10];
mean_plot_title = 'ERP Paired T-values (MCC, p<0.05)';
number_timestamps = [1:4000];
real_timestamps = number_timestamps-2000;
Figures_postanalysis_movie_paired(EEG,[],sig_t_erp, number_timestamps,real_timestamps, 'paired_erp',mean_plot_title, t_lims)

