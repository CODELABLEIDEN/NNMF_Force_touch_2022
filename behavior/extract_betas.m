function [limo_dat,cluster1] = extract_betas(eeg_mods, clus, type)
    cluster1 = eeg_mods(clus,~cellfun('isempty', eeg_mods(clus,:)));
    if type
        select_betas = cellfun(@(x) cellfun(@(pp) pp.betas,x,'UniformOutput',false),cluster1,'UniformOutput',false);
    else
        select_betas = cellfun(@(x) cellfun(@(pp) pp.p',x,'UniformOutput',false),cluster1,'UniformOutput',false);
    end
    clus_size = length(cluster1);
    limo_dat = zeros(62,4000,clus_size);
    for pp=1:clus_size
        limo_dat(:,:,pp) = cell2mat(select_betas{pp});
    end
end