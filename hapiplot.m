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

punits = meta.parameters{pn+1}.units; % Parameter units
if strcmp(punits,'null')
    % HAPI spec says units = null for dimensionless parameters
    punits = '';
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
    
    if strcmp(ptype,'isotime')
        warning(sprintf('Parameter %s is an ISO8601 time stamp. Plotting of this type on the y-axis is not implemented.\n',pname));
        return;
    end
    
    if strcmp(ptype,'string')
        [ustrs,ia,ib] = unique(y,'rows');
        y = ib;
        set(gca,'YTick',[1:length(ia)]);
        set(gca,'YTickLabel',ustrs);
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
    
    if length(punits) > 0
        yh = ylabel(sprintf('%s [%s]',pname,punits));
    else
        yh = ylabel(pname);
    end
    set(yh,'Interpreter','none'); 

    if strcmp(ptype,'string')
        legend(meta.parameters{pn+1}.description);
    end
    
    if size(y,2) > 1
        for i = 1:size(y,2)
            legstr{i} = sprintf('Component %d',i);
        end
        legend(legstr);
    end
    grid on;
    axis tight;
    box on;
else
    % Plot parameter as spectrogram

    binname = meta.parameters{pn+1}.bins.name;

    if isfield(meta.parameters{pn+1}.bins,'ranges')
        binranges  = meta.parameters{pn+1}.bins.ranges;
        warning('Parameter has bin ranges, but hapi_plot will not use them.\n');
    end
    if isfield(meta.parameters{pn+1}.bins,'centers')
        bincenters  = meta.parameters{pn+1}.bins.centers;
    end
    if exist('binranges','var') && ~exist('bincenters','var')
        warning('Parameter has bin ranges, but hapi_plot will use average as center location of ranges for bin.\n');        
    end

    if isfield(meta.parameters{pn+1}.bins,'units')
        binunits = meta.parameters{pn+1}.bins.units;
    else
        binunits = '';
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine if y scale should be log (not well tested).
    one_zero_or_negative = false;
    if sum(bincenters <= 0) == 1
        one_zero_or_negative = true;
    end
    z = (bincenters-mean(bincenters))/std(bincenters);
    loglike = false;
    spectralike = false;
    if length(abs(z) > 3) > 5/length(bincenters)
        loglike = true;
        if (one_zero_or_negative) && bincenters(1) <= 0
            spectralike = true;
            bincenters = bincenters(2:end);
            y = y(:,2:end);
            warning(sprintf('Data looks like a spectra that is best plotted on log scale. Not plotting first %s.\n',binname));            
        end
        bincenters2 = bincenters(2);
    end
    
    bincenters(1:end-1) = bincenters(1:end-1) - (bincenters(2:end) - bincenters(1:end-1))/2;
    bincenters(end) = bincenters(end) + (bincenters(end)-bincenters(end-1))/2;

    if (loglike && spectralike && bincenters(1) <=0)
        bincenters(1) = bincenters(2)/2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    % Plot matrix as colored rectangles.
    p = pcolor(time',bincenters',y');

    % Put grid on top of colored rectangles.
    set(gca,'layer','top');
    
    if loglike && spectralike
        set(gca,'YScale','log');
    end
    
    % Don't show horizontal lines for rectangle boundaries.
    if length(bincenters) > 40
        set(p,'EdgeColor','none');
    end

    % Use 16 colors so by eye one can match color on plot with
    % a colorbar value.    
    colormap(parula(16));

    % Show colorbar
    cbh = colorbar;
    
    % Set colorbar title
    if length(punits) > 0
        cbstr = sprintf('%s [%s]',pname,punits);
        title(cbh,cbstr);
    else
        title(cbh,binname);
    end

    % Set y label
    if length(binunits) > 0
        yh = ylabel(sprintf('%s [%s]',binname,binunits));
    else
        yl = ylabel(binname);
    end
    
    datetick;
    grid on;
    axis tight;
    box on;

    if loglike && spectralike
        % Label top and bottom ticks values.
        yt = get(gca,'YTick');
        set(gca,'YTick',[bincenters(1),yt,bincenters(end)]);
    end
end

if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end
fname = ['./hapi-figures/',fname,'.png'];
print('-dpng',fname);
fprintf('hapiplot.m: Wrote %s\n',fname);
