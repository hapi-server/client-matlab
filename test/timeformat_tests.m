% Tests of the timeformat and DTVec functions in hapi.m
clear

if ~exist('timeformat.m','file')
    % Extract functions
    fid = fopen('../hapi.m','r');
    c = fscanf(fid,'%c');
    fclose(fid);
    I = strfind(c,sprintf('\nfunction '));
    fid = fopen('normalizeDTVec.m','w');
    fwrite(fid,c(I(1)+1:I(2)-1));
    fclose(fid);
    fid = fopen('timeformat.m','w');
    fwrite(fid,c(I(3)+1:end));
    fclose(fid);
    rehash
end

instr{1} = sprintf('2000,1\n2000,2');
test{1}  = [2000,1,1;2000,1,1]';
test2{1} = [2000,1,1;2000,1,1]';

instr{2} = sprintf('2000-365,1\n2000-365,2');
test{2}  = [2000,365;2000,365]';
test2{2} = [2000,12,30;2000,12,30]';

instr{3} = sprintf('2000-365T01,1\n2000-365T01,2');
test{3}  = [2000,365,1;2000,365,1;2000,365,1]';
test2{3} = [2000,12,30,1;2000,12,30,1]';

instr{4} = sprintf('2000-365T01:59,1\n2000-365T01:59,2');
test{4}  = [2000,365,1,59;2000,365,1,59]';
test2{4} = [2000,12,30,1,59;2000,12,30,1,59]';

instr{5} = sprintf('2000-365T01:59:59,1\n2000-365T01:59:59,2');
test{5}  = [2000,365,1,59,59;2000,365,1,59,59]';
test2{5} = [2000,12,30,1,59,59;2000,12,30,1,59,59]';

instr{6} = sprintf('2000-365T01:59:59.9,1\n2000-365T01:59:59.9,2');
test{6}  = [2000,365,1,59,59,900;2000,365,1,59,59,900]';
test2{6} = [2000,12,30,1,59,59,900;2000,12,30,1,59,59,900]';

instr{7} = sprintf('2000-365T01:59:59.98,1\n2000-365T01:59:59.97,2');
test{7}  = [2000,365,1,59,59,980;2000,365,1,59,59,970]';
test2{7} = [2000,12,30,1,59,59,980;2000,12,30,1,59,59,970]';

instr{8} = sprintf('2000-365T01:59:59.981,1\n2000-365T01:59:59.971,2');
test{8}  = [2000,365,1,59,59,981;2000,365,1,59,59,971]';
test2{8} = [2000,12,30,1,59,59,981;2000,12,30,1,59,59,971]';

instr{9} = sprintf('2000-365T01:59:59.9815,1\n2000-365T01:59:59.9716,2');
test{9}  = [2000,365,1,59,59,981,500;2000,365,1,59,59,971,600]';
test2{9} = [2000,12,30,1,59,59,981,500;2000,12,30,1,59,59,971,600]';

instr{10} = sprintf('2000-365T01:59:59.123456789,1\n2000-365T01:59:59.123456789,2');
test{10}  = [2000,365,1,59,59,123,456,789;2000,365,1,59,59,123,456,789]';
test2{10} = [2000,12,30,1,59,59,123,456,789;2000,12,30,1,59,59,123,456,789]';

instr{11} = sprintf('2000-01,1\n2000-11,2');
test2{11} = [2000,1,1;2000,11,1]';

instr{12} = sprintf('2000-01-02,1\n2000-11-03,2');
test2{12} = [2000,1,2;2000,11,3]';

instr{13} = sprintf('2000-01-02T02,1\n2000-11-03T03,2');
test2{13} = [2000,1,2,2;2000,11,3,3]';

instr{14} = sprintf('2000-01-02T02:59,1\n2000-11-03T03:58,2');
test2{14} = [2000,1,2,2,59;2000,11,3,3,58]';

instr{15} = sprintf('2000-01-02T02:59:33,1\n2000-11-03T03:58:34,2');
test2{15} = [2000,1,2,2,59,33;2000,11,3,3,58,34]';

instr{16} = sprintf('2000-01-02T02:59:33.,1\n2000-11-03T03:58:34.,2');
test2{16} = [2000,1,2,2,59,33;2000,11,3,3,58,34]';

instr{17} = sprintf('2000-01-02T02:59:33.5,1\n2000-11-03T03:58:34.6,2');
test2{17} = [2000,1,2,2,59,33,500;2000,11,3,3,58,34,600]';

instr{18} = sprintf('2000-01-02T02:59:33.52,1\n2000-11-03T03:58:34.63,2');
test2{18} = [2000,1,2,2,59,33,520;2000,11,3,3,58,34,630]';

instr{19} = sprintf('2000-01-02T02:59:33.528,1\n2000-11-03T03:58:34.639,2');
test2{19} = [2000,1,2,2,59,33,528;2000,11,3,3,58,34,639]';

instr{20} = sprintf('2000-01-02T02:59:33.5284,1\n2000-11-03T03:58:34.6395,2');
test2{20} = [2000,1,2,2,59,33,528,400;2000,11,3,3,58,34,639,500]';

nt = length(test2);
for i = 1:length(test2)
    instr{nt+i} = regexprep(instr{i},',','Z,');
    test2{nt+i} = test2{i};
end


for i = 1:length(instr)

    test2{i} = int32(test2{i});
    % Ifc = index of first comma.  
    % Assumes time stamps + whitespace <= 40 characters.
    Ifc = strfind(instr{i}(1:min(40,length(instr{i}))),',');
    if isempty(Ifc) 
        error('Problem with first time string in file');
    end
    t1  = deblank(instr{i}(1:Ifc-1));

    [rformat,twformat,timelen,na] = timeformat(t1);

    A = textscan(instr{i},[rformat,' %d'],'Delimiter',',');

    ntc = length(findstr('d',twformat));
    DTVec = transpose(cat(2,A{1:ntc}));
    DTVec = normalizeDTVec(DTVec,t1,na);

    if all(test2{i}(:) == DTVec(:))
        fprintf('Pass on %s\n',regexprep(instr{i},sprintf('\n'),'\\n'));
    else
        error('Fail on %s\n',regexprep(instr{i},sprintf('\n'),'\\n'));
        test{i}
        DTVec
        Time
    end
    DTVec = DTVec';

end


