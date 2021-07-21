%% Test Data: All parameters
% If parameters='', HAPI() get all parameters in the dataset and HAPIPLOT
% creates (one or more, as needed) plots for each individually. This demo
% works, but is suppressed.
if (1)
    server     = 'http://hapi-server.org/servers/TestData2.0/hapi';
    dataset    = 'dataset1';
    parameters = '';
    start      = '1970-01-01';
    stop       = '1970-01-01T00:01:00';
    opts       = struct('logging',1);

    [data,meta] = hapi(server, dataset, parameters, start, stop, opts);

    data
    meta
    fprintf('meta.parameters = ');
    meta.parameters{:}

    hapiplot(data,meta)
end

if 0
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
opts       = struct('logging',1,'use_cache',0);

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
end
