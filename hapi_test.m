close all

%% 2.0 data
server     = 'http://hapi-server.org/servers/TestData2.0/hapi';
dataset    = 'dataset1';
parameters = '';
start      = '1970-01-01';
stop       = '1970-01-01T00:00:11';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)

%% 2.1 data
server     = 'http://hapi-server.org/servers/TestData2.1/hapi';
dataset    = 'dataset1';
parameters = '';
start      = '1970-01-01';
stop       = '1970-01-01T00:00:11';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)
