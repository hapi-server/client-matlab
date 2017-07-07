%% Use local TestData server if it is running.
url = 'http://localhost:8999/hapi';
[str,stat]  = urlread(url);
if stat ~= 1 % Not runing test server locally.  Use public version.
    url = 'http://mag.gmu.edu/TestData/hapi';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Jeremy's garage temperatures
% He is what we call, euphemistically, 'Temperature involved'.
% Note that hapi.m needed to allow 'float' as a data type
% for this to work.
server     = 'http://jfaden.net/HapiServerDemo/hapi';
dataset    = '0B000800408DD710';
parameters = '';
start      = '2017-06-17T21:20:32.052';
stop       = '2017-06-18T21:20:32.520';
opts       = struct('logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'0B000800408DD710')


break
%% Spectra from CASSINIA S/C
% HAPIPLOT infers that this should be plotted as a spectra because bins
% metadata were provided. Note that the first parameter is named
% time_array_0 instead of Time. To allow HAPIPLOT to work, this parameter
% was renamed before HAPIPLOT was called.  This parameter would have been
% plotted with log_{10} z-axis automatically by HAPIPLOT because the
% distribution of values is heavy-tailed, but there were negative values,
% which are not expected given the units are particles/sec/cm^2/ster/keV.
server     = 'http://datashop.elasticbeanstalk.com/hapi';
dataset    = 'CASSINI_LEMMS_PHA_CHANNEL_1_SEC';
parameters = 'A';
start      = '2002-01-01';
stop       = '2002-01-02T00:06:00';
opts       = struct('logging',1);

% Get data and metadata
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}
meta.parameters{1}.name = 'Time'; % Fix error in metadata.
% Plot
hapiplot(data,meta)


break

%% Two scalars from SSCWeb
% 
server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'X_TOD,Y_TOD';
start      = '2012-02-01';
stop       = '2012-02-02';
opts       = struct('logging',1);

% Get data and metadata
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

% Plot
hapiplot(data,meta)

break

server     = 'https://voyager.gsfc.nasa.gov/hapiproto/hapi';
dataset    = 'AC_H0_MFI';
parameters = 'BGSEc';
start      = '2002-01-01';
stop       = '2002-01-02';
opts       = struct('logging',1,'use_cache',0);

% Get data and metadata
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

meta.parameters{2}.fill = '-1e31';
% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}
meta.parameters{1}.name = 'Time'; % Fix error in metadata.
% Plot
hapiplot(data,meta)

break

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Should be an error.  Output file has columns that are
% inconsistent with what is expected from /info request for 
% parameter list.
server     = url;
dataset    = 'dataset0'; % Dataset with intentional problems for testing.
parameters = 'spectranobins';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('format',format,'logging',1,'use_cache',0);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);
hapiplot(data,meta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
