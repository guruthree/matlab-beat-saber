function doplay(player, ax, handles, timewindow, stime, samples, hits2);
    global eepplayers mytime lasttime
    
    time = toc(mytime);
    currenttime = (player.CurrentSample - 1) / player.SampleRate;
    
    % move along the plot in time to the song
    xlim(ax(1), timewindow+currenttime);
    xlim(ax(4), timewindow+currenttime);
    
    % update the vertical lines in the PSD plots
    set(handles(1), 'XData', [1 1]*currenttime);
    set(handles(2), 'XData', [1 1]*currenttime);
    
    % update dot in samples plot
    k = find(currenttime >= stime, 1, 'last');
    set(handles(3), 'XData', stime(k), 'YData', samples(k))
    
    % update the location of the box indicating player position
    set(handles(4), 'XData', [1 1 1 1]*currenttime)
    
    
    drawnow
    
    % play the hit sounds for any blocks that have passed the player since
    % the last frame
%     if dohitsound == 1 && time >= hits2(hat)
%         play(eepplayers{eepat})
%         hat = hat + 1;
%         % rotate through the hit sound players
%         eepat = eepat + 1;
%         if eepat > length(eepplayers)
%             eepat = 1;
%         end
%     end

    if length(handles) > 4 && ~isa(handles(5), 'matlab.graphics.GraphicsPlaceholder')
        fps = 1/(time-lasttime);
        handles(5).String = sprintf('%0.1f fps', fps);
    end
    
    lasttime = time;




