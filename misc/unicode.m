if 1
%%
% Unicode data and dataset & parameter names
server     = 'http://localhost:8999/TestData3.1/hapi';
%server     = 'http://hapi-server.org/servers/TestData3.1/hapi';

dataset = 'dataset1-Zα☃'; % Can work in MATLAB 2020a and later.
% Since MATLAB 2020a, UTF-8 encoded strings are allowed in .m files if
% they are saved with this encoding. For earlier MATLAB versions, execute
% the following 2 lines on the command
% line to get encoded dataset name (will not work if in script).
%   URI = matlab.net.URI(dataset)
%   dataset = char(URI.EncodedURI)
% and then copy output of command above in line below.
dataset = 'dataset1-Z%CE%B1%E2%98%83';

parameters = 'unicodescalar-2-byte (α)'; % Can work in MATLAB 2020a and later.
% See note above for URI encoding parameter string
parameters = 'unicodescalar-2-byte%20(%CE%B1)';

start      = '1970-01-01T00:00:00.000Z';
stop       = '1970-01-01T00:00:03.000Z';
opts       = struct('logging',1,'usecache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
meta
data
end

if 1
%%
% Unicode data works on MATLAB 2018b and 2020a. However, the 4-byte
% UTF-16 string appears as a space in these versions.
server     = 'http://localhost:8999/TestData3.1/hapi';
%server     = 'http://hapi-server.org/servers/TestData3.1/hapi';
dataset    = 'dataset1';
parameters = 'unicodevector';
start      = '1970-01-01T00:00:00.000Z';
stop       = '1970-01-01T00:00:03.000Z';
opts       = struct('logging',1,'usecache',0);

meta = hapi(server, dataset, parameters)

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
meta
data
data.unicodevector{:}
end

