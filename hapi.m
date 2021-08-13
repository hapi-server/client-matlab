function [data, meta] = hapi(SERVER, DATASET, PARAMETERS, START, STOP, OPTS)
% HAPI - Interface to Heliophysics Data Environment API
%
%   HAPI.m gets metadata and data from a <a href="https://github.com/hapi-server/">HAPI v1.1</a> compliant
%   data server. See <a href="./html/hapi_demo.html">hapi_demo</a> for usage examples.
%
%   This is a command-line only interface.  For a GUI for browsing and
%   searching servers, datasets, and parameters, see http://hapi-server.org/servers/.
%   Select a catalog, dataset, parameter, and time range and then request a
%   MATLAB script as an output.  A script including a call to this script
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
%   the data and metadata for for the requested parameters. If Parameters =
%   '', all parameters are returned.
%
%   Start and Stop must be time stamps of the form YYYY-mm-DDTHH:MM:SS.SSS
%   or YYYY-DDDTHH:MM:SS.SSS and truncated timestamps are allowed (e.g., 
%   YYYY-mm-DD, YYYY-DDD, YYYY-mm-DDTHH, etc.
%
%   An extra field is added to the returned Data structure named
%   DateTimeVector, which is a matrix with columns of at least Year, Month,
%   Day, and then Hour, Minute, Second, Millisecond, Microsecond, depending
%   on the precision of the time stamps in the data returned from the
%   server, e.g., if the timestamps are of the form 2000-01, then
%   DateTimeVector will have only three columns (the day is assumed to be
%   zero). Data.DateTimeVec can be used to directly compute a MATLAB
%   DATENUM using, e.g.,
%
%      datenum(Data.DateTimeVec(:,1:3)) or
%      datenum(Data.DateTimeVec(:,1:6)) or 
%      datenum(Data.DateTimeVec(:,1:6)) + Data.DateTimeVec(:,7)/86400
%
%   Data.DateTimeVec will always have either 3 columns or 6+ columns
%   depending on the precision of the returned data.  Note that MATLAB's
%   DATENUM is only accurate to 1 ms resolution, so that
%
%    datenum(Data.DateTimeVec(:,1:6)) ...
%      + Data.DateTimeVec(:,7)/86400 ..
%      + Data.DateTimeVec(:,8)/86400000
%
%   is not meaningful.
%
%   Options are set by passing a structure as the last argument with fields
%
%     logging (default false)   - Log to console
%     cache_hapi (default true) - Cache data in ./hapi-data
%     use_cache (default true)  - Use files in ./hapi-data if found
%
%   Note that file locking is not implemented for ./hapi-data.
%   
%   To reverse default options, use
%     OPTS = struct();
%     OPTS.logging      = 1;
%     OPTS.cache_hapi   = 0;
%     OPTS.use_cache    = 0;
%     HAPI(...,OPTS)
%
%   Version 2017-06-18.
%
%   For bug reports and feature requests, see
%   <a href="https://github.com/hapi-server/client-matlab/issues">https://github.com/hapi-server/client-matlab/issues</a>
%
%   See also HAPI_DEMO, DATENUM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: R.S Weigel <rweigel@gmu.edu>
% License: This is free and unencumbered software released into the public domain.
% Repository: https://github.com/hapi-server/client-matlab.git
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default Options
%
% Implemented options:
DOPTS = struct();
DOPTS.logging       = 0;
DOPTS.cache_mlbin   = 1; % Save data requested in MATLAB binary for off-line use.
DOPTS.cache_hapi    = 1; % Save responses in files (HAPI CSV, JSON, and Binary) for debugging.
DOPTS.use_cache     = 0; % Use cached MATLAB binary file associated with request if found.
DOPTS.format        = 'csv'; % If 'csv', request for HAPI CSV will be made even if server supports HAPI Binary. (For debugging.) 
%DOPTS.format        = 'binary';

DOPTS.serverlist    = 'https://raw.githubusercontent.com/hapi-server/servers/master/all.txt';
DOPTS.scripturl     = 'https://raw.githubusercontent.com/hapi-server/client-matlab/master/hapi.m';

% Not implemented:
%DOPTS.hapi_data     = './hapi-data'; % Where to store cached data.
%DOPTS.split_long    = 0; % Split long requests into chunks and fetch chunks.
%DOPTS.parallel_req  = 0; % Use parallel requests for chunks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract options (TODO: Find better way to do this.)
nin = nargin;
if exist('SERVER','var') && isstruct(SERVER),OPTS = SERVER;clear SERVER;end
if exist('DATASET','var') && isstruct(DATASET),OPTS = DATASET;clear DATASET;end
if exist('PARAMETERS','var') && isstruct(PARAMETERS),OPTS = PARAMETERS;end
if exist('START','var') && isstruct(START),OPTS = START;clear START;end
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
% Get list of servers
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

    url = [SERVER,'/catalog'];
    if (DOPTS.logging),fprintf('Reading %s ... ',url);end

    opts = weboptions('ContentType', 'json');
    try
        data = webread(url,opts);
    catch err
        error(err.message);
        return
    end
    
    if (DOPTS.logging || nargout == 0)
        fprintf('\nAvailable datasets from %s:\n',SERVER);
    end

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
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
if (nin == 2)

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
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data
if (nin == 3 || nin == 5)

    if iscell(PARAMETERS)
        PARAMETERS = sprintf('%s,',PARAMETERS{:});
        PARAMETERS = PARAMETERS(1:end-1); % Remove trailing comma
    end
    
    if (DOPTS.cache_mlbin || DOPTS.cache_hapi || DOPTS.use_cache)
        % Create directory name from server URL
        urld = regexprep(SERVER,'https*://(.*)','$1');
        urld = ['hapi-data',filesep(),regexprep(urld,'/|:','_')];
        if (nin == 5) % Data requested
            fname = sprintf('%s_%s_%s_%s',...
                            regexprep(DATASET,'/|:','_'),...
                            regexprep(PARAMETERS,',','-'),...
                            regexprep(START,'-|:\.|Z',''),...
                            regexprep(STOP,'-|:|\.|Z',''));
            fnamecsv  = [urld,filesep(),fname,'.csv'];
            fnamebin  = [urld,filesep(),fname,'.bin'];
            fnamemat  = [urld,filesep(),fname,'.mat'];
            urlcsv  = [SERVER,'/data?id=',DATASET,'&time.min=',START,'&time.max=',STOP];
            if (length(PARAMETERS) > 0) % Not all parameters wanted
                urlcsv = [urlcsv,'&parameters=',PARAMETERS];
            end
            urlbin  = [urlcsv,'&format=binary'];
        end
        urljson = [SERVER,'/info?id=',DATASET];
        if (length(PARAMETERS) > 0) % Not all parameters wanted
            urljson = [urljson,'&parameters=',PARAMETERS];
        end
        fnamejson = sprintf('%s_%s',regexprep(DATASET,'/|:','_'),regexprep(PARAMETERS,',','-'));
        fnamejson = [urld,filesep(),fnamejson,'.json'];
    end

    if (DOPTS.use_cache && nin == 5)
        % Read cached .mat file and return
        if exist(fnamemat,'file')
            if (DOPTS.logging) fprintf('Reading %s ... ',fnamemat);end
            load(fnamemat);
            if (DOPTS.logging) fprintf('Done.\n');end
            return
        end
    end

    if (DOPTS.cache_mlbin || DOPTS.cache_hapi)
        % Create directory
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
    if (nin == 3) % Only metadata wanted.  Return it.
        data = meta;
        return
    end

    if (DOPTS.cache_hapi)
        % Ideally the meta variable read above could be serialized to JSON,
        % so second request is not needed to write the JSON file, but
        % serialization is not simple to do and webread can't read from a
        % file. TODO: Look at code for webread() to find out what
        % undocumented function is used to convert JSON to MATLAB
        % structure and use it here instead of websave().
        websave(fnamejson,urljson);
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
        error('Binary read not implemented');
        % Binary read.
        if (DOPTS.logging) fprintf('Downloading %s ... ',urlbin);end
        % Fastest method based on tests in format_compare.m
        urlwrite(urlbin,fnamebin);
        if (DOPTS.logging) fprintf('Done.\n');end
        if (DOPTS.logging) fprintf('Reading %s ... ',fnamebin);end

        % See misc/binary.m for start of code to do binary read.
        
        if ~DOPTS.cache_hapi
            rmfile(fnamebin);
        end
        
        % Should use _x instead of x_, but _x is not an allowed field name.
        % Extra info needed later.
        meta.x_.format    = 'binary';
        meta.x_.url       = urlbin;
        meta.x_.cachefile = fnamebin;
    else
        % CSV read.
        if (DOPTS.cache_hapi)
            % Save to file and read file
            if (DOPTS.logging) fprintf('Downloading %s ... ',urlcsv);end
            %urlwrite(urlcsv,fnamecsv);
            websave(fnamecsv,urlcsv);
            if (DOPTS.logging) fprintf('Done.\n');end
            if (DOPTS.logging) fprintf('Reading %s ... ',fnamecsv);end
            fid = fopen(fnamecsv,'r');
            str = fscanf(fid,'%c');
            fclose(fid);
            if (DOPTS.logging) fprintf('Done.\n');end
        else
            % Read into memory directly.
            if (DOPTS.logging) fprintf('Reading %s ... ',urlcsv);end
            str = urlread(urlcsv);
            if (DOPTS.logging) fprintf('Done.\n');end
        end

        % Ifc = index of first comma.
        % Assumes time stamps + whitespace <= 40 characters.
        Ifc = findstr(str(1:min(40,length(str))),',');
        t1 = deblank(str(1:Ifc-1));

        [rformat,twformat,na] = timeformat(t1);

        % Number of time columns that will bre created using twformat read.
        ntc     = length(findstr('d',twformat));
        lcol(1) = ntc; % Last time column.

        for i = 2:length(meta.parameters) % parameters{1} is always Time
            pnames{i-1} = meta.parameters{i}.name;
            ptypes{i-1} = meta.parameters{i}.type;
            psizes{i-1} = [1];
            if isfield(meta.parameters{i},'size')
                psizes{i-1} = meta.parameters{i}.size;
            end
            if i == 2,a = ntc;else,a = lcol(i-2);end
            fcol(i-1) = a + 1; % First column of parameter
            lcol(i-1) = fcol(i-1)+prod(psizes{i-1})-1; % Last column of parameter

            if strcmp(ptypes{i-1},'integer')
                rformat = [rformat,repmat('%d ',1,prod(psizes{i-1}))];
            end
            % float should not be needed, but common error
            if strcmp(ptypes{i-1},'double') || strcmp(ptypes{i-1},'float')
                rformat = [rformat,repmat('%f ',1,prod(psizes{i-1}))];
            end
            if any(strcmp(ptypes{i-1},'isotime'))
                plengths{i-1}  = meta.parameters{i}.length;
                rformat = [rformat,repmat(['%',num2str(plengths{i-1}),'c '],1,prod(psizes{i-1}))];
            end
            if any(strcmp(ptypes{i-1},'string'))
                plengths{i-1}  = meta.parameters{i}.length;
                %rformat = [rformat,repmat(['%',num2str(plengths{i-1}),'c '],1,prod(psizes{i-1}))];
                % Use this for Unicode.
                rformat = [rformat,repmat(['%q'],1,prod(psizes{i-1}))];
            end
        end
        
        if (DOPTS.logging)
            fprintf('Parsing %s',fnamecsv);
            fprintf(' using textscan() with format string "%s" ... ',rformat);
        end
        fid = fopen(fnamecsv,'r','n','UTF-8');
        A = textscan(fid,rformat,'Delimiter',',');
        fclose(fid);
        if isempty(A{end}) % Catches case when rformat is wrong.
            error(sprintf('\nError in CSV read of %f\n',fnamecsv));
        end

        DTVec = transpose(cat(2,A{1:ntc})); 
        % DTVec is matrix with columns of Yr,Mo,Dy,Hr,Mn,Sc,Ms,...
        % or Yr,Doy,Hr,Mn,Sc,Ms,....
        
        % Return exact time strings as found in CSV. Should this even be
        % returned?  Probably won't be used. Doubles the parsing time.
        timelen = length(t1);
        Time = sprintf(twformat,DTVec(:)); % datestr() is more straightforward, but is very slow.
        if mod(length(Time),timelen) ~= 0
            error(sprintf('\nError in CSV read of %f\n',fnamecsv));
        end
        Time = reshape(Time,timelen,length(Time)/timelen)';

        % Convert DOY to Month Day in DTVec and make last column the number
        % of milliseconds (if 1-2 decimal places in t1), microseconds (if
        % 4-5 decimal places in t1), etc.
        DTVec = normalizeDTVec(DTVec,t1,na);

        data = struct('Time',Time,'DateTimeVector',DTVec');
        for i = 1:length(pnames)
            if any(strcmp(ptypes{i},{'isotime','string'}))
                % Array parameter of type isotime or string
                pdata = A(fcol(i):lcol(i));
            else
                pdata = cat(2,A{fcol(i):lcol(i)});
            end
            pdata = reshape(pdata,[size(pdata,1),psizes{i}(:)']);
            if ~isvarname(pnames{i})
                newname = sprintf('x_parameter%d',i);
                fprintf('\n');
                warning(sprintf('Parameter name ''%s'' is not a valid field name. Using ''%s'' and setting meta.parameters{%d}.name_matlab = %s',pnames{i},newname,i,pnames{i}));
                data  = setfield(data,newname,pdata);
                meta.parameters{i+1}.name_matlab = newname;
            else
                data  = setfield(data,pnames{i},pdata);
            end
        end
        
        meta.x_.format    = 'csv';
        meta.x_.url       = urlcsv;
        meta.x_.cachefile = fnamecsv;

        if (DOPTS.logging) fprintf('Done.\n');end

    end

    % Save extra metadata about request in MATLAB binary file
    % (_x is more consistent with HAPI spec, but not allowed as field
    % name.)
    %meta.x_ = struct();
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

function DTVec = normalizeDTVec(DTVec,t1,na)

    DTVec(end,:) = DTVec(end,:)*10^na;
    DTVec = DTVec';

    if size(DTVec,2) > 1
        if length(t1) > 4 && ~isempty(regexp(t1,'[0-9]{4}-[0-9]{3}'))
            % Second column of DTVec is day-of-year
            % Make second and third column month and day.
            if size(DTVec,2) > 2
                DTVec = [DTVec(:,1),doy2md(DTVec(:,1:2)),DTVec(:,3:end)];
            else
                DTVec = [DTVec(:,1),doy2md(DTVec(:,1:2))];
            end
        end
    end

    if size(DTVec,2) < 3
        DTVec = [DTVec,ones(size(DTVec,1),3-size(DTVec,2))];
    end
    if size(DTVec,2) > 3 && size(DTVec,2) < 6
        DTVec = [DTVec,ones(size(DTVec,1),3-size(DTVec,2))];
    end
    DTVec = DTVec';
    
function md = doy2md(ydoy)
% DOY2MD - Convert year/day-of-year to month/day-of-month
%
%   md = DOY2MD(ydoy) where ydoy is a two-column matrix with columns
%   of year and doy and md is a two-column int32 matrix with columns of
%   month and day.

    ydoy = double(ydoy);
    I                 = (rem(ydoy(:,1),4) == 0 & rem(ydoy(:,1),100) ~= 0) | rem(ydoy(:,1),400) == 0;
    II                = [zeros(size(ydoy,1),2) , repmat(I,1,10)]; 
    day_sum           = [0 31 59 90 120 151 181 212 243 273 304 334];
    delta             = repmat(ydoy(:,2),1,12)-(repmat(day_sum,size(ydoy,1),1) + II);
    delta(delta <= 0) = 32; 
    [D,M]             = min(delta');
    md                = int32([M',floor(D')]);

function [trformat,twformat,na] = timeformat(t1)
% TIMEFORMAT - Compute a read and write format string
%
%   [trf,twf,tlen,na] = TIMEFORMAT(t), where the sample time string t is a restricted
%   set of ISO 8601 date/time strings. See
%   https://github.com/hapi-server/data-specification/blob/master/HAPI-data-access-spec.md#representation-of-time
%   for a definition of the allowed date/time strings.
%
%   If t = '1999-11-12T00', then
%   tr = '%4d-%2d-%2dT%2d'
%   tw = '%4d-%02d-%02dT%02d'
%   tw is always the read format with %Nd replaced with %0Nd if N > 1.
%
%   When the sample time string has values after the decimal, na is
%   the number of zeros that must be appended to the last number read
%   such that it represents a millisecond, microsecond, nanosecond, etc.
%   For example, if 
%   t = '1999-11-12T23:59:59.12', then 
%   tr = '%4d-%2d-%2dT%2d:%2d:%2d.%2d'
%   and na = 1 and the last read number should be multiplied by 10^na to
%   make it a millisecond.
%
%   See also TIMEFORMAT_TEST.

    Z = '';
    if (strcmp(t1(end),'Z')) % Remove trailing Z.
        Z = t1(end);
        t1 = t1(1:end-1);
    end

    % TODO: Test all possible valid time representation lengths.
    if length(t1) == 7 || length(t1) == 8
        if isempty(regexp(t1,'[0-9]{4}-[0-9]{2}')) && isempty(regexp(t1,'[0-9]{4}-[0-9]{3}'))
            error('Unrecognized time format of first string %s',t1);
        end
    end

    timelen  = length(t1) + length(Z); % Length of time string.
    trformat = t1; % Time read format.

    trformat = regexprep(trformat,'^[0-9]{4}','%4d');
    trformat = regexprep(trformat,'%4d-[0-9][0-9][0-9]','%4d-%3d');
    trformat = regexprep(trformat,'%4d-[0-9][0-9]','%4d-%2d');
    trformat = regexprep(trformat,'%4d-%2d-[0-9][0-9]','%4d-%2d-%2d');
    trformat = regexprep(trformat,'T[0-9][0-9]','T%2d');
    trformat = regexprep(trformat,'T%2d:[0-9][0-9]','T%2d:%2d');
    trformat = regexprep(trformat,'T%2d:%2d:[0-9][0-9]','T%2d:%2d:%2d');

    na = 0; % Number of 0s to be appended 
    if regexp(t1,'\.[0-9]') % Has one or more digits after decimal
        nd = length(regexprep(t1,'.*\.([0-9].*)','$1')); % # of decimals
        if (nd > 0) % Has digits after decimal
            nb = floor(nd/3);   % # blocks of 3
            nr = mod(nd,3);     % # remaining after blocked
            % Replace blocks of three digits with %3d
            if (nr > 0)
                na = 3-(nd-3*nb);   % # of 0s to append
                pad = sprintf('%%%dd',nr);
            else
                na = 0;
                pad = '';
            end
            trformat = regexprep(trformat,'(.*)\..*',...
                           ['$1.',repmat('%3d',1,nb),pad]);
        end
    end
    trformat = [trformat,Z]; % Recover trailing Z
    twformat = regexprep(trformat,'%([2-9])','%0$1');
