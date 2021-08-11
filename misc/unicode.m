%feature('DefaultCharacterSet', 'UTF8');

%server     = 'https://jfaden.net/HapiServerDemo/hapi';
server     = 'http://localhost:8999/TestData3.1/hapi';

%dataset    = '%E7%88%B1%E8%8D%B7%E5%8D%8E%E5%9F%8E%E5%A4%A9%E6%B0%94';
%dataset    = '??????';
dataset = 'dataset1';
%parameters = 'unicodescalar-1-byte,unicodescalar-2-byte,unicodescalar-3-byte';
parameters = 'unicodevector';
%start      = '2021-07-24T00:00:00.000Z';
%stop       = '2021-07-25T00:00:00.000Z';
start      = '1970-01-01T00:00:00.000Z';
stop       = '1970-01-01T00:00:03.000Z';
opts       = struct('logging',1,'usecache',0);

URI = matlab.net.URI(dataset)
dataset = char(URI.EncodedURI)

meta = hapi(server, dataset, parameters)

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

if 0
    data
    meta
    fprintf('meta.parameters = ');
    meta.parameters{:}

    hapiplot(data,meta)
end