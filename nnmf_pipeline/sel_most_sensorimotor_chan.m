function [most_sensorimotor] = sel_most_sensorimotor_chan(EEG,erp,sensorimotor)
elecs =1:62;
if sensorimotor
    [elecs] = right_hem_elecs(EEG, 0);
end
laplacian_erp = laplacian_perrinX(erp, [EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);
if sensorimotor
    [~,idx] = sort(median(laplacian_erp(elecs,:),2), 'ascend');
else
    [~,idx] = sort(median(laplacian_erp(elecs,:),2), 'descend');
end
most_sensorimotor = elecs(idx(1));
end