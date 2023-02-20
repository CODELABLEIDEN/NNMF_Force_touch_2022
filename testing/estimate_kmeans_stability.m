%%
pp_reps = [];
numreps =50;
for rep=1:numreps
    [cluster_res] = cluster_nnmf(basis_all_pps, selected_k);
    for k=1:selected_k
        count = 1;
        for i=1:size(cluster_res,1)
            if cluster_res(i) == k
                pp = pps_in_cluster(i);
                r = ranks_in_cluster(i);
                pp_reps(k,rep, count) = str2num(strcat(int2str(pp),int2str(r)));
                count = count+1;
            end
        end
    end
end
%%
count = 0;
for p_i=1:numreps
    for q_i=1:numreps
        p = squeeze(pp_reps(:,p_i,:));
        [~,idx_sort_p] = sort(sum(p==0,2));
        p = p(idx_sort_p,:);
        q = squeeze(pp_reps(:,q_i,:));
        [~,idx_sort_q] = sort(sum(q==0,2));
        q = q(idx_sort_q,:);
        
        diff = (find(p~=q));
        if any(diff)
            p(diff) = circshift(reshape(p(diff), [2,size(diff,1)/2]),1);
        end
        if ~isequal(p,q)
            count = count+1;
        end
    end
end