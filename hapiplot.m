function hapiplot(data,meta,pn)
% HAPIPLOT - Create and save figures of response from HAPI server
% 
%   HAPIPLOT(meta,data) Plot all parameters in data
%
%   HAPIPLOT(meta,data,pn) Plots only parameter number pn

np = length(meta.parameters) - 1; % Number of parameters (excluding Time)
if nargin < 3
    for i = 1:np
        hapiplot(data,meta,i);
        % MATLAB passes by value, so delete data after passed.
        rmfield(data,meta.parameters{i}.name);
    end
    return;
end

pname = meta.parameters{pn+1}.name;  % Parameter name

% Output file name.
fname = sprintf('%s_%s_%s_%s',...
                meta.x_.dataset,...
                pname,...
                regexprep(meta.x_.time_min,'-|:\.|Z',''),...
                regexprep(meta.x_.time_max,'-|:|\.|Z',''));

% Compute fractional day number using datenum() (1 = Jan-1-0000).
time = datenum(double(data.DateTimeVector(:,1:6))); 
if size(data.DateTimeVector,2) == 7
    % Add in milliseconds to time.
    time = time + double(data.DateTimeVector(:,7))/(86400*1000);
end
if size(data.DateTimeVector,2) > 7 && any(data.DateTimeVector(:,8:end))
    % datetick function uses datenum function values, which are only 
    % relevant to 1 ms.  To plot with correct time axis labels, would
    % need to write custom datetick function.
    warning('Time resolution is less than 1 ms. Time axis labels will not be correct at this time scale.');
end

y = getfield(data,pname); % Data to plot

units = meta.parameters{pn+1}.units; % Parameter units
if strcmp(units,'null')
    % HAPI spec says units = null for dimensionless parameters
    units = '';
end

if isfield(meta.parameters{pn+1},'fill')
    if strcmp(lower(meta.parameters{pn+1}.fill),'nan')
        yfill = NaN
    else
        yfill = str2double(meta.parameters{pn+1}.fill);  % Parameter fill
        if isnan(yfill),yfill = 'null';,end
    end
else
    yfill = 'null';
end
if ~strcmp(yfill,'null')
    % Replace fills with NaN for plotting
    % (so gaps showns in lines for time series)
    y(y == yfill) = NaN;    
end

% Plot title
tstr = sprintf('%s/id=%s&parameters=%s',meta.x_.server,meta.x_.dataset,pname);

% Open figure and give title to figure window.
fhs = findobj('Type', 'figure');
for i = 1:length(fhs)
    if strcmp(fhs(i).Name,pname)
        % If figure already exists for this parameter, overwrite.
        fh = figure(fhs(i).Number);clf;
        break
    end
end
if ~exist('fh','var')
    fh = figure();
    set(fh,'Name',pname);
end

gca; hold on; % Force axes to appear so they can be labeled.
if (time(1) - time(1) <= 1)
    % Show date in x-label b/c because datetick does not
    % show date if <= one day of data.
    xlabel(['Universal Time on ',datestr(time(1),'yyyy-mm-dd')]);
else
    xlabel('Universal Time');
end

th = title(tstr);
% Interpreter = none: Don't interpret underscore in name as subscript
set(th,'Interpreter','none','FontWeight','normal');

if ~isfield(meta.parameters{pn+1},'bins')
    % Plot parameter as one or more time series
    
    ptype = meta.parameters{pn+1}.type;
    if strcmp(ptype,'string')
        [ustrs,ia,ib] = unique(y,'rows');
        y = ib;
        set(gca,'YTick',[1:length(ia)]);
        set(gca,'YTickLabel',ustrs);
        legend(meta.parameters{pn+1}.description);
    end
    
    if isfield(meta.parameters{pn+1},'categorymap')
        categorymap = meta.parameters{pn+1}.categorymap;
        pfields = fieldnames(categorymap);
        for i = 1:length(pfields)
            pfieldvals(i) = getfield(categorymap,pfields{i});
        end
        [yt,I] = sort(pfieldvals);
        set(gca,'YTick',yt);
        set(gca,'YTickLabel',pfields);        
    end
    if size(y,1) < 11
        props = {'LineStyle','none','Marker','.','MarkerSize',30};
    elseif size(y,1) < 101
        props = {'LineStyle','-','LineWidth',2,'Marker','.','MarkerSize',15};
    else
        props = {};
    end
    
    ph = plot(time,y,props{:});
    
    % Auto label x-axis based on time value
    datetick; 
    grid on;
    
    if length(units) > 0
        yh = ylabel(sprintf('%s [%s]',pname,units));
    else
        yh = ylabel(pname);
    end
    set(yh,'Interpreter','none'); 
    
    if size(y,2) > 1
        for i = 1:size(y,2)
            legstr{i} = sprintf('Component %d',i);
        end
        legend(legstr);
    end
else
    % Plot parameter as spectrogram

    % Info required from HAPI server
    biname     = meta.parameters{pn+1}.bins.name;
    binranges  = meta.parameters{pn+1}.bins.ranges;
    bincenters = meta.parameters{pn+1}.bins.centers;
    % Note bin centers only used.
    % TODO: Use ranges.
    if isfield(meta.parameters{pn+1}.bins,'units')
        binunits = meta.parameters{pn+1}.bins.units;
    else
        binunits = '';
    end
    
    % Plot matrix as colored squares.
    p = pcolor(time',binscenters',y');

    % Don't show boundaries for squares.
    set(p,'EdgeColor','none'); 

    % Show colorbar
    cbh = colorbar;
    
    % Set colorbar title
    if length(units) > 0
        cbstr = sprintf('%s [%s]',name,units);
        title(cbh,cbsstr);
    else
        title(cbh,name);
    end

    % Set y label
    if length(binunits) > 0
        yh = ylabel(sprintf('%s [%s]',binname,binunits));
    else
        yl = ylabel(binname);
    end
    
    datetick;
    grid on;
end

if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end
fname = ['./hapi-figures/',fname,'.png'];
print('-dpng',fname);
fprintf('hapiplot.m: Wrote %s\n',fname);
