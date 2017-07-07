function hapiplot(data,meta,pn,compstr)
% HAPIPLOT - Create and save figures of response from HAPI server
% 
%   HAPIPLOT(Data,Meta) Plot all parameters in data
%
%   HAPIPLOT(Data,Meta,Pname) Plots parameter named Pname vs. Time.
%
%   HAPIPLOT(Data,Meta,pnum) Plots parameter number pnum vs. Time.
%   For example, to plot the first non-Time parameter vs. Time, use
%   HAPIPLOT(Data,Meta,1). (The parameter number is 1 + the element
%   number the parameter in Meta.parameters; Meta.parameters{1} is
%   always Time, and Time can not be plotted alone).
%
%   See also HAPI_DEMO.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: R.S Weigel <rweigel@gmu.edu>
% License: This is free and unencumbered software released into the public domain.
% Repository: https://github.com/hapi-server/matlab-client.git
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('pn','var') && isstr(pn)
    if ~isfield(data,pn),error(sprintf('\nParameter %s not found.',pn));end
    parameters = meta.parameters;
    for i = 2:length(parameters)
        if strcmp(parameters{i},pn)
            break
        end
    end
    meta.parameters = {meta.parameters{1},meta.parameters{i}};
    clear pn;
end

% Number of parameters (excluding Time)
np = length(meta.parameters) - 1;
if ~exist('pn','var') 
    for i = 1:np
        if ~any(strcmp(meta.parameters{i+1}.type,{'string','isotime'})) %% && isfield(meta.parameters{i+1},'size'))
            % Doubles or integers that are stored as matrices.
            if ~isfield(meta.parameters{i+1},'size');
                meta.parameters{i+1}.size = [1];
            end
            psize = meta.parameters{i+1}.size;
            if length(psize) == 1 % Parameter is stored as 2-D matrix with rows of time
                hapiplot(data,meta,i);
            else
                pname = meta.parameters{i+1}.name;
                if length(psize) > 2
                    % TODO: Generalize to handle more than 3-D?
                    warning(sprintf('\nParameter %s has more than 3 dimensions.  Plotting only first 3.',name));
                end
                % Parameter is stored as N-D matrix with rows of time.
                % Loop over 3rd dimension.
                for j = 1:psize(2)
                    tmp   = getfield(data,pname);
                    datar = setfield(data,pname,tmp(:,:,j)); % Extracts tmp(:,:,j,1,1,...)
                    metar = setfield(meta,'size',psize(1));
                    metar.parameters{i+1}.label = sprintf('%s(:,:,%d)',pname,j);
                    hapiplot(datar,metar,i);
                end
            end
        else
            % A 2-D string or isotime parameter
            % (e.g., a time series that is a vector of strings).
            name  = meta.parameters{i+1}.name;
            comps = getfield(data,name); % comps is a cell array
            datar = data;
            metar = meta;
            if ~isfield(meta.parameters{i+1},'size');
                metar.parameters{i+1}.size = [1];
            end
            for j = 1:length(comps)
                datar = setfield(datar,name,comps{j}); % Reduced data is a matrix of strings.
                % Create a field "label" that identifies component.
                metar.parameters{i+1}.label = sprintf('%s(:,%d)',name,j);
                % Plot each component separately and pass component string
                % for file name.
                hapiplot(datar,metar,i);
            end    
        end
        % MATLAB passes by value, so delete data after passed.
        rmfield(data,meta.parameters{i}.name);
    end
    return;
end

pname = meta.parameters{pn+1}.name;  % Parameter name
if isfield(meta.parameters{pn+1},'label')
    % Parameter name for string or isotime arrays
    label = meta.parameters{pn+1}.label;
else
    label = pname;
end

% Output file name.
fname = sprintf('%s_%s_%s_%s',...
                meta.x_.dataset,...
                label,...
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
tstr = sprintf('%s/info?id=%s&parameters=%s',meta.x_.server,meta.x_.dataset,pname);

% Open figure and give title to figure window.
fhs = findobj('Type', 'figure');
for i = 1:length(fhs)
    if strcmp(fhs(i).Name,label)
        % If figure already exists for this parameter, overwrite.
        fh = figure(fhs(i).Number);clf;
        break
    end
end
if ~exist('fh','var')
    fh = figure();clf;
    set(fh,'Name',label);
end

gca;hold on; % Force axes to appear so they can be labeled.
set(findall(gcf,'-property','FontSize'),'FontSize',16)
set(findall(gcf,'-property','FontName'),'FontName','Times New Roman')

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

if ~isfield(meta.parameters{pn+1},'bins') && meta.parameters{pn+1}.size(1) < 10
    % Plot parameter as one or more time series

    ptype = meta.parameters{pn+1}.type;
    
    if strcmp(ptype,'isotime')
        y = iso2mldn(y);
    end
    
    tight = 1;
    if strcmp(ptype,'string')
        [ustrs,ia,ib] = unique(y,'rows');
        y = ib;
        yt = [1:length(ia)];
        if (length(ia) > 10)
            dy = floor(length(ia)/10);
            yt = [1:dy:length(ia)];
            if yt(end) ~= length(ia)
                yt = [yt,yt(end)+dy];
                tight = 0;
            end
        end
        set(gca,'YTick',yt);
        set(gca,'YLim',[1,yt(end)]);
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
    datetick('x');
    
    if length(punits) > 0
        yh = ylabel(sprintf('%s [%s]',label,punits));
    else
        yh = ylabel(label);
    end
    if strcmp(ptype,'isotime')
        datetick('y');
        if (y(end)-y(1) <= 1)
            yl = [get(get(gca,'YLabel'),'String'),' on ',datestr(y(1),'yyyy-mm-dd')];
            ylabel(yl);
        end
    end    
    set(yh,'Interpreter','none');

    if strcmp(ptype,'string')
        legend(meta.parameters{pn+1}.description);
    end
    
    if size(y,2) > 1
        for i = 1:size(y,2)
            legstr{i} = sprintf('Column %d',i);
        end
        legend(legstr);
    end
    grid on;
    if tight,axis tight;end
    box on;
else
    % Plot parameter as spectrogram

    if isfield(meta.parameters{pn+1},'bins')
        binname = meta.parameters{pn+1}.bins.name;
        if isfield(meta.parameters{pn+1}.bins,'ranges')
            binranges  = meta.parameters{pn+1}.bins.ranges;
            warning('Parameter has bin ranges, but hapi_plot will not use them.');
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
    else
        binname = 'Column';
        bincenters = [1:meta.parameters{pn+1}.size(1)];
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
        cbstr = sprintf('%s [%s]',label,punits);
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
fnamepng = ['./hapi-figures/',fname,'.png'];
fnamepdf = ['./hapi-figures/',fname,'.pdf'];
print('-dpng',fnamepng);
fprintf('hapiplot.m: Wrote %s\n',fnamepng);
%print('-dpdf',fnamepdf);
%fprintf('hapiplot.m: Wrote %s\n',fnamepdf);


function dn = iso2mldn(datestr)

% For converting a isotime parameter to a MATLAB date-time.
% Not well tested.
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