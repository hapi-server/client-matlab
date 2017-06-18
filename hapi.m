function [data, meta] = hapi(SERVER, DATASET, PARAMETERS, START, STOP, OPTS)
% HAPI - Interface to Heliophysics Data Environment API
%
%   HAPI.m gets metadata and data from a <a href="https://github.com/hapi-server/">HAPI v1.1</a> compliant
%   data server. See <a href="./html/hapi_demo.html">hapi_demo</a> for usage examples.
%
%   This is a command-line only interface.  For a GUI for browsing
%   and searching servers, datasets, and parameters, see
%   http://tsds.org/get/.  Select a catalog, dataset, parameter, and
%   time range and then request a MATLAB script as an output.  A script
%   will be generated that can be pasted onto the command line.
%
%   <a href="http://tsds.org/get/#catalog=SSCWeb&dataset=ace&parameters=X_TOD&start=-P2D&stop=2017-08-27&return=script&format=matlab">Example of search result</a>.
%
%   Servers = HAPI() or HAPI() returns a cell array of URL strings
%   or lists data server URLs from <a href="https://github.com/hapi-server/servers/servers.json">known HAPI servers</a>.
%
%   Dataset = HAPI(Server) or HAPI(Server) returns or lists datasets
%   available at server URL Server.
%
%   Meta = HAPI(Server, Dataset) returns metadata for all parameters
%   in dataset Dataset from server Server.
%
%   Meta = HAPI(Server, Dataset, Parameters) returns metadata
%   associated with one or more parameter strings in Parameters.
%   Parameters can be a comma-separated string or cell array.
%
%   [Data,Meta] = HAPI(Server, Dataset, Parameters, Start, Stop) returns
%   the data and metadata for for the requested parameters. Start and
%   Stop are <a href="https://en.wikipedia.org/wiki/ISO_8601">ISO 8601</a> time stamps (YYYY-mm-DDTHH:MM:SS.FFF). If
%   Parameters = '', all parameters are returned.  An extra field is
%   added to the returned Data structure named DateTimeVector, which is
%   a matrix with columns of Year, Month, Day, Hour, Minute, Second,
%   that can be passed to DATENUM.
%
%   Options are set by passing a structure as the last argument
%   with fields
%
%     logging (default false)   - Log to console
%     cache_hapi (default true) - Cache data in ./hapi-data
%     use_cache (default true)  - Use files in ./hapi-data if found
%   
%   To reverse default options, use
%     OPTS = struct();
%     OPTS.logging      = 1;
%     OPTS.cache_hapi   = 0;
%     OPTS.use_cache    = 0;
%     HAPI(...,OPTS)
%
%   Version 2017-05-26.
%
%   For bug reports and feature requests, see
%   https://github.com/hapi-server/matlab-client/issues
%
%   See also HAPI_DEMO, DATENUM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: R.S Weigel <rweigel@gmu.edu>
% License: This is free and unencumbered software released into the public domain.
% Repository: https://github.com/hapi-server/matlab-client.git
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For bug reports and feature requests, see
% https://github.com/hapi-server/matlab-client/issues
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
            urlcsv  = [SERVER,'/data?id=',DATASET,'&time.min=',START,'&time.max=',STOP];
            if (length(PARAMETERS) > 0) % Not all parameters wanted
                urlcsv = [urlcsv,'&parameters=',PARAMETERS];
            end
            urlfbin = [urlcsv,'&format=fbinary'];
            urlbin  = [urlcsv,'&format=binary'];
        end
        urljson = [SERVER,'/info?id=',DATASET];
        if (length(PARAMETERS) > 0) % Not all parameters wanted
            urljson = [urljson,'&parameters=',PARAMETERS];
        end
        fnamejson = sprintf('%s_%s',DATASET,regexprep(PARAMETERS,',','-'));
        fnamejson = [urld,filesep(),fnamejson,'.json'];
    end

    if DOPTS.use_cache && nin == 5
        if exist(fnamemat,'file')
            if (DOPTS.logging) fprintf('Reading %s ... ',fnamemat);end
                load(fnamemat);
            if (DOPTS.logging) fprintf('Done.\n');end
            return;
        end
    end

    if DOPTS.cache_mlbin || DOPTS.cache_hapi
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
        % Fastest method based on tests in format_compare.m
        urlwrite(urlfbin,fnamefbin);
        if (DOPTS.logging) fprintf('Done.\n');end
        if (DOPTS.logging) fprintf('Reading %s ... ',fnamefbin);end
        fid = fopen(fnamefbin);
        p = char(fread(fid,21,'uint8=>char'));
        n = str2num(p(1));
        data = fread(fid,'double'); 
        fclose(fid);
        if (DOPTS.logging) fprintf('Done.\n');end
        psize = 1 + meta.parameters{2}.size;
        data = reshape(data,psize,length(data)/psize)';
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
        Ifc = findstr(str(1:40),','); % First comma
        t1 = deblank(str(1:Ifc-1));
        timelen = length(t1);
        % TODO: Handle alternative date/time respresentations that are allowed:
        % YYYY-DDD, YYYYmmDD, THHMMSS, etc.
        % Probably want to use this
        % https://github.com/JodaOrg/joda-time/releases/download/v2.9.9/joda-time-2.9.9.jar
        twformat = t1;
        if ~isempty(regexp(twformat,'^[0-9]{4}-[0-9]{2}-'))
            twformat = regexprep(twformat,'^[0-9]{4}-','%4d-');
            twformat = regexprep(twformat,'%4d-[0-9][0-9]-','%4d-%02d-');
            twformat = regexprep(twformat,'%4d-%02d-[0-9][0-9]','%4d-%02d-%02d');
            twformat = regexprep(twformat,'%4d-%02d-%02dT[0-9][0-9]','%4d-%02d-%02dT%02d');
            twformat = regexprep(twformat,'%4d-%02d-%02dT%02d:[0-9][0-9]','%4d-%02d-%02dT%02d:%02d');
            twformat = regexprep(twformat,'%4d-%02d-%02dT%02d:%02d:[0-9][0-9]','%4d-%02d-%02dT%02d:%02d:%02d');
            twformat = regexprep(twformat,'\.[0-9]','.%01d');
            for i = 1:8 % Assumes no more than ns precision.
                reg = sprintf('\\.%%0%dd[0-9]',i);
                rep = sprintf('.%%0%dd',i+1);
                twformat = regexprep(twformat,reg,rep);
            end
        else
            error('Format of time string not recognized');
        end        
        rformat = regexprep(twformat,'%0','%');

        if (0)
        if strmatch(t1(end),'Z') % Last char is Z
            % Read format string
            rformat  = '%4d-%2d-%2dT%2d:%2d:%2d.%3dZ ';
            % Time write format string
            twformat = '%4d-%02d-%02dT%02d:%02d:%02d.%03dZ';
        else
            rformat  = '%4d-%2d-%2dT%2d:%2d:%2d.%3d ';
            twformat = '%4d-%02d-%02dT%02d:%02d:%02d.%03d';
        end
        end

        % Number of time columns
        ntc     = length(findstr('d',twformat));
        lcol(1) = ntc; % Last time column.

        for i = 2:length(meta.parameters) % parameters{1} is always Time
            pnames{i-1} = meta.parameters{i}.name;
            ptypes{i-1} = meta.parameters{i}.type;
            psizes{i-1} = [1];
            if isfield(meta.parameters{i},'size')
                psizes{i-1} = meta.parameters{i}.size;
            end
            if i == 2,a = ntc;,else,a = lcol(i-2);,end
            fcol(i-1) = a + 1; % First column of parameter
            lcol(i-1) = fcol(i-1)+prod(psizes{i-1})-1; % Last column of parameter

            if strcmp(ptypes{i-1},'integer')
                rformat = [rformat,repmat('%d ',1,prod(psizes{i-1}))];
            end
            % float should not be needed, but common error
            if strcmp(ptypes{i-1},'double') || strcmp(ptypes{i-1},'float')
                rformat = [rformat,repmat('%f ',1,prod(psizes{i-1}))];
            end
            if any(strcmp(ptypes{i-1},{'isotime','string'}))
                plengths{i-1}  = meta.parameters{i}.length - 1;
                rformat = [rformat,repmat(['%',num2str(plengths{i-1}),'c '],1,prod(psizes{i-1}))];
            end
        end
        if (DOPTS.logging) fprintf('Parsing %s ... ',fnamecsv);end
        
        fid = fopen(fnamecsv,'r');
        A = textscan(fid,rformat,'Delimiter',',');
        fclose(fid);

        [s,r] = system(sprintf('wc %s | tr -s [:blank:] | cut -d" " -f2',fnamecsv));
        if (s == 0) % TODO: Only works on OS-X and Linux
            % Check A to make sure it has same number of rows
            % as number of rows in file. See hapi_test for example
            % when this error is caught.  Much faster than using
            % native MATLAB function.
            nrows = str2num(r);
            for i = 1:length(A)
                nread = size(A{i},1);
                if nread ~= nrows
                    error(sprintf('\nNumber of rows read (%d) does not match number of rows in\n%s (%d).\nPlease report this issue at https://github.com/hapi-server/matlab-client/issues',fnamecsv,nread,nrows));
                end
            end
        end
        
        % Compute time strings (using a rformat with time conversion
        % specifications is much slower - see format_compare.m)
        DTVec = transpose(cat(2,A{1:ntc})); % Yr,Mo,Dy,Hr,Mn,Sc,Ms, ... matrix.
        
        % Should we even return this?  Probably won't be used.
        % Doubles the parsing time.
        Time = sprintf(twformat,DTVec(:)); % datestr is too slow
        Time = reshape(Time,timelen,length(Time)/timelen)';
        
        data      = struct();
        data      = setfield(data,'Time',Time);
        data      = setfield(data,'DateTimeVector',DTVec');

        for i = 1:length(pnames)
            if any(strcmp(ptypes{i},{'isotime','string'}))%% && isfield(meta.parameters{i+1},'size')
                % Array parameter of type isotime or string
                pdata = A(fcol(i):lcol(i));
            else
                pdata = cat(2,A{fcol(i):lcol(i)});
            end
            pdata = reshape(pdata,[size(pdata,1),psizes{i}(:)']);
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