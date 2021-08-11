server     = 'http://hapi-server.org/servers/TestData2.0/hapi';
dataset    = 'dataset1';
parameters = 'scalar';
start      = '1970-01-01';
%stop       = '1970-01-02T00:00:00';
stop       = '1970-01-01T00:00:02';
opts       = struct('logging',1);

%[data,meta] = hapi(server, dataset, parameters, start, stop, opts);

% First, from the command line execute
% curl 'http://hapi-server.org/servers/TestData2.0/hapi/data?id=dataset1&time.min=1970-01-01&time.max=1970-01-01T00:00:02&parameters=scalar&format=binary' > a.bin
% Or access this URL from a browser and save the file as a.bin
% Also, remove the &format=binary and save a.csv so that you can see
% the contents of a.bin.

% Download metadata associate with 'scalar' parameter.
meta = hapi(server, dataset, parameters, opts);

% Manually generate information needed to read file
if 1
    filebin = 'a.bin';

    fid = fopen(filebin,'rb');
    databin = fread(fid,'uint8=>uint8');
    fclose(fid);
    % databin is an array of unsigned ints. The length of databin
    % should match the number of bytes in the file.

    % Compute number of bytes per record (corresponding to a row in csv)
    % The first column (record) is always a time string with length given
    % by meta.parameters{1}.length. Add this to the number of bytes of
    % a double (8)
    bytes_per_record = meta.parameters{1}.length + 8;
    
    % Number of records (or rows in csv)
    Nt = length(databin)/bytes_per_record;
    
    % Reshape to make extraction easier.
    databin = reshape(databin, bytes_per_record, Nt);
    % Extract elements associated with time parameter and cast
    Time = char(databin(1:24,:)');

    % Extract elements associated with scalar parameter and cast
    scalar = databin(25:32,:);
    % Must flatten using scalar(:) as typecast() requires a vector.
    scalar = typecast(scalar(:),'double');

    whos Time scalar
end

if 1
    data = struct();
    for i = 1:length(meta.parameters)
        pnames{i} = meta.parameters{i}.name;
        ptypes{i} = meta.parameters{i}.type;
        psizes{i} = [1]; % Default size
        if isfield(meta.parameters{i},'size')
            psizes{i} = meta.parameters{i}.size;
        end
        if any(strcmp(ptypes{i},{'integer','double'}))
            Nc = 8*prod(psizes{i});
        end
        if any(strcmp(ptypes{i},{'string','isotime'}))
            Nc = meta.parameters{i}.length*prod(psizes{i});
        end
        if i == 1
            fcol(i) = 1;
        else
            fcol(i) = lcol(i-1) + 1;
        end
        lcol(i) = fcol(i) + Nc - 1;
        fprintf('Parameter %s occupies columns %d through %d\n',pnames{i},fcol(i),lcol(i))
        tmp = databin(fcol(i):lcol(i),:);
        % TODO: If length(psizes{i}) > 1, an additional reshape is needed.
        if strcmp(ptypes{i},'integer')
            tmp = typecast(tmp(:),'int32');
            xsize = [Nt, psizes{:}];
            data.(pnames{i}) = reshape(tmp, xsize);
        end
        if strcmp(ptypes{i},'double')
            tmp = typecast(tmp(:),'double');
            xsize = [Nt, psizes{:}];
            data.(pnames{i}) = reshape(tmp, xsize);
        end        
        if strcmp(ptypes{i},'string')
            tmp = char(tmp');
            %xsize = [Nt, meta.parameters{i}.length];
            data.(pnames{i}) = tmp;
        end        
        if strcmp(ptypes{i},'isotime')
            tmp = char(tmp');
            %xsize = [Nt, meta.parameters{i}.length];
            data.(pnames{i}) = tmp;
        end        
    end
    data
end
