function [data, meta] = hapi(SERVER, DATASET, PARAMETERS, START, STOP, OPTS)
% HAPI - Interface to Heliophysics Data Environment API
%
%   Version 2017-05-26.
%
%   Get metadata and data from a HAPI v1.1 compliant data server
%   (https://github.com/hapi-server/).  See note below for GUI options for
%   selecting data.
%
%   Servers = HAPI() or HAPI() returns or lists data server URLs from know
%   HAPI servers listed at
%   https://github.com/hapi-server/data-specification/blob/master/servers.txt
%
%   Dataset = HAPI(Server) or HAPI(Server) returns or lists datasets
%   available at server URL.
%
%   Parameters = HAPI(Server, Dataset) or HAPI(...) returns or
%   lists parameters in Dataset.
%
%   Metadata = HAPI(Server, Dataset, Parameters) or HAPI(...) returns or
%   lists metadata associated each parameter. The Parameters input 
%   can be a string or cell array.
%
%   [Data,Metadata] = HAPI(Server, Dataset, Parameters, Start, Stop) or HAPI(...)
%   returns a matrix of data.  Start and Stop are ISO8601 time stamps.
%   First column of Data is time converted to MATLAB datenum.  If
%   Parameters = '', all parameters are returned.
%
%   Options are set by passing a structure as the last argument with fields
%
%       logging (default false) - Log to console.
%       cache_hapi (default true) - Save server response files in ./hapi-data.
%       use_cache (default true) - Use cache file in ./hapi-data if found.
%   
%   e.g., to reverse default options, use
%       OPTS = struct();
%       OPTS.logging      = 1;
%       OPTS.cache_hapi   = 0;
%       OPTS.use_cache    = 0;
%       HAPI(...,OPTS)
%
%   This is a command-line only interface.  For a GUI for browsing
%   catalogs and datasets and selecting a dataset and parameters, see
%   http://tsds.org/get/.  Select a catalog, dataset, parameter, and
%   time range and then request a MATLAB script as an output.  A script
%   will be generated that can be pasted onto the command line.
%
%   Example: Open http://tsds.org/get/ and select drop-down options
%            SSCWeb, ACE, X_TOD, Script, MATLAB
%            and the following script will be shown
%              urlwrite('https://github.com/hapi-server/matlab-client/blob/master/','hapi.m');
%              [data,meta] = hapi('http://tsds.org/get/SSCWeb/hapi/','ace','X_TOD','2017-04-23','2017-04-24');
%            Copy and paste these two lines in MATLAB.
%
%   See also HAPI_DEMO, DATENUM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: R.S Weigel <rweigel@gmu.edu>
% License: This is free and unencumbered software released into the public domain.
% Repository: https://github.com/hapi-server/matlab-client.git
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default Options
%
% Implemented
DOPTS = struct();
DOPTS.update_script = 0;
DOPTS.logging       = 0;
DOPTS.cache_mlbin   = 1; % Save data requested in MATLAB binary for off-line use.
DOPTS.cache_hapi    = 1; % Save responses in files (HAPI CSV, JSON, and Binary) for debugging/sharing.
DOPTS.use_cache     = 1; % Use cached MATLAB binary file associated with request if its exists.
DOPTS.format        = 'csv'; % If 'csv', request for HAPI CSV will be made even if server supports HAPI Binary. 

DOPTS.serverlist    = 'https://raw.githubusercontent.com/hapi-server/data-specification/master/servers.txt';
DOPTS.scripturl     = 'https://raw.githubusercontent.com/hapi-server/matlab-client/master/hapi.m';

% TODO: These are not implemented.
%DOPTS.split_long    = 0; % Split long requests into chunks and fetch chunks.
%DOPTS.parallel_req  = 0; % Use parallel requests for chunks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract options (TODO: find better way to do this.)
nin = nargin;
if exist('SERVER','var') && isstruct(SERVER),OPTS = SERVER;clear SERVER;end
if exist('DATASET','var') && isstruct(DATASET),OPTS = DATASET;clear DATASET;;end
if exist('PARAMETERS','var') && isstruct(PARAMETERS),OPTS = PARAMETERS;;end
if exist('START','var') && isstruct(START),OPTS = START;clear START;;end
if exist('STOP','var') && isstruct(STOP),OPTS = STOP;clear STOP;end

if exist('OPTS','var')
    keys = fieldnames(OPTS);
    nin = nin-1;
    if length(keys)
        for i = 1:length(keys)
            DOPTS = setfield(DOPTS,keys{i},getfield(OPTS,keys{i}));
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get latest version of script
if (DOPTS.update_script)
    % http://www.mathworks.com/matlabcentral/fileexchange/55746-javamd5
    md = java.security.MessageDigest.getInstance('MD5');
    fid = fopen('hapi.m','r');
    digest = dec2hex(typecast(md.digest(fread(fid, inf, '*uint8')),'uint8'));
    fclose(fid);
    md5a = lower(reshape(digest',1,[]));
    urlwrite(DOPTS.scripturl,'.hapi.m');
    fid = fopen('.hapi.m','r');
    digest = dec2hex(typecast(md.digest(fread(fid, inf, '*uint8')),'uint8'));
    fclose(fid);
    md5b = lower(reshape(digest',1,[]));
    if (isempty(strmatch(md5a,md5b)))
        %reply = input('Newer version of hapi.m found.  Install? [y]/n:','s');
        %if strcmp(lower(reply),'y')
        fname = sprintf('.hapi.m.%s',datestr(now,29));
        movefile('hapi.m',fname);
        movefile('.hapi.m','hapi.m');
        fprintf('Updated hapi.m. Old version saved as %s. Use options to disable updates.\n',fname);
        %else
        %    fprintf('Not updating hapi.m. Update attempts can be disabled with options.\n');
        %end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Servers
if (nin == 0)
    if (DOPTS.logging) fprintf('Reading %s ... ',DOPTS.serverlist);end
    str = urlread(DOPTS.serverlist);
    data = strread(str,'%s','delimiter',sprintf('\n'));
    if (DOPTS.logging) fprintf('Done.\n');end

    if (DOPTS.logging || nargout == 0) 
        fprintf('List of HAPI servers in %s:\n',DOPTS.serverlist);
        for i = 1:length(data)
            fprintf('  %s\n',data{i});
        end
        fprintf('\n');
    end
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Get this from servers.json
keys = {'http://datashop.elasticbeanstalk.com/hapi','http://tsds.org/get/SSCWeb/hapi','http://mag.gmu.edu/TestData/hapi'};
vals = {'DataShop','SSCWeb','TestData'};
smap = containers.Map(keys,vals);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datasets
if (nin == 1)

    if isKey(smap,SERVER)
        catalog = smap(SERVER);
        turl = sprintf('http://tsds.org/get/#catalog=%s',catalog);
        fprintf('See the interface at <a href="%s">%s</a>\nto search and explore datasets from the <a href="%s">%s</a> HAPI Server.\n',turl,turl,SERVER,catalog);
    end

    url = [SERVER,'/catalog/'];
    if (DOPTS.logging),fprintf('Reading %s ... ',url);end

    opts = weboptions('ContentType', 'json');
    try
        data = webread(url,opts);
    catch err
        error(err.message);
        return
    end
    
    if (DOPTS.logging || nargout == 0),fprintf('\nAvailable datasets from %s:\n',SERVER);end

    if isstruct(data.catalog) 
        % Make data.catalog cell array of structs.
        % Why is data.catalog a struct array instead of
        % a cell array of structs like data.parameters?
        % Perhaps when JSON array has objects with only one key?
        ids = {data.catalog.id};
        for i = 1:length(ids)
           tmp{i} = struct('id',ids{i});
        end
        data.('catalog') = tmp;
    end

    for i = 1:length(data.catalog)
        if (DOPTS.logging || nargout == 0),fprintf('  %s\n',data.catalog{i}.id);end
    end
    if (DOPTS.logging || nargout == 0),fprintf('\n');end
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
if (nin == 2)

    if isKey(smap,SERVER)
        catalog = smap(SERVER);
        turl = sprintf('http://tsds.org/get/#catalog=%s&dataset=%s',catalog,DATASET);
        fprintf('See the interface at <a href="%s">%s</a>\nto search and explore parameters in this dataset from the <a href="%s">%s</a> HAPI Server.\n',turl,turl,SERVER,catalog);
    end

    url = [SERVER,'/info?id=',DATASET];

    if (DOPTS.logging) fprintf('Downloading %s ... ',url);end
	opts = weboptions('ContentType', 'json');
    try
        data = webread(url,opts);
    catch err
        error(err.message);
        return
    end    
    if (DOPTS.logging) fprintf('Done.\n');end

    start = data.startDate;
    stop  = data.stopDate;

    if (DOPTS.logging || nargout == 0)
        fprintf('Available parameters in %s from %s:\n',DATASET,SERVER);
        fprintf('Time range of availability: %s-%s\n',start,stop);
        for i=1:length(data.parameters)
            desc = 'No description';
            if isfield(data.parameters{i},'description')
                desc = data.parameters{i}.description;
            end
            fprintf('  %s - %s\n',data.parameters{i}.name,desc);
        end
    end
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data

if (nin == 3 || nin == 5)

    if iscell(PARAMETERS)
        PARAMETERS = sprintf('%s,',PARAMETERS{:});
        PARAMETERS = PARAMETERS(1:end-1); % Remove trailing comma
    end
    
    if (DOPTS.cache_mlbin || DOPTS.cache_hapi || DOPTS.use_cache)
        urld = regexprep(SERVER,'https*://(.*)','$1');
        urld = ['hapi-data',filesep(),regexprep(urld,'/','_')];
        if (nin == 5)
            fname = sprintf('%s_%s_%s_%s',...
                            DATASET,...
                            regexprep(PARAMETERS,',','-'),...
                            regexprep(START,'-|:\.|Z',''),...
                            regexprep(STOP,'-|:|\.|Z',''));
            fnamecsv  = [urld,filesep(),fname,'.csv'];
            fnamebin  = [urld,filesep(),fname,'.bin'];
            fnamefbin = [urld,filesep(),fname,'.fbin'];
            fnamemat  = [urld,filesep(),fname,'.mat'];
            urlcsv  = [SERVER,'/data?id=',DATASET,'&parameters=',PARAMETERS,'&time.min=',START,'&time.max=',STOP];
            urlfbin = [urlcsv,'&format=fbinary'];
            urlbin  = [urlcsv,'&format=binary'];
        end        
        urljson = [SERVER,'/info?id=',DATASET,'&parameters=',PARAMETERS];
        fnamejson = sprintf('%s_%s',DATASET,regexprep(PARAMETERS,',','-'));
        fnamejson = [urld,filesep(),fnamejson,'.json'];
    end

    if (DOPTS.use_cache) && nin == 5
        if exist(fnamemat,'file')
            if (DOPTS.logging) fprintf('Reading %s ... ',fnamemat);end
                load(fnamemat);
            if (DOPTS.logging) fprintf('Done.\n');end
        end
    end

    if (DOPTS.cache_mlbin || DOPTS.cache_hapi)
        if ~exist('hapi-data','dir')
            mkdir('hapi-data');
        end
        if ~exist(urld,'dir')
            mkdir(urld);
        end    
    end
    
    if (DOPTS.logging) fprintf('Downloading %s ... ',urljson);end
	opts = weboptions('ContentType', 'json');
    try
        meta = webread(urljson,opts);
    catch err
        error(err.message);
        return
    end
    
    if (DOPTS.logging) fprintf('Done.\n');end
    if (nin == 3)
        data = meta
        return
    end

    if (DOPTS.cache_hapi)
        % Ideally meta variable would be serialized meta to JSON, so second
        % request is not needed, but serialization is not simple to do.
        % TODO: Look at code for webread() to find out what
        % undocumented function is used to convert JSON to MATLAB
        % structure.  Then use urlread() instead of webread() above 
        % so the following request is not needed.
        urlwrite(urljson,fnamejson);
        if (DOPTS.logging) fprintf('Wrote %s ...\n',fnamejson);end
    end

    if ~strcmp(DOPTS.format,'csv')
        % Determine if server supports binary
        url = [SERVER,'/capabilities'];
        if (DOPTS.logging) fprintf('Reading %s ... ',url);end
        opts = weboptions('ContentType', 'json');
        caps = webread(url,opts);
        if (DOPTS.logging) fprintf('Done.\n');end
        if any(strcmp(caps.outputFormats,'binary'))
            binaryavailable = 1;
        end
    end
    
    if ~strcmp(DOPTS.format,'csv') && binaryavailable
        % Binary read.
        % TODO: Account for mixed types?  But can't have single array
        % with integer and doubles.  
        if (DOPTS.logging) fprintf('Downloading %s ... ',urlfbin);end
        % Fastest if downloaded to file then read insted of read into 
        % memory directly.
        urlwrite(urlfbin,fnamefbin);
        if (DOPTS.logging) fprintf('Done.\n');end
        if (DOPTS.logging) fprintf('Reading %s ... ',fnamefbin);end
        fid = fopen(fnamefbin);
        p = char(fread(fid,21,'uint8=>char'));
        n = str2num(p(1));
        data = fread(fid,'double'); 
        fclose(fid);
        if (DOPTS.logging) fprintf('Done.\n');end
        size = 1 + meta.parameters{2}.size;
        data = reshape(data,size,length(data)/size)';
        zerotime = p(2:end)';
        data(:,1) = datenum(zerotime,'yyyy-mm-ddTHH:MM:SS') + data(:,1)/(86400*10^(3*n));

        if ~DOPTS.cache_hapi
            rmfile(fnamefbin);
        end
        
        meta.x_.format    = 'csv';
        meta.x_.url       = urlbin;
        meta.x_.cachefile = fnamebin;
        
    else
        % CSV read.
        if (DOPTS.cache_hapi)
            if (DOPTS.logging) fprintf('Downloading %s ... ',urlcsv);end
            % Save to file and read file
            urlwrite(urlcsv,fnamecsv);
            if (DOPTS.logging) fprintf('Done.\n');end
            if (DOPTS.logging) fprintf('Reading %s ... ',fnamecsv);end
            fid = fopen(fnamecsv,'r');
            str = fscanf(fid,'%c');
            fclose(fid);
            if (DOPTS.logging) fprintf('Done.\n');end
        else
            if (DOPTS.logging) fprintf('Reading %s ... ',urlcsv);end
            % Read into memory directly.
            str = urlread(urlcsv);
            if (DOPTS.logging) fprintf('Done.\n');end
        end

        % timelen = number of characters in time string + 1 (for null)
        timelen = meta.parameters{1}.length;
        % TODO: Handle alternative time respresentations that are allowed:
        % Truncated time and YYYY-DD.  Determine format from regex.
        % Probably want to use this
        % https://github.com/JodaOrg/joda-time/releases/download/v2.9.9/joda-time-2.9.9.jar
        % for non-standard time strings instead of writing a native
        % MATLAB parser.
        if strmatch(str(timelen-1),'Z') % Last char is Z
            % Read format string
            rformat  = '%4d-%2d-%2dT%2d:%2d:%2d.%3dZ ';
            % Time write format string
            twformat = '%4d-%02d-%02dT%02d:%02d:%02d.%03dZ';
        else
            rformat  = '%4d-%2d-%2dT%2d:%2d:%2d.%3d ';
            twformat = '%4d-%02d-%02dT%02d:%02d:%02d.%03d';
        end

        ntc     = 7; % Number of time columns
        lcol(1) = ntc; % Last time column. (TODO: Compute in general based on timeformat.)

        for i = 2:length(meta.parameters) % 1 corresponds to time.
            if isfield(meta.parameters{i},'size')
                psize(i-1)  = meta.parameters{i}.size;
            end
            pnames{i-1} = meta.parameters{i}.name;
            ptype{i-1}  = meta.parameters{i}.type;
            psize(i-1)  = 1;
            if isfield(meta.parameters{i},'size')
                psize(i-1) = meta.parameters{i}.size;
            end
            if i == 2,a = ntc;,else,a = lcol(i-2);,end
            fcol(i-1) = a + 1; % First column of parameter
            lcol(i-1) = fcol(i-1)+psize(i-1)-1; % Last column of parameter

            if strcmp(ptype{i-1},'integer')
                rformat = [rformat,repmat('%d ',1,psize(i-1))];
            end
            if strcmp(ptype{i-1},'double')
                rformat = [rformat,repmat('%f ',1,psize(i-1))];
            end
            if any(strcmp(ptype{i-1},{'isotime','string'}))
                plength{i-1}  = meta.parameters{i}.length - 1;
                rformat = [rformat,repmat(['%',num2str(plength{i-1}),'c '],1,psize(i-1))];
            end
        end
        if (DOPTS.logging) fprintf('Parsing %s ... ',fnamecsv);end
        
        fid = fopen(fnamecsv,'r');
        A = textscan(fid,rformat,'Delimiter',',');
        fclose(fid);

        % Compute time strings (using a rformat with time conversion
        % specifications is slower - see format_compare.m)
        DTVec     = transpose(cat(2,A{1:ntc})); % Yr,Mo,Dy,Hr,Mn,Sc,Ms, ... matrix.
        
        % Should we even return this?  Probably won't be used.
        % Doubles parse time.
        Time      = sprintf(twformat,DTVec(:)); % datestr is too slow
        Time      = reshape(Time,timelen-1,length(Time)/(timelen-1))';

        data      = struct();
        data      = setfield(data,'Time',Time);
        data      = setfield(data,'DateTimeVector',DTVec');

        for i = 1:length(pnames)
            if any(strcmp(ptype{i},{'isotime','string'}))
                % Array parameter of type isotime or string
                pdata = A(fcol(i):lcol(i));
            else
                pdata = cat(2,A{fcol(i):lcol(i)});
            end
            data  = setfield(data,pnames{i},pdata);
        end

        meta.x_.format    = 'csv';
        meta.x_.url       = urlcsv;
        meta.x_.cachefile = fnamecsv;

        if (DOPTS.logging) fprintf('Done.\n');end

    end

    % Save extra metadata about request in MATLAB binary file
    meta.x_ = struct();
    meta.x_.server     = SERVER;
    meta.x_.dataset    = DATASET;
    meta.x_.parameters = PARAMETERS;
    meta.x_.time_min   = START;
    meta.x_.time_max   = STOP;

    if (DOPTS.cache_mlbin)
        if (DOPTS.logging) fprintf('Saving %s ... ',fnamemat);end
        save(fnamemat,'urlcsv','data','meta');
        if (DOPTS.logging) fprintf('Done.\n');end
    end

end