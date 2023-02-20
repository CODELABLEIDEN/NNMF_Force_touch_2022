function [ITI] = calculate_ITI(fs1s,pp, options)
arguments
    fs1s;
    pp;
    options.start logical= 1;
end
ITI = round([fs1s{pp,8} 0] - [0 fs1s{pp,10}]);
ITI = ITI(2:end);
ITI(end) = round(median(ITI));
ITI(ITI > 15000) = round(median(ITI));
if options.start
    ITI(fs1s{pp,11}) = NaN;
else
    ITI(fs1s{pp,12}) = NaN;
end
ITI = rmmissing(ITI);
end