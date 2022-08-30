function [most_prev] = sel_most_prevalent_chan(EEG,erp,preparation)

[elecs] = electrode_selection(EEG, 0, preparation);

laplacian_erp = laplacian_perrinX(erp, [EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);
if preparation
    [~,idx] = sort(median(laplacian_erp(elecs,:),2), 'ascend');
else
    [~,idx] = sort(median(laplacian_erp(elecs,:),2), 'descend');
end
most_prev = elecs(idx(1));
end