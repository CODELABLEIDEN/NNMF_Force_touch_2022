function [end_indices,start_indices,mid_indices,original_merged] =remove_short_ITIs(end_indices,start_indices,mid_indices)
max_iti = 100;
ITI = round([start_indices 0] - [0 end_indices]);
ITI = ITI(1:end-1);
to_remove = find(ITI<max_iti);
n_to_remove = length(to_remove);
original_merged = n_to_remove;
while n_to_remove > 1
    ITI = round([start_indices 0] - [0 end_indices]);
    ITI = ITI(1:end-1);
    to_remove = find(ITI<max_iti);
    n_to_remove = length(to_remove);
    end_indices(to_remove(1)) = [];
    start_indices(to_remove(1)) = [];
    mid_indices(to_remove(1)) = [];
end
if n_to_remove == 1
    ITI = round([start_indices 0] - [0 end_indices]);
    ITI = ITI(1:end-1);
    to_remove = find(ITI<max_iti);
    end_indices(to_remove) = [];
    start_indices(to_remove) = [];
    mid_indices(to_remove) = [];
end
end