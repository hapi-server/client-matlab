function hapiplot(meta,data)

fname = sprintf('%s_%s_%s_%s',...
                meta.x_dataset,...
                regexprep(meta.x_request_parameters,',','-'),...
                regexprep(meta.x_request_time_min,'-|:\.|Z',''),...
                regexprep(meta.x_request_time_max,'-|:|\.|Z',''));

figure;

if (size(data,2) == 2)
    % Replace fills with NaN for plotting (so gaps shown in line)
    data(data(:,2) == str2num(meta.parameters{2}.fill)) = NaN;
    ph = plot(data(:,1),data(:,2));
    th = title(sprintf('%s/id=%s&parameters=%s',...
        meta.x_server,meta.x_dataset,meta.parameters{2}.name));
    set(th,'Interpreter','none','FontWeight','normal');
    yh = ylabel([meta.parameters{2}.name,' [',meta.parameters{2}.units,']']);
    set(yh,'Interpreter','none'); % Don't interpret _ as subscript
    datetick
    grid on;
    if (data(1,1) - data(end,1) <= 1)
        xlabel(['Universal Time on ',datestr(data(1,1),'yyyy-mm-dd')]);
    else
        xlabel('Universal Time');
    end
end

if (size(data,2) > 4)
    % Spectrogram

    time  = data(:,1);
    data  = data(:,2:end);
    bins  = meta.parameters{2}.bins.centers;
    % Note bin ranges are given, but not used here.

    % Replace fills with NaN for plotting (so white tile is shown)
    data(data == str2num(meta.parameters{2}.fill)) = NaN;

    m     = min(min(data));
    data  = log10(data - m + 1);

        % Plot matrix as colored squares.
        p = pcolor(time',log10(bins'),data');
        set(p,'EdgeColor','none'); % Don't show boundaries for squares.
        ch = colorbar;
        title(ch,sprintf('log_{10}(%s + %.1f + 1 [%s])',...
            meta.parameters{2}.name,abs(m),meta.parameters{2}.units));
        th = title(sprintf('%s/id=%s&parameters=%s',...
            meta.x_server,meta.x_dataset,meta.parameters{2}.name));
        set(th,'Interpreter','none','FontWeight','normal');
        if (isfield(meta.parameters{2},'units'))
            units = meta.parameters{2}.units;
            yl = [meta.parameters{2}.bins.name,' [',units,']'];
        else
            yl = [meta.parameters{2}.bins.name];
        end
        yh = ylabel(sprintf('log_{10}(%s)',yl));
        datetick;
        grid on;
        if (time(1) - time(1) <= 1)
            % Show date in x-label b/c because datetick does not
            % show date if <= one day of data.
            xlabel(['Universal Time on ',datestr(time(1),'yyyy-mm-dd')]);
        else
            xlabel('Universal Time');
        end
end

if ~exist('hapi-figures','dir'),mkdir('hapi-figures');end
fname = ['./hapi-figures/',fname,'.png'];
print('-dpng',fname);
fprintf('hapiplot.m: Wrote %s\n',fname);
