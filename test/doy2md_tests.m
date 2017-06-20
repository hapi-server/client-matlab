% Tests of the doy2md function in hapi.m
clear

if ~exist('doy2md.m','file')
    % Extract function
    fid = fopen('../hapi.m','r');
    c = fscanf(fid,'%c');
    fclose(fid);
    I = strfind(c,sprintf('\nfunction '));
    fid = fopen('doy2md.m','w');
    fwrite(fid,c(I(2)+1:I(3)-1));
    fclose(fid);
    rehash
end

lys = [1904, 1908, 1912, 1916, 1920, 1924, 1928, 1932, 1936, 1940, 1944, 1948, 1952, 1956, 1960, 1964, 1968, 1972, 1976, 1980, 1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012, 2016, 2020];

for i = 1:length(lys)
    k = 3*(i-1);
    in(k+1,:)  = [lys(i),1];
    out(k+1,:) = [lys(i),1,1];
    in(k+2,:)  = [lys(i),31+29];
    out(k+2,:) = [lys(i),2,29];
    in(k+3,:)  = [lys(i),366];
    out(k+3,:) = [lys(i),12,31];
end
ko = size(in,1);
for i = 1:length(lys)
    k = ko + 3*(i-1);
    in(k+1,:)  = [lys(i)+1,1];
    out(k+1,:) = [lys(i)+1,1,1];
    in(k+2,:)  = [lys(i)+1,31+29];
    out(k+2,:) = [lys(i)+1,3,1];
    in(k+3,:)  = [lys(i)+1,365];
    out(k+3,:) = [lys(i)+1,12,31];
end
n = size(in,1);
in(n+1,:)  = [1900,31+29];
out(n+1,:) = [1900,3,1];
in(n+2,:)  = [2100,31+29];
out(n+2,:) = [2100,3,1];
in(n+2,:)  = [2200,31+29];
out(n+2,:) = [2200,3,1];

for i = 1:size(in,1)
    md = doy2md(in(i,:));
    
    if md == out(i,2:3)
        fprintf('Pass on %d, %d\n',in(i,:));
    else
        error('Fail on %d, %d\n',in(i,:));
    end
    
end
