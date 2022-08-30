function [model,pvals] = reg_model(features,sorted_rank, options)
arguments
    features; 
    sorted_rank;
    options.type logical = 0;
end
%%
if options.type
    n_features = size(features,2);
    model = cell(n_features,1);
    pvals = zeros(n_features+1,1);
    for feat=1:n_features
        design_matrix = [full(sorted_rank)];
        model{feat} = limo_glm(features(:,feat), design_matrix', 0, 0, 0, 'IRLS', 'TIME');
        pvals(feat) = model{feat}.p;
    end
else
    n_features = size(features,2);
    model = cell(n_features+1,1);
    pvals = zeros(n_features+1,1);
    for feat=1:n_features
        design_matrix = [features(:,feat), ones(size(features(:,feat)))];
        model{feat} = limo_glm(full(sorted_rank)', design_matrix, 0, 0, 0, 'IRLS', 'TIME');
    end
    design_matrix = [features, ones(size(features(:,feat)))];
    model{n_features+1} = limo_glm(full(sorted_rank)', design_matrix, 0, 0, 0, 'IRLS', 'TIME');
    pvals(n_features+1) = model{n_features+1}.p;
end