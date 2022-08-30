[durations] = calculate_fs_durations(fs1s,pp);
[W, H] = stable_nnmf(basis_all,loadings_all, pp);
k = size(H,1);
%%
[sorted1, idx1] = sort(H(1,:), 'descend');
durations_rank1 = durations(idx);

[sorted2, idx2] = sort(H(2,:), 'descend');
durations_rank2 = durations(idx);
%%
percentage = 20;
n_trials = size(H,2);
sel_trials = n_trials * percentage/100;
all_trials_1 = zeros(n_trials,1);
all_trials_1(idx1(1:sel_trials)) = 1;
all_trials_2 = zeros(n_trials,1);
all_trials_2(idx2(1:sel_trials)) = 1;
%%
figure; 
tiledlayout(2,1)
nexttile
imagesc(all_trials_1');
nexttile
imagesc(all_trials_2');
%%
highest = 0;
lowest = 0;
count = 0;
for i=1:length(all_trials_1)
    if all_trials_1(i)
        count = count + 1;
    end
    if all_trials_2(i)
        count = count - 1;
    end
    if count > && ~all_trials_1(idx_inner)highest
        highest = count;
    elseif count < lowest
        lowest = count;
    end
end
%%
distance = zeros(length(all_trials_1),1);
distance = distance-1;
for idx_outer=1:length(all_trials_1)
    if all_trials_1(idx_outer)
        find_value = idx_outer;
        count = 0;
        for idx_inner=1:length(all_trials_2)
            if idx_inner > find_value && ~all_trials_2(idx_inner) && ~all_trials_1(idx_inner)
                count = count + 1;
            elseif idx_inner > find_value && all_trials_2(idx_inner) && ~all_trials_1(idx_inner)
                distance(idx_outer) = count;
                break
            elseif idx_inner > find_value && all_trials_1(idx_inner)
                break
            end
        end
    end
end