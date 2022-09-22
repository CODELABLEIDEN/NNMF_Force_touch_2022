function plot_residuals(mod)
figure;
tiledlayout(2,3)
nexttile
hist(mod{1})
nexttile
hist(mod{2})
nexttile
hist(mod{3})
nexttile
hist(mod{4})
nexttile
hist(mod{5})
nexttile
hist(mod{6})
end