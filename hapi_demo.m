%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scalar time series example

server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'X_TOD';
start      = '2012-02-01';
stop       = '2012-02-02';
opts       = struct('logging',1,'use_cache',0);

% Get data
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

% Plot
hapiplot(meta,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spectra example
server     = 'http://datashop.elasticbeanstalk.com/hapi';
dataset    = 'CASSINI_LEMMS_PHA_CHANNEL_1_SEC';
parameters = 'A';
start      = '2002-01-01';
stop       = '2002-01-02';

% Get data
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

% Plot
hapiplot(meta,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

break

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
metad = hapi(Servers{sn})
% or 
% metad = hapi(Servers{sn},opts)

% MATLAB structure of JSON parameter list
metap = hapi(Servers{sn}, metad.catalog{dn}.id)
% or
% metap = hapi(Servers{sn},ids{dn},opts);

% MATLAB structure of reduced JSON parameter list
metapr = hapi(Servers{sn}, metad.catalog{dn}.id, metap.parameters{2}.name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
