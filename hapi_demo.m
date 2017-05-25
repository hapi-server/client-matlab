hapi()
break
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot first dataset from two different hapi servers.
% Saves plots as hapi_demo1.png and hapi_demo2.png

% Time series example
server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'X_TOD';
start      = '2012-02-01';
stop       = '2012-02-02';
% Get data
[data,meta] = hapi(server,dataset,parameters,start,stop);

% Replace fills with NaN for plotting (so gaps shown in line)
data(data(:,2) == meta{2}.fill) = NaN;

figure(2)
    ph = plot(data(:,1),data(:,2));
    th = title(sprintf('%s/id=%s&parameters=%s',...
        server,dataset,meta{2}.name));
    set(th,'Interpreter','none','FontWeight','normal');
    yh = ylabel([meta{2}.name,' [',meta{2}.units,']']);
    set(yh,'Interpreter','none'); % Don't interpret _ as subscript
    datetick
    grid on;
    if (data(1,1) - data(end,1) <= 1)
        xlabel(['Universal Time on ',datestr(data(1,1),'yyyy-mm-dd')]);
    else
        xlabel('Universal Time');
    end
    if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end

    print -dpng hapi_demo2.png
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Spectrogram example
server     = 'http://datashop.elasticbeanstalk.com/hapi';
dataset    = 'CASSINI_LEMMS_PHA_CHANNEL_1_SEC';
parameters = 'A';
start      = '2002-01-01';
stop       = '2002-01-02';
% Get data
[data,meta] = hapi(server,dataset,parameters,start,stop);

% pcolor needs a matrix (but shouldn't ...)
[X,Y] = meshgrid(data(:,1),meta{2}.bins.centers);
% Note bin boundaries are given, but for now don't account for them
% to simplify plot command.
m     = min(min(data(:,2:end)));
data  = log10(data(:,2:end) - m + 1);

figure(1)
    % Plot matrix as colored squares.
    p = pcolor(X,log10(Y),data');
    set(p,'EdgeColor','none'); % Don't show boundaries for squares.
    ch = colorbar;
    title(ch,sprintf('log_{10}(%s + %.1f + 1 [%s])',...
        meta{2}.name,abs(m),meta{2}.units));
    th = title(sprintf('%s/id=%s&parameters=%s',...
        server,dataset,meta{2}.name));
    set(th,'Interpreter','none','FontWeight','normal');
    if (isfield(meta{2}.bins,'units'))
        yl = [meta{2}.bins.name,' [',units,']'];
    else
        yl = [meta{2}.bins.name];
    end
    yh = ylabel(sprintf('log_{10}(%s)',yl));
    datetick;
    grid on;
    if (data(1,1) - data(end,1) <= 1)
        % Show date in x-label b/c because datetick does not
        % show date if <= one day of data.
        xlabel(['Universal Time on ',datestr(data(1,1),'yyyy-mm-dd')]);
    else
        xlabel('Universal Time');
    end
    if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end
    print -dpng hapi-figures/hapi_demo1.png


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Metadata request examples

sn = 1; % Server number in servers.txt
dn = 1; % Dataset number from first server

% List all HAPI servers
hapi();

% Cell array of server URLs
Servers = hapi();

% List datasets from second server in list
hapi(Servers{sn});

% Cell array of dataset IDs from server
Datasets = hapi(Servers{sn});

% List info for parameters in first dataset
Parameters = hapi(Servers{sn},Datasets{dn});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting options
opts = struct();
opts.logging = false;
hapi(opts);
server     = 'http://datashop.elasticbeanstalk.com/hapi';
hapi(server,opts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

