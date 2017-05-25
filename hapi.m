function [data, meta] = hapi(SERVER, DATASET, PARAMETERS, START, STOP, OPTS)
% HAPI - Interface to Heliophysics Data Environment API
%
%   Version 2017-05-24.
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
%       logging (default true) - Log to console.
%       cache_files (default true) - Save files in hapi-data.
%       use_cache (default true) - Use cache file if found.
%       serverlist (default https://raw.githubusercontent.com/hapi-server/data-specification/master/servers.txt)
%   
%   e.g., 
%       OPTS = struct(); 
%       OPTS.logging = 0;
%       HAPI(...,OPTS)
%
%   This is a command-line only interface.  For a GUI for browsing catalogs
%   and datasets and selecting a dataset and parameters, see
%   http://tsds.org/get/.  Select a catalog, dataset, parameter, and
%   time range and then request a MATLAB script as an output.  A script
%   will be generated that can be pasted onto the command line.
%
%   Example: 
%
%
%   See also HAPI_DEMO, DATENUM.

% This is free and unencumbered software released into the public domain.
% R.S Weigel <rweigel@gmu.edu>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default Options
%
% Implemented
DOPTS = struct();
DOPTS.update_script = 1;
DOPTS.logging       = 1;
DOPTS.cache_files   = 1; % Save data requested in file for off-line use.
DOPTS.use_cache     = 1; % Use cached file associated with request if its exists.
DOPTS.serverlist    = 'https://raw.githubusercontent.com/hapi-server/data-specification/master/servers.txt';
DOPTS.jsonlib       = 'https://github.com/hapi-server/matlab-client/blob/master/json-20140107.jar';
DOPTS.scripturl     = 'https://raw.githubusercontent.com/hapi-server/matlab-client/master/hapi.m';

% TODO: These are not implemented.
%DOPTS.use_binary    = 0; % Use binary transport.
%DOPTS.split_long    = 0; % Split long requests into chunks and fetch chunks.
%DOPTS.parallel_req  = 0; % Use parallel requests for chunks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract options (better way to do this?)
nin = nargin;
if exist('SERVER','var') && isstruct(SERVER),OPTS = SERVER;clear SERVER;nin = nin-1;end
if exist('DATASET','var') && isstruct(DATASET),OPTS = DATASET;clear DATASET;nin = nin-1;end
if exist('PARAMETERS','var') && isstruct(PARAMETERS),OPTS = PARAMETERS;clear SERVER;nin = nin-1;end
if exist('START','var') && isstruct(START),OPTS = START;clear SERVER;;end
if exist('STOP','var') && isstruct(STOP),OPTS = STOP;clear SERVER;end

if exist('OPTS')
    keys = fieldnames(OPTS);
    if length(keys)
        for i = 1:length(keys)
            setfield(DOPTS,keys{i},getfield(OPTS,keys{i}));
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get latest version of script
if (DOPTS.update_script)
    % Not tested.
    % http://www.mathworks.com/matlabcentral/fileexchange/55746-javamd5
    md = java.security.MessageDigest.getInstance('MD5');
    fid = fopen('hapi.m','r');
    digest = dec2hex(typecast(md.digest(fread(fid, inf, '*uint8')),'uint8'));
    fclose(fid);
    md5a = lower(reshape(digest',1,[]));
    str = urlread(DOPTS.scripturl);
    digest = dec2hex(typecast(md.digest(str),'uint8'));
    md5b = lower(reshape(digest',1,[]));
    if (~strmatch(md5a,md5b))
        % Will this work?
        fid = fopen('hapi.m','w');
        fprintf(fid,'%s',str);
        fclose(fid);
    end
end

if (exist('hapi_','file'))
    % Use newer version of this script.
    [data,meta] = hapi(varsrgin{:});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get java JSON library
if ~exist('org.json.JSONArray')
    % Fetch library if not already there (will do once per MATLAB session).
    % Uses json.org Java library.  See also https://gist.github.com/mikofski/2492355
    if (DOPTS.logging) fprintf('Adding to Java class path: %s\n',DOPTS.jsonlib);end
    javaaddpath(DOPTS.jsonlib);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datasets
if (nin == 1)

    url = [SERVER,'/catalog/'];
    if (DOPTS.logging) fprintf('Reading %s ... ',url);end

    try
        str = urlread(url);
        if (DOPTS.logging) fprintf('Done.\n');end
    catch
        error('Error when attempting to fetch %s\n',url);
    end

    try
        j1 = org.json.JSONObject(str);
    catch err
        error('Problem parsing JSON response from %s:\n\n%s',url,str);
    end

    if (DOPTS.logging)
        %fprintf('Response:\n\n%s\n',char(j1.get('catalog').toString(2)));
    end

    % Convert Java JSON object to MATLAB structure
    if (DOPTS.logging || nargout == 0) fprintf('Available datasets from %s:\n',SERVER);end
    for i = 1:j1.get('catalog').length
        Datasets{i} = char(j1.get('catalog').get(i-1).get('id'));
        if (DOPTS.logging || nargout == 0) fprintf('  %s\n',Datasets{i});end
    end
    if (DOPTS.logging || nargout == 0) fprintf('\n');end
    data = Datasets;
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
if (nin == 2)
    url = [SERVER,'/info?id=',DATASET];

    if (DOPTS.logging) fprintf('Reading %s ... ',url);end

    try
        str = urlread(url);
        if (DOPTS.logging) fprintf('Done.\n');end
    catch
        error('Error when attempting to fetch %s\n',url);
    end

    try
        j1 = org.json.JSONObject(str);
    catch err
        error('Problem parsing JSON response from %s:\n\n%s',url,str);
    end


    if (j1.has('firstDate'))
        % HAPI 1.0
        start = char(j1.get('firstDate'));
        stop  = char(j1.get('lastDate'));
    else
        % HAPI 1.1
        start = char(j1.get('startDate'));
        stop  = char(j1.get('stopDate'));
    end

    for i = 1:j1.get('parameters').length
        json = j1.get('parameters').get(i-1);
        ParametersStruct = struct([]);
        Parameters{i} = char(json.get('name'));
        if (json.has('description'))
            Description{i} = char(j1.get('parameters').get(i-1).get('description'));
        else
            Description{i} = '';
        end
    end

    if (DOPTS.logging || nargout == 0)
        fprintf('Available parameters in %s from %s:\n',DATASET,SERVER);
        fprintf('Time range of availability: %s-%s\n',start,stop)
        for i=1:length(Parameters)
            fprintf('  %s - %s\n',Parameters{i}, Description{i});
        end
    end
    data = Parameters;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data

if (nin == 3 || nin == 5)

    url = [SERVER,'/info?id=',DATASET,'&parameters=',PARAMETERS];

    if (DOPTS.logging) fprintf('Reading %s ... ',url);end
    str = urlread(url);
    if (DOPTS.logging) fprintf('Done.\n');end

    try
        j1 = org.json.JSONObject(str);
    catch err
        err
        error('Problem parsing JSON response from %s:\n\n%s',url,str);
    end

    json = j1.get('parameters');
    for i = 1:json.length
        names = json.get(i-1).names;
        meta{i} = struct();
        for j = 1:names.length
            key = names.get(j-1);
            val = json.get(i-1).get(key);
            if (strmatch(key,'fill'))
                val = str2num(val);
            end
            if (strmatch(key,'size'))
                val = str2num(val);
            end
            if (strmatch(key,'bins'))
                bins = struct();
                bins.name = val.get(0).get('name');
                bins.centers = str2num(char(val.get(0).get('centers')));
                bins.ranges = str2num(char(val.get(0).get('ranges')));
                if (val.get(0).isNull('units'))
                    bins.description = val.get(0).get('description');
                end
                if (val.get(0).isNull('units'))
                    bins.units = val.get(0).get('units');
                end
                val = bins;
            end

            meta{i} = setfield(meta{i},key,val);
        end
    end
    if nin == 3
        data = meta;
        return
    end

    url = [SERVER,'/data?id=',DATASET,'&parameters=',PARAMETERS,'&time.min=',START,'&time.max=',STOP];

    if (DOPTS.cache_files || DOPTS.use_cache)
        urld = regexprep(SERVER,'http://(.*)','$1');
        urld = ['hapi-data',filesep(),regexprep(urld,'/','_')];
        fname = sprintf('%s_%s_%s_%s',...
                        DATASET,...
                        regexprep(PARAMETERS,',','-'),...
                        regexprep(START,'-|:\.|Z',''),...
                        regexprep(STOP,'-|:|\.|Z',''));

        fname = [urld,filesep(),fname,'.csv'];
    end

    if (DOPTS.use_cache)
        fnamem = regexprep(fname,'\.csv','.mat');
        if exist(fnamem,'file');
            load(fnamem);
            return
        end
    end

    if (DOPTS.cache_files)
        if ~exist('hapi-data','dir')
            mkdir('hapi-data');
        end
        if ~exist(urld,'dir')
            mkdir(urld);
        end    
    end

    if (DOPTS.use_cache && exist(fname,'file'))
            if (DOPTS.logging) fprintf('Reading %s ... ',fname);end
            fid = fopen(fname,'r');
            str = fscanf(fid,'%c');
            fclose(fid);
            if (DOPTS.logging) fprintf('Done.\n');end
    else
        try
            if (DOPTS.cache_files)
                if (DOPTS.logging) fprintf('Downloading %s ... ',url);end
                urlwrite(url,fname);
                if (DOPTS.logging) fprintf('Done.\n');end
                if (DOPTS.logging) fprintf('Reading %s ... ',fname);end
                fid = fopen(fname,'r');
                str = fscanf(fid,'%c');
                fclose(fid);
                if (DOPTS.logging) fprintf('Done.\n');end
            else
                if (DOPTS.logging) fprintf('Reading %s ... ',url);end
                str = urlread(url);
                if (DOPTS.logging) fprintf('Done.\n');end
            end
        catch
            error('Error when attempting to fetch %s\n',url);
        end
    end

    try
        % TODO: Save data to a file with name based on inputs
        % if update = false and file exists, read data from local file.
        if (DOPTS.logging) fprintf('Reading %s ... ',url);end
        str = urlread(url);
        if (DOPTS.logging) fprintf('Done.\n');end
    catch
        error('Error when attempting to fetch %s\n',url);
    end

    datas = strread(str,'%s','delimiter',sprintf('\n'));
    if (DOPTS.logging) fprintf('Parsing %s ... ',fname);end

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

    if (DOPTS.cache_files)
        save(regexprep(fname,'\.csv',''),'url','data','meta');
    end

    return
end