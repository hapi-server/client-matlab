
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Metadata request examples
sn = 3; % Server number in servers.txt
dn = 1; % Dataset number from first server

Servers = hapi();

% List datasets from second server in list
hapi(Servers{sn}); 
% or
% hapi(Servers{sn},opts); 

% MATLAB structure of JSON dataset list
metad = hapi(Servers{sn}); 
% or 
% metad = hapi(Servers{sn},opts)

% MATLAB structure of JSON parameter list
metap = hapi(Servers{sn}, metad.catalog{dn}.id);
% or
% metap = hapi(Servers{sn},ids{dn},opts);

% MATLAB structure of reduced JSON parameter list
metapr = hapi(Servers{sn}, metad.catalog{dn}.id, metap.parameters{2}.name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scalar time series example. Save as figures/hapi_demo1.png.

server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'X_TOD';
start      = '2012-02-01';
stop       = '2012-02-02';
opts       = struct('logging',1,'use_cache',0);

% Get data
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

% Replace fills with NaN for plotting (so gaps shown in line)
data(data(:,2) == str2num(meta.parameters{2}.fill)) = NaN;

figure(2);clf
    ph = plot(data(:,1),data(:,2));
    th = title(sprintf('%s/id=%s&parameters=%s',...
        server,dataset,meta.parameters{2}.name));
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
    if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end

    print -dpng hapi-figures/hapi_demo2.png
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spectrogram time series example. Save as figures/hapi_demo2.png.

server     = 'http://datashop.elasticbeanstalk.com/hapi';
dataset    = 'CASSINI_LEMMS_PHA_CHANNEL_1_SEC';
parameters = 'A';
start      = '2002-01-01';
stop       = '2002-01-02';

% Get data
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

time  = data(:,1);
data  = data(:,2:end);
bins  = meta.parameters{2}.bins.centers;
% Note bin ranges are given, but not used here.

% Replace fills with NaN for plotting (so white tile is shown)
data(data == str2num(meta.parameters{2}.fill)) = NaN;

m     = min(min(data));
data  = log10(data - m + 1);

figure(1);clf
    % Plot matrix as colored squares.
    p = pcolor(time',log10(bins'),data');
    set(p,'EdgeColor','none'); % Don't show boundaries for squares.
    ch = colorbar;
    title(ch,sprintf('log_{10}(%s + %.1f + 1 [%s])',...
        meta.parameters{2}.name,abs(m),meta.parameters{2}.units));
    th = title(sprintf('%s/id=%s&parameters=%s',...
        server,dataset,meta.parameters{2}.name));
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
    if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end
    print -dpng hapi-figures/hapi_demo1.png
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
