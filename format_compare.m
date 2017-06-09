clear

% Test server of HAPI CSV and binary and the "Fast" CSV and binary.
base = 'http://localhost:8999/hapi';
%base = 'http://mag.gmu.edu/TestData/hapi';

% Choose data type (speed-up is not very dependent on which is used).
% Would get n from size from /info
file = 'scalar'; n = 1;

filecsv   = ['./tmp/',file,'.csv'];
filefcsv  = ['./tmp/',file,'.fcsv'];
filebin   = ['./tmp/',file,'.bin'];
filefbin  = ['./tmp/',file,'.fbin'];
filefbin2 = ['./tmp/',file,'.fbin2'];

if ~exist(['.',filesep(),'tmp'],'dir')
    mkdir(['.',filesep(),'tmp'])
end
if ~exist(filecsv,'file')
    % Download HAPI csv
    urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=csv'],filecsv);
end
if ~exist(filebin,'file')
    % Download HAPI binary
    urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=binary'],filebin);
end
if ~exist(filefcsv,'file')
    % Download fast csv
    urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fcsv'],filefcsv);
end
if ~exist(filefbin,'file')
    % Download fast binary; all doubles
    urlwrite([base,'/data/?id=TestData&parameters=',file,'&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],filefbin);
end
if ~exist(filefbin2,'file')
    % Download fast binary; time is double, parameter is integer
    urlwrite([base,'/data/?id=TestData&parameters=',file,'int','&time.min=1970-01-01&time.max=1970-01-02T00:00:00&format=fbinary'],filefbin2);
end

figure(1);clf;hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read "Fast" CSV
tic
fid = fopen(filefcsv,'r');
A = textscan(fid,'%f','Delimiter',',','CollectOutput',true);
fclose(fid);
datafcsv1 = reshape(A{1}',2,length(A{1})/2)';
datafcsv1(:,1) = datafcsv1(:,1)/86400 + datenum(1970,1,1);
tfcsv(1) = toc;
fprintf('fcsv (textscan)     %.4fs\t# "Fast" CSV\n',tfcsv(1));

figure(1);
plot(datafcsv1(:,1),datafcsv1(:,2),'b');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read "Fast" CSV
tic
datafcsv2 = load(filefcsv);
datafcsv2(:,1) = datafcsv2(:,1)/86400 + datenum(1970,1,1);
tfcsv(2) = toc;
fprintf('fcsv (load)         %.4fs\t# "Fast" CSV\n',tfcsv(2));

figure(1);
plot(datafcsv2(:,1),datafcsv2(:,2),'r');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI CSV
tic
fid = fopen(filecsv,'r');
format = '%{uuuu-MM-dd''T''HH:mm:ss.SSS}D %f';
datacsv1 = readtable(filecsv,'Delimiter',',','Format',format,'ReadVariableNames',false);
datacsv1.Var1 = datenum(datacsv1.Var1);
tcsv(1) = toc;
fprintf('csv (readtbl/tfmt)  %.4fs\t# HAPI CSV\n',tcsv(1));

figure(1);
plot(datacsv1.Var1,datacsv1.Var2,'g');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI CSV
tic
fid = fopen(filecsv,'r');
datacsv2 = textscan(fid,'%{uuuu-MM-dd''T''HH:mm:ss.SSS}D %f','Delimiter',',','DateLocale','en_US');
datacsv2{1} = datenum(datacsv2{1});
fclose(fid);
tcsv(2) = toc;
fprintf('csv (textscan/tfmt) %.4fs\t# HAPI CSV\n',tcsv(2));

figure(1);
plot(datacsv2{1},datacsv2{2},'k');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI CSV
tic;
format = '%4d-%2d-%2dT%2d:%2d:%2d.%3d %f';
fid = fopen(filecsv,'r');
datacsv3 = textscan(fid,format,'Delimiter',',','CollectOutput',true);
fclose(fid);
datacsv3{1} = double(datacsv3{1});
datacsv3{1} = datenum(double(datacsv3{1}(:,1:6))) + datacsv3{1}(:,7)/1000;
tcsv(3) = toc;
fprintf('csv (textscan)      %.4fs\t# HAPI CSV\n',tcsv(3));

figure(1);
plot(datacsv3{1},datacsv3{2},'y');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI CSV (slower method)
tic
fid = fopen(filecsv,'r');
str = fscanf(fid,'%c');
fclose(fid);
patm = '(^|\n)([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{0,3})Z*,';
patr = '$1$2,$3,$4,$5,$6,$7.$8,';
str = regexprep(str,patm,patr);
datacsv4 = str2num(str);
datacsv4 = [datenum(datacsv4(:,1:6)),datacsv4(:,7:end)];
tcsv(4) = toc;
fprintf('csv (regex/str2num) %.4fs\t# HAPI CSV\n',tcsv(4));

figure(1);
plot(datacsv4(:,1),datacsv4(:,2),'b');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Fast" binary file containing all doubles
tic
fid = fopen(filefbin,'r');
datafbin1 = fread(fid,'double');
fclose(fid);
datafbin1 = reshape(datafbin1,n+1,length(datafbin1)/(n+1))';
zerotime  = datenum('1970-01-01','yyyy-mm-dd');
datafbin1(:,1) =  zerotime + datafbin1(:,1)/(86400);
tfbin(1) = toc;
fprintf('fbin (fread)        %.04fs\t# "Fast" binary (both doubles)\n',tfbin(1));

figure(1);
plot(datafbin1(:,1),datafbin1(:,2),'m');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Fast" binary file containing all doubles
tic
m = memmapfile(filefbin,'Format','double');
datafbin2 = reshape(m.Data,2,length(m.Data)/(2))';
zerotime  = datenum('1970-01-01','yyyy-mm-dd');
datafbin2(:,1) = zerotime + datafbin2(:,1)/86400;
tfbin(2) = toc;
fprintf('fbin (mmap)         %.4fs\t# "Fast" binary (both doubles)\n',tfbin(2));

figure(1);
plot(datafbin2(:,1),datafbin2(:,2),'k');
drawnow;datetick;
clear m datafbin2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Fast" binary file containing double time, int32 parameter
tic
fid = fopen(filefbin2,'r');
timefbin3 = fread(fid,'double',4);
fseek(fid,8,'bof');
datafbin3 = fread(fid,'int32=>double',8);
fclose(fid);
zerotime = datenum('1970-01-01','yyyy-mm-dd');
timefbin3(:,1) =  zerotime + timefbin3(:,1)/(86400);
tfbin(3) = toc;
fprintf('fbin w/ints (fread) %.4fs\t# "Fast" binary (time dbl, param int)\n',tfbin(3));

figure(1)
plot(timefbin3,datafbin3/1000,'y'); % Int parameter is int32(1000*sin(t))
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Fast" binary containing double time and int32 parameter
tic
m = memmapfile(filefbin2,'Format',...
    {'double' [1 n] 'time'; 'int32', [1 n] 'data'});
Data      = m.Data;
datafbin4 = [Data.data];
zerotime  = datenum('1970-01-01','yyyy-mm-dd');
timefbin4 = zerotime + double([Data.time])/86400;
tfbin(4) = toc;
fprintf('fbin w/ints (mmap)  %.4fs\t# "Fast" binary (both doubles)\n',tfbin(4));

figure(1)
plot(timefbin4,datafbin4/1000,'y'); % Int parameter is int32(1000*sin(t))
drawnow;datetick;
clear m Data timefbin4 datfbin4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Fast" binary file
import java.nio.file.*
tic
p = Paths.get(filefbin(1:2),filefbin(3:end));
datafbin5 = Files.readAllBytes(p);
datafbin5 = typecast(datafbin5(:),'double');
datafbin5 = reshape(datafbin5,2,length(datafbin5)/2)';
zerotime  = datenum('1970-01-01');
datafbin5(:,1) = zerotime + datafbin5(:,1)/86400;

tfbin(5) = toc;
fprintf('fbin (java.nio)     %.4fs\t# "Fast" binary\n',tfbin(5));

figure(1)
plot(datafbin5(:,1),datafbin5(:,2),'y');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI binary file
import java.nio.file.*
tic
p = Paths.get(filebin(1:2),filebin(3:end));
databin1 = Files.readAllBytes(p);
databin1 = reshape(databin1,24+8,length(databin1)/(24+8))';
It = [1:4,6:7,9:10,12:13,15:16,18:19,21:23];
B = double(databin1(:,It) - '0');
B(:,1) = 1000*B(:,1) + 100*B(:,2) + 10*B(:,3) + B(:,4);
B(:,2) = 10*B(:,5) + B(:,6);
B(:,3) = 10*B(:,7) + B(:,8);
B(:,4) = 10*B(:,9) + B(:,10);
B(:,5) = 10*B(:,11) + B(:,12);
B(:,6) = 10*B(:,13) + B(:,14);
B(:,7) = 100*B(:,15) + 10*B(:,16) + B(:,17);
timebin1 = datenum(B(:,1:6)) + B(:,7)/86400000;
databin1 = databin1(:,25:end)';
databin1 = typecast(databin1(:)','double');
tbin(1) = toc;
fprintf('bin (java.nio)      %.4fs\t# HAPI binary\n',tbin(1));

figure(1)
plot(timebin1,databin1,'r');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read and plot using HAPI binary download
tic
fid = fopen(filebin,'rb');
format   = '24*char=>char';
timebin2 = fread(fid,Inf,format,8);
timebin2 = timebin2 - '0'; % ASCII code for 0 is 48.  Subtract off to get integers correct.
fseek(fid,24,'bof');
databin2 = fread(fid,Inf,'double',24);
fclose(fid);

I = [1:4,6:7,9:10,12:13,15:16,18:19,21:23];
timebin2 = reshape(timebin2,24,length(timebin2)/24)';
timebin2 = timebin2(:,I);
timebin2(:,1) = 1000*timebin2(:,1) + 100*timebin2(:,2) + 10*timebin2(:,3) + timebin2(:,4);
timebin2(:,2) = 10*timebin2(:,5) + timebin2(:,6);
timebin2(:,3) = 10*timebin2(:,7) + timebin2(:,8);
timebin2(:,4) = 10*timebin2(:,9) + timebin2(:,10);
timebin2(:,5) = 10*timebin2(:,11) + timebin2(:,12);
timebin2(:,6) = 10*timebin2(:,13) + timebin2(:,14);
timebin2(:,7) = 100*timebin2(:,15) + 10*timebin2(:,16) + B(:,17);
timebin2 = datenum(timebin2(:,1:6)) + timebin2(:,7)/86400000;
tbin(2) = toc;
fprintf('bin (kludge)        %.4fs\t# HAPI binary\n',tbin(2));

figure(1)
plot(timebin2,databin2,'r');
drawnow;datetick;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI binary
tic
m = memmapfile(filebin, 'Format',...
    {'uint8' [1 24] 'time'; 'double', [1 n] 'data'});
Data = m.Data;
databin3 = [Data.data]; 
timebin3 = [Data.time];
timebin3 = double(reshape(timebin3-'0',24,length(timebin3)/24)');
It = [1:4,6:7,9:10,12:13,15:16,18:19,21:23];
timebin3 = timebin3(:,It);
timebin3(:,1) = 1000*timebin3(:,1) + 100*timebin3(:,2) + 10*timebin3(:,3) + timebin3(:,4);
timebin3(:,2) = 10*timebin3(:,5) + timebin3(:,6);
timebin3(:,3) = 10*timebin3(:,7) + timebin3(:,8);
timebin3(:,4) = 10*timebin3(:,9) + timebin3(:,10);
timebin3(:,5) = 10*timebin3(:,11) + timebin3(:,12);
timebin3(:,6) = 10*timebin3(:,13) + timebin3(:,14);
timebin3(:,7) = 100*timebin3(:,15) + 10*timebin3(:,16) + timebin3(:,17);
timebin3 = datenum(timebin3(:,1:6)) + timebin3(:,7)/86400000;
tbin(3) = toc;
fprintf('bin (memmap alt):   %0.4fs\t# HAPI binary\n',tbin(3));

figure(1)
plot(timebin3,databin3,'r');
drawnow;datetick;
clear m Data timebin3 databin3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI binary
tic
m = memmapfile(filebin, 'Format','uint8');
databin4 = reshape(m.Data,24+8,length(m.Data)/(24+8))';

It = [1:4,6:7,9:10,12:13,15:16,18:19,21:23];
timebin4 = double(databin4(:,It) - '0');
timebin4(:,1) = [1000*timebin4(:,1) + 100*timebin4(:,2) + 10*timebin4(:,3) + timebin4(:,4)];
timebin4(:,2) = [10*timebin4(:,5) + timebin4(:,6)];
timebin4(:,3) = 10*timebin4(:,7) + timebin4(:,8);
timebin4(:,4) = 10*timebin4(:,9) + timebin4(:,10);
timebin4(:,5) = 10*timebin4(:,11) + timebin4(:,12);
timebin4(:,6) = 10*timebin4(:,13) + timebin4(:,14);
timebin4(:,7) = 100*timebin4(:,15) + 10*timebin4(:,16) + timebin4(:,17);
timebin4 = datenum(timebin4(:,1:6)) + timebin4(:,7)/86400000;

databin4 = databin4(:,25:end)';
databin4 = typecast(databin4(:)','double');

tbin(4) = toc;
fprintf('bin (memmap alt2):  %0.4fs\t# HAPI binary\n',tbin(4));

figure(1)
plot(timebin4,databin4,'y');
drawnow;datetick;
clear m timebin4 databin4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAPI binary file
tic
m = memmapfile(filebin, 'Format',...
    {'uint8' [1 24] 'time'; 'double', [1 n] 'data'});
tbinx(1) = toc;

% Extract data
tic
Data = m.Data;
databin5 = [Data.data];
databin5 = reshape(databin5,n,length(databin5)/n)';
tbinx(2) = toc;    

% Extract time strings
tic
timebin5 = char(Data.time);
tbinx(3) = toc;

% Convert strings to numeric value
tic
timebin5 = datenum(timebin5,'yyyy-mm-ddTHH:MM:SS');
tbinx(4) = toc;

tbin(5) = sum(tbinx);

figure(1);
plot(timebin5,databin5(:,1),'r');
datetick;

clear m Data databin5 timebin5  % Un-memmap file

fprintf('bin (mmap/datastr)  %0.4fs\t# HAPI binary\n',tbin(5));
%fprintf('  (bin memmap:        %0.4fs)\n',tbinx(1));
%fprintf('  (bin extract data:  %0.4fs)\n',tbinx(2));
%fprintf('  (bin extract time:  %0.4fs)\n',tbinx(3));
%fprintf('  (bin datenum:       %0.4fs)\n',tbinx(4));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
fprintf('\nBest-Time Ratios\n')
fprintf('csv/fcsv:   %0.1f\n',min(tcsv)/min(tfcsv));
fprintf('bin/fbin:   %0.1f\n',min(tbin)/min(tfbin));
fprintf('\n');
fprintf('csv/bin     %0.1f\n',min(tcsv)/min(tbin));
fprintf('fcsv/fbin:  %0.1f\n',min(tfcsv)/min(tfbin));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (0)
    url = java.net.URL(a)
    is = openStream(url);
    isr = java.io.InputStreamReader(is);
    br = java.io.BufferedReader(isr);
    for i = 1:86400
        s = readLine(br);
    end
    toc
end
