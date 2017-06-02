clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tests if hapi.m
server     = 'http://mag.gmu.edu/TestData/hapi';
%server     = 'http://localhost:8999/hapi';
dataset    = 'TestData';
parameters = 'scalar';
start      = '1970-01-01';
stop       = '1970-01-01T00:00:10';

% Get data using binary transport
opts = struct('logging',1,'use_cache',0,'use_binary',1);
[data1,meta1] = hapi(server,dataset,parameters,start,stop,opts);

% Get data using ascii transport
opts = struct('logging',1,'use_cache',0,'use_binary',0);
[data2,meta2] = hapi(server,dataset,parameters,start,stop,opts);

% Get data using cache
opts = struct('logging',1,'use_cache',1,'use_binary',1);
[data3,meta3] = hapi(server,dataset,parameters,start,stop,opts);

if ~all(data1(:) == data2(:))
    error('Data do not match');
end

if ~all(data1(:) == data3(:))
    error('Data do not match');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
