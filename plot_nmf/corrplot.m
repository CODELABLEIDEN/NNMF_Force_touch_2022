function corrplot(durations,areas,force,areas_short)
figure;
tiledlayout(4,3)
nexttile
scatter(zscore(durations),zscore(areas))
xlabel('Duration');ylabel('areas')
CORR = corrcoef(zscore(durations),zscore(areas));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(durations),zscore(force))
xlabel('Duration');ylabel('force')
CORR = corrcoef(zscore(durations),zscore(force));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(durations),zscore(areas_short))
xlabel('Duration');ylabel('areas short')
CORR = corrcoef(zscore(durations),zscore(areas_short));
title(sprintf('Corr: %.2f', CORR(2)))

nexttile
scatter(zscore(force),zscore(areas))
xlabel('Force');ylabel('areas')
CORR = corrcoef(zscore(force),zscore(areas));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(force),zscore(durations))
xlabel('Force');ylabel('duration')
CORR = corrcoef(zscore(force),zscore(durations));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(force),zscore(areas_short))
xlabel('Force');ylabel('areas short')
CORR = corrcoef(zscore(force),zscore(areas_short));
title(sprintf('Corr: %.2f', CORR(2)))

nexttile
scatter(zscore(areas),zscore(durations))
xlabel('areas');ylabel('duration')
CORR = corrcoef(zscore(areas),zscore(durations));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(areas),zscore(force))
xlabel('areas');ylabel('force')
CORR = corrcoef(zscore(areas),zscore(force));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(areas),zscore(areas_short))
xlabel('areas');ylabel('areas short')
CORR = corrcoef(zscore(areas),zscore(areas_short));
title(sprintf('Corr: %.2f', CORR(2)))

nexttile
scatter(zscore(areas_short),zscore(durations))
xlabel('areas short');ylabel('duration')
CORR = corrcoef(zscore(areas_short),zscore(durations));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(areas_short),zscore(force))
xlabel('areas short');ylabel('force')
CORR = corrcoef(zscore(areas_short),zscore(force));
title(sprintf('Corr: %.2f', CORR(2)))
nexttile
scatter(zscore(areas_short),zscore(areas))
xlabel('areas short');ylabel('areas')
CORR = corrcoef(zscore(areas_short),zscore(areas));
title(sprintf('Corr: %.2f', CORR(2)))
end