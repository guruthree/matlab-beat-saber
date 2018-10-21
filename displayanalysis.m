function handle = displayanalysis(ax, allPxx, F, ptime)

%     ylog = 0;
    ylog = 1;

    logbase = 32;
    mylog = @(x)log(x)/log(logbase);

    % TODO bin the frequencies like a graphic equaliser? according to notes?
    % f = round(2^((p-69)/12)*440) 

    
    if ylog == 0
        pcolor(ax, ptime, F, log10(allPxx'))
        ylim(ax, [0 FFTlength/2])
    else
        pcolor(ax, ptime, mylog(F), log10(allPxx'))
        ylim(ax, mylog([32 8192]))
    end
    shading(ax, 'flat')

    caxis(ax, [-10 -2])

    xlabel(ax, 'Time (seconds)')
    ylabel(ax, 'Frequency (Hz)')

    if ylog == 1
        yts = get(ax, 'YTick');
        lab = cellfun(@(x)sprintf('%.0f', x), num2cell(logbase.^yts), 'UniformOutput', 0);
        set(ax, 'YTickLabel', lab);
    end

    yl = ylim(ax);
    hold(ax, 'on')
    handle = line(ax, [1 1]*ptime(1), yl, 'Color', 'w');
    hold(ax, 'off')

    xlabel(ax, 'Time (seconds)')
    ylabel(ax, 'Frequency (Hz)')
    
    drawnow