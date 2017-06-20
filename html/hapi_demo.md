Contents
--------

-   [Download hapi.m if not found.](#1)
-   [Scalar ephemeris from SSCWeb](#2)
-   [Two scalars from SSCWeb](#3)
-   [Scalar string from SSCWeb](#4)
-   [Vector from CDAWeb](#5)
-   [Jeremy's garage temperatures](#6)
-   [Spectra from CASSINIA S/C](#7)
-   [Test Data: Vector (size = \[3\] in HAPI notation)](#8)
-   [Test Data: 10-element vector (size = \[10\] in HAPI notation)](#9)
-   [Test Data: 3x3 transformation matrix as 1-D HAPI array](#10)
-   [Test Data: 3x3 transformation matrix as 2-D HAPI array](#11)
-   [Test Data: Scalar string parameter](#12)
-   [Test Data: Scalar isotime parameter](#13)
-   [Test Data: Scalar integer parameter (with proposed category map)](#14)
-   [Test Data: Parameter that is two vectors](#15)
-   [Test Data: Vector of strings](#16)
-   [Test Data: 100-element time series with no bins](#17)
-   [Test Data: All parameters](#18)
-   [Request list of known HAPI servers](#19)
-   [List datasets from a server](#20)
-   [Get metadata for all parameters in a dataset](#21)
-   [Get parameter metadata for one parameter in a dataset](#22)

Download hapi.m if not found.<span id="1"></span>
-------------------------------------------------

``` codeinput
if exist('hapi','file') ~= 2
    u = 'https://raw.githubusercontent.com/hapi-server/matlab-client/master/hapi.m';
    urlwrite(u,'hapi.m');
end
```

Scalar ephemeris from SSCWeb<span id="2"></span>
------------------------------------------------

``` codeinput
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
```

``` codeoutput
Reading hapi-data/tsds.org_get_SSCWeb_hapi/ace_X_TOD_20120201_20120202.mat ... Done.

data = 

              Time: [120x24 char]
    DateTimeVector: [120x7 int32]
             X_TOD: [120x1 double]


meta = 

       startDate: '1997-08-25T17:48:00Z'
        stopDate: '2017-08-27T23:36:00Z'
         cadence: 'PT720S'
    creationDate: '2017-06-18T22:48:57.964Z'
            HAPI: '1.1'
          status: [1x1 struct]
      parameters: {2x1 cell}
              x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
    length: 25


ans = 

           name: 'X_TOD'
           type: 'double'
          units: 'R_E'
    description: 'X Position in the Geocentric Equatorial Inertial coordin...'
           fill: '1e31'

hapiplot.m: Wrote ./hapi-figures/ace_X_TOD_20120201_20120202.png
```

![](hapi_demo_01.png)
Two scalars from SSCWeb<span id="3"></span>
-------------------------------------------

``` codeinput
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
```

``` codeoutput
Reading hapi-data/tsds.org_get_SSCWeb_hapi/ace_X_TOD-Y_TOD_20120201_20120202.mat ... Done.

data = 

              Time: [120x24 char]
    DateTimeVector: [120x7 int32]
             X_TOD: [120x1 double]
             Y_TOD: [120x1 double]


meta = 

       startDate: '1997-08-25T17:48:00Z'
        stopDate: '2017-08-27T23:36:00Z'
         cadence: 'PT720S'
    creationDate: '2017-06-18T22:49:01.673Z'
            HAPI: '1.1'
          status: [1x1 struct]
      parameters: {3x1 cell}
              x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
    length: 25


ans = 

           name: 'X_TOD'
           type: 'double'
          units: 'R_E'
    description: 'X Position in the Geocentric Equatorial Inertial coordin...'
           fill: '1e31'


ans = 

           name: 'Y_TOD'
           type: 'double'
          units: 'R_E'
    description: 'Y Position in the Geocentric Equatorial Inertial coordin...'
           fill: '1e31'

hapiplot.m: Wrote ./hapi-figures/ace_X_TOD_20120201_20120202.png
hapiplot.m: Wrote ./hapi-figures/ace_Y_TOD_20120201_20120202.png
```

![](hapi_demo_02.png) ![](hapi_demo_03.png)
Scalar string from SSCWeb<span id="4"></span>
---------------------------------------------

``` codeinput
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
```

``` codeoutput
Reading hapi-data/tsds.org_get_SSCWeb_hapi/ace_LT_GEO_20120201_20120202.mat ... Done.

data = 

              Time: [120x24 char]
    DateTimeVector: [120x7 int32]
            LT_GEO: {[120x8 char]}


meta = 

       startDate: '1997-08-25T17:48:00Z'
        stopDate: '2017-08-27T23:36:00Z'
         cadence: 'PT720S'
    creationDate: '2017-06-18T22:49:05.889Z'
            HAPI: '1.1'
          status: [1x1 struct]
      parameters: {2x1 cell}
              x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
    length: 25


ans = 

           name: 'LT_GEO'
           type: 'string'
          units: '$H:$M:$S'
    description: 'Local time in the Geographic coordinate system, also kno...'
           fill: '99:99:99'
         length: 9

hapiplot.m: Wrote ./hapi-figures/ace_LT_GEO(:,1)_20120201_20120202.png
```

![](hapi_demo_04.png)
Vector from CDAWeb<span id="5"></span>
--------------------------------------

Had to modify hapi.m to work because /info?id=AC\_H0\_MFI&parameters=BGSEc returns all parameters, not just BGSEc. Also note the metadata has the wrong fill value of "-9.999999848243207E30". It should be "-1e31" and a correction was applied below.

``` codeinput
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
```

``` codeoutput
Downloading https://voyager.gsfc.nasa.gov/hapiproto/hapi/info?id=AC_H0_MFI&parameters=BGSEc ... Warning: Server returned too many parameters in
/info request 
Done.
Wrote hapi-data/voyager.gsfc.nasa.gov_hapiproto_hapi/AC_H0_MFI_BGSEc.json ...
Downloading https://voyager.gsfc.nasa.gov/hapiproto/hapi/data?id=AC_H0_MFI&time.min=2002-01-01&time.max=2002-01-02&parameters=BGSEc ... Done.
Reading hapi-data/voyager.gsfc.nasa.gov_hapiproto_hapi/AC_H0_MFI_BGSEc_20020101_20020102.csv ... Done.
Parsing hapi-data/voyager.gsfc.nasa.gov_hapiproto_hapi/AC_H0_MFI_BGSEc_20020101_20020102.csv ... Done.
Saving hapi-data/voyager.gsfc.nasa.gov_hapiproto_hapi/AC_H0_MFI_BGSEc_20020101_20020102.mat ... Done.

data = 

              Time: [5400x23 char]
    DateTimeVector: [5400x7 int32]
             BGSEc: [5400x3 double]


meta = 

            HAPI: '1.0'
    creationDate: '2017/06/20 15:38:28'
      parameters: {[1x1 struct]  [1x1 struct]}
       startDate: '1997-09-02T00:00:12'
        stopDate: '2017-04-11T23:59:53'
              x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
    length: 24


ans = 

           name: 'BGSEc'
           type: 'double'
          units: 'nT'
           fill: '-1e31'
    description: 'Magnetic Field Vector in GSE Cartesian coordinates (16 sec)'
           size: 3

hapiplot.m: Wrote ./hapi-figures/AC_H0_MFI_BGSEc_20020101_20020102.png
```

![](hapi_demo_05.png)
Jeremy's garage temperatures<span id="6"></span>
------------------------------------------------

He is what we call, euphemistically, 'Temperature involved'. Note that hapi.m needed to allow 'float' as a data type for this to work.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/jfaden.net_HapiServerDemo_hapi/0B000800408DD710__20170617T21:20:32.052_20170618T212032520.mat ... Done.

data = 

              Time: [4575x23 char]
    DateTimeVector: [4209x7 int32]
       Temperature: [4209x1 double]


meta = 

               HAPI: '1.1'
          createdAt: '2017-06-18T22:10Z'
         parameters: {2x1 cell}
    sampleStartDate: '2017-06-17T22:10:44.004Z'
     sampleStopDate: '2017-06-18T22:10:44.044Z'
          startDate: '2012-01-09T00:00:00.000Z'
             status: [1x1 struct]
           stopDate: '2017-06-18T22:10:44.044Z'
                 x_: [1x1 struct]

meta.parameters = 
ans = 

    length: 24
      name: 'Time'
      type: 'isotime'
     units: 'UTC'


ans = 

    description: 'temperature in garage, car'
           fill: '-1e31'
           name: 'Temperature'
           type: 'float'
          units: 'deg F'

hapiplot.m: Wrote ./hapi-figures/0B000800408DD710_Temperature_20170617T21:20:32.052_20170618T212032520.png
```

![](hapi_demo_06.png)
Spectra from CASSINIA S/C<span id="7"></span>
---------------------------------------------

HAPIPLOT infers that this should be plotted as a spectra because bins metadata were provided. Note that the first parameter is named time\_array\_0 instead of Time. To allow HAPIPLOT to work, this parameter was renamed before HAPIPLOT was called. This parameter would have been plotted with log\_{10} z-axis automatically by HAPIPLOT because the distribution of values is heavy-tailed, but there were negative values, which are not expected given the units are particles/sec/cm^2/ster/keV.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/datashop.elasticbeanstalk.com_hapi/CASSINI_LEMMS_PHA_CHANNEL_1_SEC_A_20020101_20020102T000600.mat ... Done.

data = 

              Time: [8037x23 char]
    DateTimeVector: [8037x7 int32]
                 A: [8037x55 double]


meta = 

               HAPI: '1.1'
             status: [1x1 struct]
         parameters: {2x1 cell}
          startDate: '2002-01-01T00:00:00.000'
           stopDate: '2016-05-12T21:38:16.000'
    sampleStartDate: '2002-01-02T00:00:00.000'
      sampleEndDate: '2002-01-02T06:00:00.000'
        description: 'Cassini MIMI LEMMS PHA channel intensities with mag ...'
       creationDate: '2017-06-18T22:49:22.000'
            cadence: 'PT1S'
                 x_: [1x1 struct]

meta.parameters = 
ans = 

           name: 'time_array_0'
           type: 'isotime'
         length: 23
          units: 'UTC'
           fill: []
    description: 'time as UTC string to milliseconds'


ans = 

           name: 'A'
           type: 'double'
          units: 'particles/sec/cm^2/ster/keV'
           size: 55
           fill: '-1.0e38'
    description: 'high energy resolution LEMMS spectrum of A channels'
           bins: [1x1 struct]

Warning: Parameter has bin ranges, but hapi_plot
will not use them. 
hapiplot.m: Wrote ./hapi-figures/CASSINI_LEMMS_PHA_CHANNEL_1_SEC_A_20020101_20020102T000600.png
```

![](hapi_demo_07.png)
Test Data: Vector (size = \[3\] in HAPI notation)<span id="8"></span>
---------------------------------------------------------------------

HAPIPLOT infers that this a parameter that should be displayed as multiple time series because the number of components of the vector is &lt; 10. Note that the metadata does not provide labels for the individual components of the vector, so "Column \#" is used in the legend. HAPI metadata should include an option to add column labels.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_vector_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
            vector: [60x3 double]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'vector'
           type: 'double'
          units: 'm'
           fill: '-1e31'
           size: 3
    description: 'Each component is a sine wave with a 600 s period with d...'

hapiplot.m: Wrote ./hapi-figures/dataset1_vector_19700101_19700101T000100.png
```

![](hapi_demo_08.png)
Test Data: 10-element vector (size = \[10\] in HAPI notation)<span id="9"></span>
---------------------------------------------------------------------------------

HAPIPLOT infers that this a parameter that should be displayed as a spectra because the number of vector elements is &gt; 9. Note that the metadata does not provide labels for the individual components of the vector, so "Column" is used as the y-axis label.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_vector_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
            vector: [60x3 double]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'vector'
           type: 'double'
          units: 'm'
           fill: '-1e31'
           size: 3
    description: 'Each component is a sine wave with a 600 s period with d...'

hapiplot.m: Wrote ./hapi-figures/dataset1_vector_19700101_19700101T000100.png
```

![](hapi_demo_09.png)
Test Data: 3x3 transformation matrix as 1-D HAPI array<span id="10"></span>
---------------------------------------------------------------------------

HAPIPLOT infers that this a parameter that should be displayed as a spectra because the number of components is &gt;= 9. Note that the metadata does not provide bins so the y-labels are "Column \#'. In this case the data provider indented to provide a time series of rotation transformation matrices (using Javascript array notation) \[Txx, Txy, Txz, Tyx, Tyy, Tyz, Tzx, Tzy, Tzz\]. HAPI metadata should include the ability to provide these labels.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_transform_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
         transform: [60x9 double]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'transform'
           type: 'double'
          units: 'm'
           fill: '-1e31'
           size: 9
    description: 'Transformation matrix elements Txx, Txy, Txz, Tyx, Tyy, ...'

hapiplot.m: Wrote ./hapi-figures/dataset1_transform_19700101_19700101T000100.png
```

![](hapi_demo_10.png)
Test Data: 3x3 transformation matrix as 2-D HAPI array<span id="11"></span>
---------------------------------------------------------------------------

HAPIPLOT displays each layer of the matrix as three time series with y-labels tranformmulti(:,:,1), transformmulti(:,:,2), and transformmulti(:,:,3) and legend labels of "Column \#", where \# = 1, 2, or 3. In this case the data provided intended to provided a time series of rotation matrices with labels (using HAPI array notation) \[\['Txx','Txy','Txz'\],\['Tyx','Tyy','Tyz'\],\['Tzx','Tzy','Tzz'\]\]. HAPI should include the ability to provide these labels.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_transformmulti_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
    transformmulti: [60x3x3 double]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'transformmulti'
           type: 'double'
          units: 'm'
           fill: '-1e31'
           size: [2x1 double]
    description: '3-D transformation matrix'

hapiplot.m: Wrote ./hapi-figures/dataset1_transformmulti(:,:,1)_19700101_19700101T000100.png
hapiplot.m: Wrote ./hapi-figures/dataset1_transformmulti(:,:,2)_19700101_19700101T000100.png
hapiplot.m: Wrote ./hapi-figures/dataset1_transformmulti(:,:,3)_19700101_19700101T000100.png
```

![](hapi_demo_11.png) ![](hapi_demo_12.png) ![](hapi_demo_13.png)
Test Data: Scalar string parameter<span id="12"></span>
-------------------------------------------------------

Demonstrating how HAPIPLOT handles this type of parameter.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_scalarstr_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
         scalarstr: {[60x3 char]}


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'scalarstr'
           type: 'string'
          units: []
           fill: []
         length: 4
    description: 'Status checks result; P = Pass, F = Fail'

hapiplot.m: Wrote ./hapi-figures/dataset1_scalarstr(:,1)_19700101_19700101T000100.png
```

![](hapi_demo_14.png)
Test Data: Scalar isotime parameter<span id="13"></span>
--------------------------------------------------------

HAPIPLOT converts the isotime string to a MATLAB DATENUM to create y-axis labels.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_scalariso_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
         scalariso: {[60x20 char]}


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'scalariso'
           type: 'isotime'
          units: 'UTC'
           fill: '0000-00-00:T00:00:00Z'
         length: 21
    description: 'Time parameter + 1 second'

hapiplot.m: Wrote ./hapi-figures/dataset1_scalariso(:,1)_19700101_19700101T000100.png
```

![](hapi_demo_15.png)
Test Data: Scalar integer parameter (with proposed category map)<span id="14"></span>
-------------------------------------------------------------------------------------

A time series of integers intended to communicate a status represented by a string. The metadata includes a (non-HAPI standard) map from an integer to a string, and this map is used to generate y-axis labels.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_scalarcats_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
        scalarcats: [60x1 int32]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'scalarcats'
           type: 'integer'
          units: []
           fill: []
    categorymap: [1x1 struct]
    description: 'Category of personality'

hapiplot.m: Wrote ./hapi-figures/dataset1_scalarcats_19700101_19700101T000100.png
```

![](hapi_demo_16.png)
Test Data: Parameter that is two vectors<span id="15"></span>
-------------------------------------------------------------

HAPIPLOT creates two time series plots in this case and labels the first using MATLAB notation as vectormulti(:,:,1) and second as vectormulti(:,:,2).

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_vectormulti_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
       vectormulti: [60x3x2 double]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'vectormulti'
           type: 'double'
          units: 'm'
           fill: '-1e31'
           size: [2x1 double]
    description: 'Two vectors; Each component of each vector is a sine wav...'

hapiplot.m: Wrote ./hapi-figures/dataset1_vectormulti(:,:,1)_19700101_19700101T000100.png
hapiplot.m: Wrote ./hapi-figures/dataset1_vectormulti(:,:,2)_19700101_19700101T000100.png
```

![](hapi_demo_17.png) ![](hapi_demo_18.png)
Test Data: Vector of strings<span id="16"></span>
-------------------------------------------------

In this unusual dataset, 3-vector (size = \[3\] in HAPI notation) of strings is given. HAPIPLOT creates three time series plots, one for each vector component.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_vectorstr_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
         vectorstr: {[60x3 char]  [60x3 char]  [60x3 char]}


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'vectorstr'
           type: 'string'
          units: []
           fill: []
         length: 4
           size: 3
    description: 'Status checks result; P = Pass, F = Fail'

hapiplot.m: Wrote ./hapi-figures/dataset1_vectorstr(:,1)_19700101_19700101T000100.png
hapiplot.m: Wrote ./hapi-figures/dataset1_vectorstr(:,2)_19700101_19700101T000100.png
hapiplot.m: Wrote ./hapi-figures/dataset1_vectorstr(:,3)_19700101_19700101T000100.png
```

![](hapi_demo_19.png) ![](hapi_demo_20.png) ![](hapi_demo_21.png)
Test Data: 100-element time series with no bins<span id="17"></span>
--------------------------------------------------------------------

HAPIPLOT assumes that this is best plotted as a spectra because the number of elements is greater than 9.

``` codeinput
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
```

``` codeoutput
Reading hapi-data/mag.gmu.edu_TestData_hapi/dataset1_spectranobins_19700101_19700101T000100.mat ... Done.

data = 

              Time: [60x23 char]
    DateTimeVector: [60x7 int32]
     spectranobins: [60x10 double]


meta = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:09'
     x_maxDurations: [1x1 struct]
            cadence: 'PT1S'
         parameters: {[1x1 struct]  [1x1 struct]}
               HAPI: '1.1'
             status: [1x1 struct]
                 x_: [1x1 struct]

meta.parameters = 
ans = 

      name: 'Time'
      type: 'isotime'
     units: 'UTC'
      fill: []
    length: 24


ans = 

           name: 'spectranobins'
           type: 'double'
          units: 'm'
           fill: '-1e31'
           size: 10
    description: 'A time independent 1/f spectra.'

hapiplot.m: Wrote ./hapi-figures/dataset1_spectranobins_19700101_19700101T000100.png
```

![](hapi_demo_22.png)
Test Data: All parameters<span id="18"></span>
----------------------------------------------

If parameters='', HAPI() get all parameters in the dataset and HAPIPLOT creates (one or more, as needed) plots for each individually. This demo works, but is suppressed.

``` codeinput
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
```

Request list of known HAPI servers<span id="19"></span>
-------------------------------------------------------

``` codeinput
Servers = hapi()
```

``` codeoutput
Servers = 

    'http://datashop.elasticbeanstalk.com/hapi'
    'http://tsds.org/get/SSCWeb/hapi'
    'http://mag.gmu.edu/TestData/hapi'
```

List datasets from a server<span id="20"></span>
------------------------------------------------

``` codeinput
sn = 3; % Server number of interest
metad = hapi(Servers{sn})
% or
% metad = hapi(Servers{sn},opts)
```

``` codeoutput
See the interface at <a href="http://tsds.org/get/#catalog=TestData">http://tsds.org/get/#catalog=TestData</a>
to search and explore datasets from the <a href="http://mag.gmu.edu/TestData/hapi">TestData</a> HAPI Server.

metad = 

    catalog: {3x1 cell}
       HAPI: '1.1'
     status: [1x1 struct]
```

Get metadata for all parameters in a dataset<span id="21"></span>
-----------------------------------------------------------------

``` codeinput
dn = 1; % Dataset number from server number sn
metap = hapi(Servers{sn}, metad.catalog{dn}.id)
% or
% metap = hapi(Servers{sn},ids{dn},opts);
```

``` codeoutput
See the interface at <a href="http://tsds.org/get/#catalog=TestData&dataset=dataset0">http://tsds.org/get/#catalog=TestData&dataset=dataset0</a>
to search and explore parameters in this dataset from the <a href="http://mag.gmu.edu/TestData/hapi">TestData</a> HAPI Server.

metap = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:10'
            cadence: 'PT1M'
         parameters: {19x1 cell}
```

Get parameter metadata for one parameter in a dataset<span id="22"></span>
--------------------------------------------------------------------------

``` codeinput
pn = 2; % Parameter number pn in dataset dn from server sn
metapr = hapi(Servers{sn}, metad.catalog{dn}.id, metap.parameters{pn}.name)
% or
% metapr = hapi(Servers{sn}, metad.catalog{dn}.id, metap.parameters{pn}.name)
```

``` codeoutput
Warning: Server returned too many parameters in
/info request 

data = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:10'
            cadence: 'PT1M'
         parameters: {[1x1 struct]  [1x1 struct]  [1x1 struct]}


metapr = 

          startDate: '1970-01-01'
           stopDate: '2016-12-31'
    sampleStartDate: '1970-01-01'
     sampleStopDate: '1970-01-01T00:00:10'
            cadence: 'PT1M'
         parameters: {[1x1 struct]  [1x1 struct]  [1x1 struct]}
```

[Published with MATLAB® R2015a](http://www.mathworks.com/products/matlab/)
