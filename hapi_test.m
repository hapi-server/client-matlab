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

%% 3.0 data
server     = 'http://hapi-server.org/servers/TestData3.0/hapi';
dataset    = 'dataset1';
parameters = '';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:11';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)

%% 3.1 data
server     = 'http://hapi-server.org/servers/TestData3.1/hapi';
dataset    = 'dataset1';
parameters = '';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:11';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)

server     = 'http://hapi-server.org/servers/TestData3.1/hapi';
dataset    = 'dataset1-Aα☃';
parameters = '';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:11';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)

server     = 'http://hapi-server.org/servers/TestData3.1/hapi';
dataset    = 'dataset2';
parameters = '';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:11';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)

%% 3.2 data
server     = 'http://hapi-server.org/servers/TestData3.2/hapi';
dataset    = 'DE1/PWI/B_H';
parameters = '';
start      = '1981-09-16T02:19Z';
stop       = '1981-09-17T19:24Z';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)


