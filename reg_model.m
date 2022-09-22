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
    pvals = zeros(n_features,1);
    for feat=1:n_features
        design_matrix = [full(sorted_rank)];
        model{feat} = limo_glm(features(:,feat), design_matrix', 0, 0, 0, 'IRLS', 'TIME');
        pvals(feat) = model{feat}.p;
    end
else
    n_features = size(features,2);
    model = cell(n_features,1);
    residuals = cell(n_features,1);
    pvals = zeros(n_features,1);
    for feat=1:n_features-1
        design_matrix = [features(:,feat)];
%         model{feat} = limo_glm(full(sorted_rank)', design_matrix, 0, 0, 0, 'IRLS', 'TIME');
    mod = fitlm(design_matrix,full(sorted_rank)', 'RobustOpts', 'bisquare');
    model{feat} = mod.Coefficients.Estimate(2,1);
    residuals{feat} = mod.Residuals.Raw;
    end
    design_matrix = [features(:,1:4)];
    mod = fitlm(design_matrix,full(sorted_rank)', 'RobustOpts', 'bisquare');
    model{n_features} = mod.Coefficients.Estimate(2,1);
    residuals{n_features} = mod.Residuals.Raw;
%     plot_residuals(residuals)
end