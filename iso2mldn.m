function dn = iso2mldn(datestr)

datefmt = regexprep(datestr(1,:),'Z$','');
if ~isempty(regexp(datefmt,'^[0-9]{4}-[0-9]{2}-'));
    datestrtype = 1;
    datefmt = regexprep(datefmt,'^[0-9]{4}-','yyyy-');
    datefmt = regexprep(datefmt,'yyyy-[0-9][0-9]-','yyyy-mm-');
end
if ~isempty(regexp(datefmt,'^[0-9]{4}-[0-9]{3}-'));
    datestrtype = 2;
end

datefmt = regexprep(datefmt,'yyyy-mm-[0-9][0-9]T','yyyy-mm-ddT');
datefmt = regexprep(datefmt,'yyyy-mm-ddT[0-9][0-9]','yyyy-mm-ddTHH');
datefmt = regexprep(datefmt,'yyyy-mm-ddTHH:[0-9][0-9]','yyyy-mm-ddTHH:MM');
datefmt = regexprep(datefmt,'yyyy-mm-ddTHH:MM:[0-9][0-9]','yyyy-mm-ddTHH:MM:SS');

n = length('yyyy-mm-ddTHH:MM:SS');
l = length(datefmt);
ms = 0;
if l > n
    if strcmp(datestr(1,end),'Z')
        ms = str2num(datestr(:,n+1:end-1))*10^(3+n-l)
    else
        ms = str2num(datestr(:,n+1:end))*10^(3+n-l)
    end
    datefmt = regexprep(datefmt,'yyyy-mm-ddTHH:MM:SS.*','yyyy-mm-ddTHH:MM:SS');
    if (ms < 0.001)
        warning('Parameter time resolution is less than 1 ms. Axis labels will not be correct at this time scale.');
    end
    dn = datenum(datestr,datefmt) + ms/(86400);
else
    dn = datenum(datestr,datefmt);
end
