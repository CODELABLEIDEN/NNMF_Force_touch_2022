function LIMO_nnmf(fs1s,cluster_res,options)
arguments 
    fs1s;
    cluster_res
    options.preparation = 1;
    options.save_path = 'limo_nnmf';
    options.electrodes = 62;
    
end
if options.preparation
    selected_k = 7;
    load('/home/s1815458/fs_nnmf_pipeline/stable_loadings.mat')
    load('/home/s1815458/fs_nnmf_pipeline/cluster_res.mat')
else
    selected_k = 2;
end 

pps_in_cluster = zeros(91,1);
ranks_in_cluster = zeros(91,1);
count = 1;
for pp=1:size(stable_loadings,2)
    n_ranks = size(stable_loadings{pp},1);
    pps_in_cluster(count:count+n_ranks-1) = pp;
    ranks_in_cluster(count:count+n_ranks-1) = 1:n_ranks;
    count = count+n_ranks;
end

eeg_mods = {};
options.electrodes = 62;
for k=1:selected_k
    count = 1;
    for i=1:size(cluster_res,1)
        if cluster_res(i) == k
            pp = pps_in_cluster(i);
            r = ranks_in_cluster(i);
            H = stable_loadings{pp};
            
            mod = cell(options.electrodes,1);
            erp_ersp_data = fs1s{pp,4};
            
            for chan=1:options.electrodes
                mod{chan} = limo_glm(squeeze(erp_ersp_data(chan,:,:))',full(H(r,:))', 0, 0, 0, 'IRLS', 'TIME');
            end
            eeg_mods{k,count} = mod;
            save(sprintf('%s/mod_%d%d%d.mat',options.save_path,k,r,pp), 'mod')
            count = count+1;
        end
    end
    save(sprintf('%s/eeg_mods_%d.mat',options.save_path,k), 'eeg_mods')
end
save(sprintf('%s/eeg_mods.mat',options.save_path,k), 'eeg_mods')
end