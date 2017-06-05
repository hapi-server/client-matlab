clear

% Test server that serves HAPI CSV and binary and the proposed CSV and
% binary.
%base = 'http://localhost:8999/hapi';
base = 'http://mag.gmu.edu/TestData/hapi';

% Choose data type (speed-up is not very dependent on which is used).
file = 'scalar'; n = 1; % Would get n from size from /info
%file = 'vector';  n = 3; % (3-component)
%file = 'spectra'; n = 10; % (10-channel)

% Download HAPI csv
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=csv'],[file,'.csv']);
% Download HAPI binary
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=binary'],[file,'.bin']);
% Download fast csv
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fcsv'],[file,'.fcsv']);
% Download fast binary; all doubles
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],[file,'.fbin']);
% Download fast binary; time is double, parameter is integer
urlwrite([base,'/data/?id=TestData&parameters=',file,'int','&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],[file,'int.fbin']);

% Note that the fast binary served from the above server have the ordinal
% time and time unit in the first 21 bytes of the file. The fast csv file
% is assumed to start at an arbitrary ordinal time. The results will not 
% change when this information is moved to the response from a /info
% request for the parameter.

figure(1);clf;hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and HAPI csv
tic
fid = fopen([file,'.csv'],'r');
str = fscanf(fid,'%c');
fclose(fid);
patm = '(^|\n)([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{0,3})Z*,';
patr = '$1$2,$3,$4,$5,$6,$7.$8,';
str = regexprep(str,patm,patr);
datacsv = str2num(str);
datacsv = [datenum(datacsv(:,1:6)),datacsv(:,7:end)];
tcsv = toc;
fprintf('csv total:         %.4fs\t# HAPI CSV\n',tcsv);

figure(1);
plot(datacsv(:,1),datacsv(:,2),'b'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast CSV
tic
datafcsv = load([file,'.fcsv']);
datafcsv(:,1) = datafcsv(:,1)/86400 + datenum(1970,1,1);
tfcsv = toc;
fprintf('fcsv total:        %.4fs\t# Proposed fast CSV\n',tfcsv);

figure(1);
plot(datafcsv(:,1),datafcsv(:,2),'b'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast binary containing doubles and ints
if (0) % Much slower than using fread as below.
    tic
    m = memmapfile([file,'int.fbin'], 'Offset',22,'Format',...
        {'double' [1 n] 'time'; 'int8', [1 n] 'data'});

    % Extract data
    Data = m.Data;
    data0 = [Data.data];
    time0 = [Data.time];
    t0 = toc;
    fprintf('fbin w/ints mmap: %.4fs\n',t0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast binary containing all doubles
% Much faster than using memmapfile()
tic
fid = fopen([file,'.fbin'],'r');
head = char(fread(fid,21,'uint8=>char'));
datafbin1 = fread(fid,'double');
fclose(fid);
datafbin1 = reshape(datafbin1,n+1,length(datafbin1)/(n+1))';
zerotime = datenum(head(2:end)','yyyy-mm-ddTHH:MM:SS');
f = 10^(3*str2num(head(1)));
datafbin1(:,1) =  zerotime + datafbin1(:,1)/(86400*f);
tfbin1 = toc;
fprintf('fbin total:        %.04fs\t# Proposed binary (both doubles)\n',tfbin1);

figure(1);
plot(datafbin1(:,1),datafbin1(:,2),'m'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast binary containing doubles and ints
tic
fid = fopen([file,'int.fbin'],'r');
head = char(fread(fid,21,'uint8=>char'));
timefbin2 = fread(fid,'double',4);
fseek(fid,21+8,'bof');
datafbin2 = fread(fid,'int32=>double',8);
fclose(fid);
zerotime = datenum(head(2:end)','yyyy-mm-ddTHH:MM:SS');
f = 10^(3*str2num(head(1)));
timefbin2(:,1) =  zerotime + timefbin2/(86400*f);
tfbin2 = toc;
fprintf('fbin w/ints total: %.4fs\t# Proposed binary (time dbl, param int)\n',tfbin2);

figure(1)
plot(timefbin2,datafbin2/1000,'g'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot using HAPI binary download
tic
m = memmapfile([file,'.bin'], 'Format',...
    {'uint8' [1 24] 'time'; 'double', [1 n] 'data'});
tbin(1) = toc;

% Extract data
tic
Data = m.Data;
databin = [Data.data];
databin = reshape(databin,n,length(databin)/n)';
tbin(2) = toc;    

% Extract time strings
tic
timebin = char(Data.time);
tbin(3) = toc;

% Convert strings to numeric value
tic
timebin = datenum(timebin,'yyyy-mm-ddTHH:MM:SS');
tbin(4) = toc;

figure(1);
plot(timebin,databin(:,1),'r');
datetick;

clear databin timebin Data % Un-memmap file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
fprintf('bin total:         %0.4fs\t# HAPI binary\n',sum(tbin));
fprintf('  (bin memmap:        %0.4fs)\n',tbin(1));
fprintf('  (bin extract data:  %0.4fs)\n',tbin(2));
fprintf('  (bin extract time:  %0.4fs)\n',tbin(3));
fprintf('  (bin datenum:       %0.4fs)\n',tbin(4));

fprintf('\nTime Ratios\n')
fprintf('csv/fcsv:          %0.1f\n',tcsv/tfcsv);
fprintf('csv/bin:           %0.1f\n',tcsv/sum(tbin));
fprintf('bin/fbin:          %0.1f\n',sum(tbin)/tfbin1);
fprintf('bin/(fbin w/ints): %0.1f\n',sum(tbin)/tfbin2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

