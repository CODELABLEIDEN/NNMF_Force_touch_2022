function non_neg_data = make_eeg_nonneg(data, shift_type, options)
arguments
    data;
    shift_type char;
    options.participants (1,1) = size(data,4);
    options.channels (1,1) = size(data,1);
end
% if (numel(size(data)) ~= 4)
%     error('Data should be in the shape of chan x time x trials x participants')
% end
non_neg_data = zeros(size(data));

if strcmp(shift_type, 'shift_global') 
    shift_by_global = ceil(abs(min(data, [], 'all')));
    non_neg_data = squeeze(data + shift_by_global);
elseif numel(size(data)) == 4
    for pp=1:options.participants
        for chan=1:options.channels
            if strcmp(shift_type, 'abs')
                % absolute
                non_neg_data(chan,:,:,pp) = abs(data(chan,:,:,pp));
            elseif strcmp(shift_type, 'shift_local')
                % shift by minimum per channel per participant
                shift_by = ceil(abs(min(data(chan,:,:,pp), [], 'all')));
                non_neg_data(chan,:,:,pp) = data(chan,:,:,pp) + shift_by';
            end
        end
    end
else 
    if strcmp(shift_type, 'abs')
        % absolute
        non_neg_data = abs(data);
    elseif strcmp(shift_type, 'shift_local')
        % shift by minimum per channel per participant
        shift_by = ceil(abs(min(data, [], 'all')));
        non_neg_data = data+ shift_by';
    end
end
end