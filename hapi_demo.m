clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Download hapiplot.m if not found.
if exist('hapiplot','file') ~= 2
    u = 'https://raw.githubusercontent.com/hapi-server/matlab-client/master/hapi.m';
    urlwrite(u,'hapi.m');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

format = 'csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scalar and vector example
%server     = 'http://mag.gmu.edu/TestData/hapi';
server     = 'http://localhost:8999/hapi';
dataset    = 'TestData';
parameters = 'scalar,scalarcats';
start      = '1970-01-01';
stop       = '1970-01-01T00:00:10';
opts       = struct('format',format,'logging',1,'use_cache',0);


[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

hapiplot(data,meta)

break

format = 'csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scalar and vector example
server     = 'http://mag.gmu.edu/TestData/hapi';
%server     = 'http://localhost:8999/hapi'
dataset    = 'TestData';
parameters = 'scalar,scalarint,vector';
start      = '1970-01-01';
stop       = '1970-01-01T00:00:10';
opts       = struct('format',format,'logging',1,'use_cache',0);


[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
% data is structure with fields:
% data.Time           % time string as represented in server response
% data.DataTimeVector % yr,mo,dy,hr,mn,sc,...
% data.scalar         % first parameter in parameters string
% data.scalarint      % etc.
% data.vector
hapiplot(data,meta)
break

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scalar time series example

server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'X_TOD';
start      = '2012-02-01';
stop       = '2012-02-02';
opts       = struct('logging',1,'use_cache',0);

% Get data and metadata
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
opts       = struct('logging',1,'use_cache',0);

% Get data and metadata
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

% Plot
hapiplot(meta,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
