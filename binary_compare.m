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

% Download  HAPI binary
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=binary'],[file,'.bin']);
% Download fast binary
urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],[file,'.fbin']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot using fast binary download
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
fprintf('fbin total:       %.04f\n',t1);
%end

figure(1);clf;
plot(A(:,1),A(:,2),'b'); % Plot first data column
datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot using HAPI binary download

m = memmapfile([file,'.bin'], 'Format',...
    {'uint8' [1 24] 'time'; 'double', [1 n] 'data'});
t(1) = toc;
fprintf('bin memmap:       %0.4f\n',t(1));

% Extract data
tic
Data = m.Data;
data = [Data.data];
data = reshape(data,n,length(data)/n)';
t(2) = toc;    
fprintf('bin extract data: %0.4f\n',t(2));

% Extract time strings
tic
time = char(Data.time);
t(3) = toc;
fprintf('bin extract time: %0.4f\n',t(3));

% Convert strings to numeric value
tic
time = datenum(time,'yyyy-mm-ddTHH:MM:SS');
t(4) = toc;
fprintf('bin datenum:      %0.4f\n',t(4));

fprintf('bin/fbin speed:   %0.1f\n',sum(t)/t1);

figure(1);hold on;
plot(time,data(:,1),'r');
datetick;

if ~all(data==A(:,2:end))
    error('Data do not match\n');
end
clear data time Data % Un-memmap file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

