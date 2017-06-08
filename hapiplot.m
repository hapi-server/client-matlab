<<<<<<< HEAD
function hapiplot(data,meta,pn)
% HAPIPLOT - Create and save figures of response from HAPI server
% 
%   HAPIPLOT(meta,data) Plot all parameters in data
%
%   HAPIPLOT(meta,data,pn) Plots only parameter number pn

nf = length(meta.parameters);
if nargin < 3 && nf > 2 % First parameter is Time.
    for i = 1:nf-1
        hapiplot(data,meta,i);
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

yfill  = str2num(meta.parameters{pn+1}.fill);  % Parameter fill
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
    
    ph = plot(time,y,'LineWidth',2);

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
=======
function hapiplot(meta,data)

fname = sprintf('%s_%s_%s_%s',...
                meta.x_dataset,...
                regexprep(meta.x_request_parameters,',','-'),...
                regexprep(meta.x_request_time_min,'-|:\.|Z',''),...
                regexprep(meta.x_request_time_max,'-|:|\.|Z',''));

figure;

if (size(data,2) == 2)
    % Replace fills with NaN for plotting (so gaps shown in line)
    data(data(:,2) == str2num(meta.parameters{2}.fill)) = NaN;
    ph = plot(data(:,1),data(:,2));
    th = title(sprintf('%s/id=%s&parameters=%s',...
        meta.x_server,meta.x_dataset,meta.parameters{2}.name));
    set(th,'Interpreter','none','FontWeight','normal');
    yh = ylabel([meta.parameters{2}.name,' [',meta.parameters{2}.units,']']);
    set(yh,'Interpreter','none'); % Don't interpret _ as subscript
    datetick
    grid on;
    if (data(1,1) - data(end,1) <= 1)
        xlabel(['Universal Time on ',datestr(data(1,1),'yyyy-mm-dd')]);
    else
        xlabel('Universal Time');
    end
end

if (size(data,2) > 4)
    % Spectrogram

    time  = data(:,1);
    data  = data(:,2:end);
    bins  = meta.parameters{2}.bins.centers;
    % Note bin ranges are given, but not used here.

    % Replace fills with NaN for plotting (so white tile is shown)
    data(data == str2num(meta.parameters{2}.fill)) = NaN;

    m     = min(min(data));
    data  = log10(data - m + 1);

        % Plot matrix as colored squares.
        p = pcolor(time',log10(bins'),data');
        set(p,'EdgeColor','none'); % Don't show boundaries for squares.
        ch = colorbar;
        title(ch,sprintf('log_{10}(%s + %.1f + 1 [%s])',...
            meta.parameters{2}.name,abs(m),meta.parameters{2}.units));
        th = title(sprintf('%s/id=%s&parameters=%s',...
            meta.x_server,meta.x_dataset,meta.parameters{2}.name));
        set(th,'Interpreter','none','FontWeight','normal');
        if (isfield(meta.parameters{2},'units'))
            units = meta.parameters{2}.units;
            yl = [meta.parameters{2}.bins.name,' [',units,']'];
        else
            yl = [meta.parameters{2}.bins.name];
        end
        yh = ylabel(sprintf('log_{10}(%s)',yl));
        datetick;
        grid on;
        if (time(1) - time(1) <= 1)
            % Show date in x-label b/c because datetick does not
            % show date if <= one day of data.
            xlabel(['Universal Time on ',datestr(time(1),'yyyy-mm-dd')]);
        else
            xlabel('Universal Time');
        end
>>>>>>> b2197f596fe8712a7f4a868ea0f44d0d0669015c
end

if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end
fname = ['./hapi-figures/',fname,'.png'];
print('-dpng',fname);
fprintf('hapiplot.m: Wrote %s\n',fname);
