function doplay(player, ax, handles, timewindow, stime, samples, hits2)
    global eepplayers lasttime
    
    time = (player.CurrentSample - 1) / player.SampleRate;
    
    % move along the plot in time to the song
    xlim(ax(1), timewindow+time);
    xlim(ax(4), timewindow+time);
    
    % update the vertical lines in the PSD plots
    handles(1).XData = [1 1]*time;
    handles(2).XData = [1 1]*time;
    
    % update dot in samples plot
    k = find(time >= stime, 1, 'last');
    handles(3).XData = stime(k);
    handles(3).YData = samples(k);
    
    % update the location of the box indicating player position
    handles(4).XData = [1 1 1 1]*time;
    
    
    % play the hit sounds for any blocks that have passed the player since
    % the last frame
    if ~isempty(eepplayers)
        k = hits2 > lasttime & hits2 < time;
        
        if sum(k) > 0
            eepat = find([eepplayers{:,2}] == 1);
            play(eepplayers{eepat,1})

            % rotate through the hit sound players
            eepplayers{eepat,2} = 0;
            eepat = eepat + 1;
            if eepat > length(eepplayers)
                eepat = 1;
            end
            eepplayers{eepat,2} = 1;
        end
    end

    if length(handles) > 4 && ~isa(handles(5), 'matlab.graphics.GraphicsPlaceholder')
        fps = 1/(time-lasttime);
        handles(5).String = sprintf('%0.1f fps', fps);
    end
    
    lasttime = time;