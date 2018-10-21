function [handle, hits] = displaybs(ax, data, currenttime)

    % level display settings
    noteboxes = 1; % draw boxes around notes, not idea when enablefading = 1
    timestretch = 2; % how much to stretch the time axis (greater for busier songs)
    
    % colors of the blocks
    colors = {'r', 'b'};

    % settings from json
    notes = data.x_notes;
    bpm = data.x_beatsPerMinute;

    % coordinates for patchs to represent each note
    TY = cell(1, 9);
    TZ = cell(1, 9);
    
    % coordinates to draw a triangle poly
    TYo = ([0 6 3]-3)*0.1;
    TZo = ([0 0 4.8]-4.8/2)*0.1;

    % the angles at which blocks are rotated
    angles = [0 180 90 270 45 315 135 225];

    % rotate the triangle coordinates appropriately
    for ii=1:length(angles)
        theta = angles(ii);
        R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
        point = R*[TYo; TZo];
        TY{ii} = point(1,:);
        TZ{ii} = point(2,:);
    end

    % create a circle for the circle blocks
    ang = 0:(pi/4):2*pi;
    TY{end} = cos(ang)'*0.2;
    TZ{end} = sin(ang)'*0.2;

    % array of the times at which all blocks occur
    hits = zeros(size(notes));
    % array of handles to patch objects
    allph(1:length(notes)) = patch;
    if noteboxes == 1
        longlineX = nan(1,6*length(notes));
        longlineY = nan(1,6*length(notes));
        longlineZ = nan(1,6*length(notes));
    end
    
    cla(ax)
    hold(ax, 'on')
    % loop through all notes in the json and draw them at the appriate
    % coordiantes
    for ii=1:length(notes)

        % convert the note position to time in seconds
        x = notes(ii).x_time/bpm*60;
        y = notes(ii).x_lineIndex + 1;
        z = notes(ii).x_lineLayer + 1;
        % type 2 is a mine? ignore
        if notes(ii).x_type > 1
            continue
        end
        c = colors{notes(ii).x_type+1};
        d = notes(ii).x_cutDirection+1;
        hits(ii) = x;
    
        allph(ii) = patch(ones(size(TY{d}))*x, TY{d}+y, TZ{d}+z, c);
        allph(ii).FaceAlpha = 0.5;
    
        if noteboxes == 1
            longlineX((ii-1)*6+1:(ii*6)-1) = x;
            if d < 5 || d > 8
                longlineY((ii-1)*6+1:(ii*6)-1) = [1 -1 -1 1 1]*0.4+y;
                longlineZ((ii-1)*6+1:(ii*6)-1) = [-1 -1 1 1 -1]*0.4+z;
            else % diagonal block
                longlineY((ii-1)*6+1:(ii*6)-1) = [0 1 0 -1 0]*0.566+y;
                longlineZ((ii-1)*6+1:(ii*6)-1) = [-1 0 1 0 -1]*0.566+z;
            end
        end
    
    end
    if noteboxes == 1
        line(longlineX, longlineY, longlineZ, 'Color', 'k')
    end
    hold(ax, 'off')

    % format the plot, setup the axis limits, etc
    axis(ax, 'image')
    grid(ax, 'on');
    box(ax, 'on');

    ylim(ax, [0.5 4.5])
    zlim(ax, [0.5 3.5])

    set(ax, 'YTick', 0:5)
    set(ax, 'ZTick', 0:5)
    % the column coordinates are backwards from what we expect, so flip
    set(ax, 'YDir', 'reverse')

    ylabel(ax, 'lineIndex');
    zlabel(ax, 'lineLayer');
    xlabel(ax, 'Time (seconds)');

    % initial view
    % view(ax, [-45 45])
    view(ax, [-45 20])
    % view(ax, [-85 10])

    % set tick marks at 1 second intervals for the whole song
    xl = xlim(ax);
    set(ax, 'XTick', floor(min(xl)):(max(xl)+1))
    % stretch out time
    set(ax,'DataAspectRatio',[1/timestretch 1 1])
    set(ax, 'YTickLabel', [], 'ZTickLabel', [])

    % create coordinates for a rectangle patch that is the where the player
    % stands
    X = ones(1,4)*currenttime;
    yl = ylim(ax);
    zl = zlim(ax);
    Y = [yl(1) yl(2) yl(2) yl(1)];
    Z = [zl(1) zl(1) zl(2) zl(2)];
    handle = patch(X, Y, Z, 'k');
    handle.FaceAlpha = 0.2;
    
    drawnow