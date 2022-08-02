function plot_elec_location(elec, chanlocs)
figure;
selection = zeros(1,64);
selection(elec) = 1;
topoplot(selection, chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')
end