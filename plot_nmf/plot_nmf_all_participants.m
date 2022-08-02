function plot_nmf_all_participants(basis,time_range,chan, options)
arguments
    basis;
    time_range;
    chan (1,1) {mustBePositive};
    options.erp_data = [];
    options.layout_columns (1,1) {mustBePositive} = 4;
    options.rows = [];
end
% assert size row
if isempty(options.rows) && isempty(options.erp_data)
    options.rows = ceil(size(basis,2)/options.layout_columns);
elseif ~isempty(options.erp_data)
    options.rows = ceil(size(basis,2)/options.layout_columns) * 2;
end

figure;
tiledlayout(options.rows, options.layout_columns)
for pp =1:size(basis,2)
    nexttile;
    plot(time_range,basis{chan,pp})
    xline(0);
    title(sprintf('Sub: %d',pp))
    if ~isempty(options.erp_data)
        nexttile;
        plot(time_range,options.erp_data(chan,:,pp))
        title(sprintf('ERP Sub: %d',pp))
        xline(0)
    end
end
sgtitle(sprintf('Channel %d', chan))
end