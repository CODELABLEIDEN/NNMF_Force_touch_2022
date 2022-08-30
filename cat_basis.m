basis_all_pps = [];
basis = {};
loadings = {};
for pp=1:size(basis_all,2)
    [W, H] = stable_nnmf(basis_all,loadings_all, pp);
    basis{pp} = W;
    loadings{pp} = H;
    basis_all_pps = cat(2,basis_all_pps,W);
end
%%
pps_in_cluster = zeros(size(basis_all_pps,2),1);
ranks_in_cluster = zeros(size(basis_all_pps,2),1);
count = 1;
for pp=1:size(basis_all,2)
    n_ranks = size(basis_all{1,pp},2);
    pps_in_cluster(count:count+n_ranks-1) = pp;
    ranks_in_cluster(count:count+n_ranks-1) = 1:n_ranks;
    count = count+n_ranks;
end
%% choose optimal k

% elbow method
nClusters=10; % pick/set number of clusters your going to use
totSum=zeros(nClusters-1,1);  % preallocate the result
for k=2:nClusters
  [~,~,sumd]=kmeans(basis_all_pps', k);
  totSum(k)=sum(sumd);
end
figure;
tiledlayout(2,1)
nexttile
plot(totSum)
xlim([2,10])
title('Elbow method')
nexttile
evaluation = evalclusters(basis_all_pps',"kmeans","silhouette","KList",1:10);
plot(evaluation)
title('Silhouette method')
%% silhoutte method 
optimal_ks = zeros(1000,1);
optimal_ys = zeros(1000,size(basis_all_pps,2));
for rep=1:1000
evaluation = evalclusters(basis_all_pps',"kmeans","silhouette","KList",1:10);
optimal_ks(rep) = evaluation.OptimalK;
optimal_ys(rep,:) = evaluation.OptimalY;
end
selected_k = mode(optimal_ks);
%%
cluster_res = kmeans(basis_all_pps', selected_k);
%%
time_range=[-500:100];
plot_clusters(basis_all_pps',cluster_res,selected_k,pps_in_cluster,time_range)
%%
preparation = 1;
if preparation
    selected_time = 1500:2100;
else
    selected_time = 2100:2500;
end
%%
cluster_behavior = {};
cluster_model = {};
for k=1:selected_k
    count = 1;
    for i=1:size(basis_all_pps,2)
        features = [];
        if cluster_res(i) == k
            pp = pps_in_cluster(i);
            r = ranks_in_cluster(i);
            
            erp_ersp_data = fs1s{pp,4};
            W = stable_basis{pp};
            H = stable_loadings{pp};

            [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
            [trial_times] = trial_idx(H,fs1s,size(W,2),time_range,chan,pp);
%             plot_spider_rel(H,fs1s,trial_times,pp)
            [stats, features(:,1), features(:,2), features(:,3), features(:,4), features(:,5)] = behavior_stats(H,fs1s,trial_times,r,pp);
%             cluster_behavior{k,count,1} = features(:,1);
%             cluster_behavior{k,count,2} = features(:,2);
%             cluster_behavior{k,count,3} = features(:,3);
%             cluster_behavior{k,count,4} = features(:,4);
            mod =reg_model(features,H(r,:),'type', 1);
            cluster_model{k,1,count} = mod{1}.betas;
            cluster_model{k,2,count} = mod{2}.betas;
            cluster_model{k,3,count} = mod{3}.betas;
            cluster_model{k,4,count} = mod{4}.betas;
            count = count+1;
        end
    end
end
%%
for clus =1:selected_k
    cluster = cell2mat(cluster_model(clus,:,:));
    [LIMO_path] = run_t_tests_and_clustering(sprintf('cluster_%d',clus), 0, 0, cluster);
end
%%
group = {};
data = [];
count = 1;
for k=1:selected_k
    tmp = [cluster_behavior{k,:}];
    durations_top = [tmp.force_top];
    data = [data durations_top];
    [group{count:count+length(tmp)-1}] = deal(int2str(k));
    count = count+length(tmp);
end
%%
data = zeros(length(tmp),4);
data(:,1) = [tmp.duration_top];
data(:,2) = [tmp.force_top];
data(:,3) = [tmp.areas_top];
data(:,4) = [tmp.areas_short_top];
figure;
limits = [floor(min(data(:,1))) ceil(max(data(:,1))); floor(min(data(:,2))) ceil(max(data(:,2))); floor(min(data(:,3))) ceil(max(data(:,3))); floor(min(data(:,4))) ceil(max(data(:,4)))]';
spider_plot(data, 'AxesLabels', {'duration', 'force', 'areas', 'areas short'}, 'AxesLimits', limits, 'FillOption', 'on')
%% LIMO 1st level analysis
models = {};
p_values_all = {};
base_path = '/home/ruchella/variable_activation/results/GLM_models';
for pp=1:size(basis_all,2)
    erp_ersp_data = fs1s{pp,4};
    W = stable_basis{pp};
    H = stable_loadings{pp};
    k = size(W,2);
    [chan] = sel_most_prevalent_chan(EEG,squeeze(trimmean(erp_ersp_data(:,selected_time,:),20,3)),preparation);
    [trial_times] = trial_idx(H,fs1s,k,time_range,chan,pp);
    features = [];
    for r=1:k
        [stats, features(:,1), features(:,2), features(:,3), features(:,4), features(:,5)] = behavior_stats(H,fs1s,trial_times,r,pp);
%         [models{pp,r} p_values_all{pp,r}] = reg_model(features,H(r,:), 'type', 1);
        path = sprintf('%s/pp_%d_%d',base_path,pp,r);
        unique_name = sprintf('pp_%d_%d',pp,r);
        [models{pp,r} p_values_all{pp,r}] =reg_model(features,H(r,:),'type', 1);
    end
%     plot_spider_rel(H,fs1s,trial_times,pp)
end
%% LIMO second level analysis 
second_models = {};
for k=1:selected_k
    count = 1;
    for i=1:size(basis_all_pps,2)
        tmp = {}
        if cluster_res(i) == k
            pp = pps_in_cluster(i);
            r = ranks_in_cluster(i);
            models{pp,r} 
        end
    end
end
