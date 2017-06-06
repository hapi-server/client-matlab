function [data, meta] = hapi(SERVER, DATASET, PARAMETERS, START, STOP, OPTS)
% HAPI - Interface to Heliophysics Data Environment API
%
%   Version 2017-05-26.
%
%   Get metadata and data from a HAPI v1.1 compliant data server
%   (https://github.com/hapi-server/).  See note below for GUI options for
%   selecting data.
%
%   Servers = HAPI() or HAPI() returns or lists data server URLs from
%   https://github.com/hapi-server/data-specification/blob/master/servers.txt
%
%   Dataset = HAPI(Server) or HAPI(Server) returns or lists datasets
%   available at server URL.
%
%   Parameters = HAPI(Server, Dataset) or HAPI(...) returns or
%   lists parameters in dataset.
%
%   Metadata = HAPI(Server, Dataset, Parameters) or HAPI(...) returns or
%   list metadata associated each parameter. The Parameters input 
%   can be a string, array, or cell array.
%
%   Data = HAPI(Server, Dataset, Parameters, Start, Stop) or HAPI(...)
%   returns a matrix of data.  Start and Stop are ISO8601 time stamps.
%   First column of Data is time converted to MATLAB datenum.
%
%   Options are set by passing a structure as the last argument with fields
%
%       update_script (default true) - Use newer hapi.m if found.
%       logging (default false) - Log to console.
%       cache_hapi (default true) - Save files in hapi-data.
%       use_cache (default true) - Use cache file if found.
%       serverlist (default https://raw.githubusercontent.com/hapi-server/data-specification/master/servers.txt)
%   
%   e.g., to reverse default options, use
%       OPTS = struct();
%       OPTS.updatescript = 0;
%       OPTS.logging      = 1;
%       OPTS.cache_hapi   = 0;
%       OPTS.use_cache    = 0;
%       HAPI(...,OPTS)
%
%   This is a command-line only interface.  For a GUI for browsing catalogs
%   and datasets and selecting a dataset and parameters, see
%   http://tsds.org/get/.  Select a catalog, dataset, parameter, and
%   time range and then request a MATLAB script as an output.  A script
%   will be generated that can be pasted onto the command line.
%
%   Example: Open http://tsds.org/get/ and select drop-down options
%            SSCWeb, ACE, X_TOD, Script, MATLAB
%            and the following script will be shown
%              urlwrite('https://github.com/hapi-server/matlab-client/blob/master/','hapi.m');
%              [data,meta] = hapi('http://tsds.org/get/SSCWeb/hapi/','ace','X_TOD','2017-04-23','2017-04-24');
%            copy and paste these two lines in MATLAB.
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
DOPTS.use_binary    = 0; % Will be removed.

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

% Shameless plug
if nin > 0 && DOPTS.logging
    if ~isempty(strmatch('http://tsds.org/',SERVER))
        fprintf('See <a href="http://tsds.org/get/">http://tsds.org/get/</a> to explore catalog datasets.\n');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datasets
if (nin == 1)
    url = [SERVER,'/catalog/'];
    if (DOPTS.logging),fprintf('Reading %s ... ',url);end

    opts = weboptions('ContentType', 'json');
    data = webread(url,opts);
    
    if (DOPTS.logging || nargout == 0),fprintf('Available datasets from %s:\n',SERVER);end

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
    url = [SERVER,'/info?id=',DATASET];

    if (DOPTS.logging) fprintf('Downloading %s ... ',url);end
	opts = weboptions('ContentType', 'json');
    data = webread(url,opts);
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
    meta = webread(urljson,opts);
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

        
    if (DOPTS.use_binary)
        % Determine if server supports binary
        url = [SERVER,'/capabilities'];
        if (DOPTS.logging) fprintf('Reading %s ... ',url);end
        opts = weboptions('ContentType', 'json');
        caps = webread(url,opts);
        if (DOPTS.logging) fprintf('Done.\n');end
        if isempty(strmatch('fbinary',caps.outputFormats,'exact'))
            fprintf('DOPTS.use_binary = true, but server does not support binary output.\n');
            DOPTS.use_binary = false;
        end
    end

    if (DOPTS.use_binary)
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
        if (DOPTS.cache_mlbin)
            if (DOPTS.logging) fprintf('Saving %s ... ',fnamemat);end
            save(fnamemat,'urlfbin','data','meta');
            if (DOPTS.logging) fprintf('Done.\n');end
        end
        return;
    end
    
    try
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
    catch
        error('\nError when attempting to fetch %s\n',urlcsv);
    end

    timelen = meta.parameters{1}.length;
    if (timelen == 23 || timelen == 24)
        if (DOPTS.logging) fprintf('Fast parsing %s ... ',fnamecsv);end
        % TODO: Check that no other variables are strings.  If any, drop
        % to slow mode.
        % TODO: return structure data.Time, data.Parameter1, etc.
        size = 0;
        for i = 2:length(meta.parameters)
            size = size + meta.parameters{i}.size;
        end
        nd = repmat('%f ',1,size);
        % TODO: Handle alternative time respresentations that are allowed:
        % Truncated time and YYYY-DD.
        if strmatch(str(24),'Z')
            % For now, to get things working.
            format = ['%4d-%2d-%2dT%2d:%2d:%2d.%3dZ ',nd];
        else
            format = ['%4d-%2d-%2dT%2d:%2d:%2d.%3d ',nd];
        end
        fid = fopen(fnamecsv,'r');
        A = textscan(fid,format,'Delimiter',',','CollectOutput',true);
        fclose(fid);
        A{1} = double(A{1});
        A{1}(:,6) = A{1}(:,6) + A{1}(:,7)/1000;
        data(:,1) = datenum(A{1}(:,1:6));
        data = [data,A{2}];
        datestr(data(1:10,1),'yyyy-mm-ddTHH:MM:SS.FFF');
        if (DOPTS.logging) fprintf('Done.\n');end
    else
        % Slow method.  Iterate over each line.
        % TODO: Hanlde string columns.
        if (DOPTS.logging) fprintf('Slow parsing %s ... ',fnamecsv);end
        datas = strread(str,'%s','delimiter',sprintf('\n'));
        for i = 1:length(datas)
            line = strsplit(datas{i},',');
            time = regexprep(line(1),'Z.*','');
            % TODO: Need to handle non-full versions of ISO time, e.g.,
            % YYYY-mm-ddTHH, etc.
            time = datenum(time,'yyyy-mm-ddTHH:MM:SS');
            try
                tmp = cellfun(@str2num,line(2:end),'Uniform',1);
            catch
                error('Problem with line %d:\n%s',i,datas{i});
            end
            data(i,:) = [time,tmp];
        end
        if (DOPTS.logging) fprintf('Done.\n');end
    end

    meta.x_server = SERVER;
    meta.x_dataset = DATASET;
    meta.x_requestURL = urlcsv;
    meta.x_requestFile = fnamecsv;
    meta.x_requestFormat = 'csv';
    meta.x_request_parameters = PARAMETERS;
    meta.x_request_time_min = START;
    meta.x_request_time_max = STOP;

    if (DOPTS.cache_mlbin)
        if (DOPTS.logging) fprintf('Saving %s ... ',fnamemat);end
        save(fnamemat,'urlcsv','data','meta');
        if (DOPTS.logging) fprintf('Done.\n');end
    end

    return;
end