clear

% Download bin (HAPI binary) and fbinary ("fast binary") files containing
% 86400 rows.
base = 'http://localhost:8999/hapi';
base = 'http://mag.gmu.edu/TestData/hapi';

% Choose data type (speed-up is not very dependent on which is
% used).
file = 'scalar'; n = 1; % Would get n from size from /info
%file = 'vector';  n = 3; % (3-component)
%file = 'spectra'; n = 10; % (10-channel)

% Download  HAPI csv
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=csv'],[file,'.csv']);
% Download  HAPI binary
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=binary'],[file,'.bin']);
% Download fast csv
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fcsv'],[file,'.fcsv']);
% Download fast binary; all doubles
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],[file,'.fbin']);
% Download fast binary; mixed
urlwrite([base,'/data/?id=TestData&parameters=',file,'int','&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],[file,'int.fbin']);

figure(1);clf;hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot csv
tic
fid = fopen([file,'.csv'],'r');
str = fscanf(fid,'%c');
fclose(fid);
patm = '(^|\n)([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{0,3})Z*,';
patr = '$1$2,$3,$4,$5,$6,$7.$8,';
str = regexprep(str,patm,patr);
data = str2num(str);
data = [datenum(data(:,1:6)),data(:,7:end)];
tc = toc;
fprintf('csv total:         %.4fs\t# HAPI CSV\n',tc);
figure(1);
plot(data(:,1),data(:,2),'b'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast csv
tic
data = load([file,'.fcsv']);
tfc = toc;
fprintf('fcsv total:        %.4fs\t# Proposed CSV\n',tfc);
figure(1);
plot(data(:,1),data(:,2),'b'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (0) % Much slower than using fread twice as below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast binary containing doubles and ints
tic
m = memmapfile([file,'int.fbin'], 'Offset',22,'Format',...
    {'double' [1 n] 'time'; 'int8', [1 n] 'data'});

% Extract data
Data = m.Data;
data0 = [Data.data];
time0 = [Data.time];
t0 = toc;
fprintf('fbin w/ints total: %.4fs\n',t0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast binary containing all doubles
%for i = 1:10 % Gets 4x faster after first iteration (jit?)
tic
fid = fopen([file,'.fbin'],'r');
a = char(fread(fid,21,'uint8=>char'));
A = fread(fid,'double');
fclose(fid);
A = reshape(A,n+1,length(A)/(n+1))';
zerotime = datenum(a(2:end)','yyyy-mm-ddTHH:MM:SS');
f = 10^(3*str2num(a(1)));
A(:,1) =  zerotime + A(:,1)/(86400*f);
t1 = toc;
fprintf('fbin total:        %.04fs\t# Proposed binary (time and parameter doubles)\n',t1);
%end

figure(1);
plot(A(:,1),A(:,2),'m'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot fast binary containing doubles and ints
% Much faster method use fread twice
tic
fid = fopen([file,'int.fbin'],'r');
a = char(fread(fid,21,'uint8=>char'));
time0 = fread(fid,'double',4);
fseek(fid,21+8,'bof');
data0 = fread(fid,'int32=>double',8);
fclose(fid);
zerotime = datenum(a(2:end)','yyyy-mm-ddTHH:MM:SS');
f = 10^(3*str2num(a(1)));
time0(:,1) =  zerotime + time0/(86400*f);
t0 = toc;
fprintf('fbin w/ints total: %.4fs\t# Proposed binary (time is double, parameter is integer)\n',t0);
figure(1)
plot(time0,data0/1000,'g'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot using HAPI binary download
tic
m = memmapfile([file,'.bin'], 'Format',...
    {'uint8' [1 24] 'time'; 'double', [1 n] 'data'});
t(1) = toc;
% Extract data
tic
Data = m.Data;
data = [Data.data];
data = reshape(data,n,length(data)/n)';
t(2) = toc;    

% Extract time strings
tic
time = char(Data.time);
t(3) = toc;

% Convert strings to numeric value
tic
time = datenum(time,'yyyy-mm-ddTHH:MM:SS');
t(4) = toc;
fprintf('bin total:         %0.4fs\t# HAPI binary\n',sum(t));
fprintf('  (bin memmap:        %0.4fs)\n',t(1));
fprintf('  (bin extract data:  %0.4fs)\n',t(2));
fprintf('  (bin extract time:  %0.4fs)\n',t(3));
fprintf('  (bin datenum:       %0.4fs)\n',t(4));

fprintf('\nTime Ratios\n')
fprintf('csv/fcsv:          %0.1f\n',tc/tfc);
fprintf('csv/bin:           %0.1f\n',tc/sum(t));
fprintf('bin/fbin:          %0.1f\n',sum(t)/t1);
fprintf('bin/(fbin w/ints): %0.1f\n',sum(t)/t0);

figure(1);
plot(time,data(:,1),'r');
datetick;

if ~all(data==A(:,2:end))
    error('Data do not match\n');
end
clear data time Data % Un-memmap file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

