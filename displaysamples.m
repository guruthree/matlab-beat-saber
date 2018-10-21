function [handle, stime, samples] = displaysamples(ax, Y, Fs, currenttime)

    skip = Fs/100; % sub-sampling to clean-up plot
    
    Y2 = movmean(Y,skip);
    stime = (0:skip:(length(Y)-1))/Fs;
    samples = Y2(1:skip:end,1);
    plot(ax, stime, samples)

    k = find(currenttime >= stime, 1);
    if isempty(k)
        error('currenttime does not exist')
    end
    
    hold(ax, 'on')
    handle = plot(ax, stime(k), samples(k), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    hold(ax, 'off')
    
    ylabel(ax, 'Sample Level [-]')
    ax.XTickLabel = [];
    
    drawnow