function [end_indices,start_indices,mid_indices,original_merged] = merge_fs(end_indices,start_indices,mid_indices)
ITI = round([start_indices 0] - [0 end_indices]);
ITI = ITI(1:end-1);
to_merge = find(ITI<5);
n_merged = length(to_merge);
original_merged = n_merged;
while n_merged>1
    ITI = round([start_indices 0] - [0 end_indices]);
    ITI = ITI(1:end-1);
    to_merge = find(ITI<5);
    n_merged = length(to_merge);
    end_indices(to_merge(1)-1) = end_indices(to_merge(1));
    end_indices(to_merge(1)) = [];
    start_indices(to_merge(1)) = [];
    mid_indices(to_merge(1)) = [];
end
end