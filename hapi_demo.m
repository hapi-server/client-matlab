%% Download hapi.m if not found.
% 
if exist('hapi','file') ~= 2
    u = 'https://raw.githubusercontent.com/hapi-server/matlab-client/master/hapi.m';
    urlwrite(u,'hapi.m');
end

%%  Scalar ephemeris from SSCWeb
%
server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'X_TOD';
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

%% Scalar string from SSCWeb
%

server     = 'http://tsds.org/get/SSCWeb/hapi';
dataset    = 'ace';
parameters = 'LT_GEO';
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

%% Vector from CDAWeb
% Had to modify hapi.m to work because /info?id=AC_H0_MFI&parameters=BGSEc
% returns all parameters, not just BGSEc. Also note the metadata has
% the wrong fill value of "-9.999999848243207E30".  It should be "-1e31"
% and a correction was applied below.
server     = 'https://voyager.gsfc.nasa.gov/hapiproto/hapi';
dataset    = 'AC_H0_MFI';
parameters = 'BGSEc';
start      = '2002-01-01';
stop       = '2002-01-02';
opts       = struct('logging',1,'use_cache',0);

% Get data and metadata
[data,meta] = hapi(server,dataset,parameters,start,stop,opts);

meta.parameters{2}.fill = '-1e31'; % Correct fill value.
% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}
meta.parameters{1}.name = 'Time'; % Fix error in metadata.
% Plot
hapiplot(data,meta)

%% Jeremy's garage temperatures
% He is what we call, euphemistically, 'Temperature involved'.
% Note that hapi.m needed to allow 'float' as a data type
% for this to work.
server     = 'http://jfaden.net/HapiServerDemo/hapi';
dataset    = '0B000800408DD710';
parameters = '';
start      = '2017-06-17T21:20:32.052';
stop       = '2017-06-18T21:20:32.520';
opts       = struct('logging',1,'use_cache',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'0B000800408DD710')

%% Spectra from CASSINIA S/C
% HAPIPLOT infers that this should be plotted as a spectra because bins
% metadata were provided. Note that the returned data is for six hours but
% the plot shows that the data extend over 24 hours.  This appears to be a
% bug in MATLAB's DATETICK function. Also note that the first parameter is
% named time_array_0 instead of Time. To allow HAPIPLOT to work, this
% parameter was renamed before HAPIPLOT was called.  This parameter would
% have been plotted with log_{10} y-axis, but there were negative values,
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

%% Test Data: Vector (size = [3] in HAPI notation)
% HAPIPLOT infers that this a parameter that should be displayed as
% multiple time series because the number of components of the vector
% is < 10. Note that the metadata does not provide labels for the
% individual components of the vector, so "Column #" is used in the
% legend. HAPI metadata should include an option to add column labels.
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'vector';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

% Plot
hapiplot(data,meta)
% or
% hapiplot(data,meta,'vector')

%% Test Data: 10-element vector (size = [10] in HAPI notation)
% HAPIPLOT infers that this a parameter that should be displayed as
% a spectra because the number of vector elements is > 9. Note that the 
% metadata does not provide labels for the individual components of the
% vector, so "Column" is used as the y-axis label.
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'vector';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

% Plot
hapiplot(data,meta)
% or
% hapiplot(data,meta,'vector')

%% Test Data: 3x3 transformation matrix as 1-D HAPI array
% HAPIPLOT infers that this a parameter that should be displayed as
% a spectra because the number of components is >= 9. Note that the
% metadata does not provide bins so the y-labels are "Column #'.  In this
% case the data provider indented to provide a time series of rotation
% transformation matrices  (using Javascript array notation)
% [Txx, Txy, Txz, Tyx, Tyy, Tyz, Tzx, Tzy, Tzz]. HAPI metadata should 
% include the ability to provide these labels.
server     = 'http://mag.gmu.edu/TestData/hapi';
dataset    = 'dataset1';
parameters = 'transform';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

% Plot
hapiplot(data,meta)
% or
% hapiplot(data,meta,'transform')

%% Test Data: 3x3 transformation matrix as 2-D HAPI array
% HAPIPLOT displays each layer of the matrix as three time series with
% y-labels tranformmulti(:,:,1), transformmulti(:,:,2), and
% transformmulti(:,:,3) and legend labels of "Column #", where # = 1, 2, or
% 3. In this case the data provided intended to provided a time series of
% rotation matrices with labels (using HAPI array notation)
% [['Txx','Txy','Txz'],['Tyx','Tyy','Tyz'],['Tzx','Tzy','Tzz']]. HAPI
% should include the ability to provide these labels.
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'transformmulti';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

% Plot
hapiplot(data,meta)
% or
% hapiplot(data,meta,'transformulti')

%% Test Data: Scalar string parameter
% Demonstrating how HAPIPLOT handles this type of parameter.
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'scalarstr';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'scalarstr')

%% Test Data: Scalar isotime parameter
% HAPIPLOT converts the isotime string to a MATLAB DATENUM to create
% y-axis labels.
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'scalariso';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'scalariso')

%% Test Data: Scalar integer parameter (with proposed category map)
% A time series of integers intended to communicate a status represented by
% a string.  The metadata includes a (non-HAPI standard) map from an
% integer to a string, and this map is used to generate y-axis labels.
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'scalarcats';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'scalarcats')

%% Test Data: Parameter that is two vectors
% HAPIPLOT creates two time series plots in this case and labels the first
% using MATLAB notation as vectormulti(:,:,1) and second as
% vectormulti(:,:,2).
server     = 'http://mag.gmu.edu/TestData/hapi'; ;
dataset    = 'dataset1';
parameters = 'vectormulti';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'vectormulti')

%% Test Data: Vector of strings
% In this unusual dataset, 3-vector (size = [3] in HAPI notation) of
% strings is given. HAPIPLOT creates three time series plots, one for each
% vector component.
server     = 'http://mag.gmu.edu/TestData/hapi';
dataset    = 'dataset1';
parameters = 'vectorstr';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'vectorstr')

%% Test Data: 100-element time series with no bins
% HAPIPLOT assumes that this is best plotted as a spectra because
% the number of elements is greater than 9.
server     = 'http://mag.gmu.edu/TestData/hapi';
dataset    = 'dataset1';
parameters = 'spectranobins';
start      = '1970-01-01';
stop       = '1970-01-01T00:01:00';
opts       = struct('logging',1);

[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% Display information
data
meta
fprintf('meta.parameters = ');
meta.parameters{:}

hapiplot(data,meta)
% or
% hapiplot(data,meta,'spectranobins')

%% Test Data: All parameters
% If parameters='', HAPI() get all parameters in the dataset and HAPIPLOT
% creates (one or more, as needed) plots for each individually. This demo
% works, but is suppressed.
    if (0)
    server     = 'http://mag.gmu.edu/TestData/hapi';
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

%% Request list of known HAPI servers
% 
Servers = hapi()

%% List datasets from a server
% 
sn = 3; % Server number of interest
metad = hapi(Servers{sn})
% or 
% metad = hapi(Servers{sn},opts)

%% Get metadata for all parameters in a dataset 
%
dn = 1; % Dataset number from server number sn
metap = hapi(Servers{sn}, metad.catalog{dn}.id)
% or
% metap = hapi(Servers{sn},ids{dn},opts);

%% Get parameter metadata for one parameter in a dataset
%
pn = 2; % Parameter number pn in dataset dn from server sn
metapr = hapi(Servers{sn}, metad.catalog{dn}.id, metap.parameters{pn}.name)
% or
% metapr = hapi(Servers{sn}, metad.catalog{dn}.id, metap.parameters{pn}.name)