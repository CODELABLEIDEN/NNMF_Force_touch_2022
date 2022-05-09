function plot_elec_location(elec, EEG)
figure;
selection = zeros(1,64);
selection(elec) = 1;
topoplot(selection, EEG.chanlocs, 'style', 'blank', 'whitebk', 'on', 'electrodes', 'off')
end