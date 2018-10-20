clear

% level settings
levelfile = 'Expert.json';
songfile = 'song.ogg';

% player settings
noteboxes = 1; % draw boxes around notes, not idea when enablefading = 1
displayfps = 1; % display a frame rate counter in the top right
dohitsound = 1; % play hitsound when a box should be hit
hitsound = 'Wild Eep.wav';
futuretime = [0 4]; % how much of the map to see in advance
timestretch = 2; % how much to stretch the time axis (greater for busier songs)
enablefading = 0; % enable fading in of notes, big performance hit
futurefadetime = [1 3.5]; % if fading is enabled, the range to fade over

%% read in level
[data, Y, Fs] = loadbs('.', levelfile, songfile);

% settings from json
notes = data.x_notes;
bpm = data.x_beatsPerMinute;

% setup music player
player = audioplayer(Y, Fs);

%% open hit sound
if dohitsound == 1
    [eepY,eepFs] = audioread(hitsound);
    eepplayers = cell(1,20);
    % setup multiple players for the sound so that we can play sound effect in
    % rapid succession
    for ii=1:length(eepplayers)
        eepplayers{ii} = audioplayer(eepY, eepFs); %#ok<TNMLP>
    end
end

%% render level
% coordinates for patchs to represent each note
TY = cell(1, 9);
TZ = cell(1, 9);
TX = ones(1,3);
% colors of the blocks
colors = {'r', 'b'};
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

clf
hold on
% array of the times at which all blocks occur
hits = zeros(size(notes));
% array of handles to patch objects
allph(1:length(notes)) = patch;
if noteboxes == 1
    longlineX = nan(1,6*length(notes));
    longlineY = nan(1,6*length(notes));
    longlineZ = nan(1,6*length(notes));
end
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
%             line(ones(1,5)*x, [1 -1 -1 1 1]*0.4+y, [-1 -1 1 1 -1]*0.4+z, 'Color', 'k')
            longlineY((ii-1)*6+1:(ii*6)-1) = [1 -1 -1 1 1]*0.4+y;
            longlineZ((ii-1)*6+1:(ii*6)-1) = [-1 -1 1 1 -1]*0.4+z;
        else % diagonal block
%             line(ones(1,5)*x, [0 1 0 -1 0]*0.566+y, [-1 0 1 0 -1]*0.566+z, 'Color', 'k')
            longlineY((ii-1)*6+1:(ii*6)-1) = [0 1 0 -1 0]*0.566+y;
            longlineZ((ii-1)*6+1:(ii*6)-1) = [-1 0 1 0 -1]*0.566+z;
        end
    end
    
end
if noteboxes == 1
    line(longlineX, longlineY, longlineZ, 'Color', 'k')
end
hold off

% sort all of the hits in order for playing the hitsound
[hits2, k] = sort(hits);
allph = allph(k); % reorder the patch handles for play order
allph = allph(hits2 > 0); % do not count hits at time zero
hits2 = hits2(hits2 > 0);
% we only need to play the sound once
if dohitsound == 1
    hits3 = unique(hits2);
end

% format the plot, setup the axis limits, etc
axis image
grid on
box on

ylim([0.5 4.5])
zlim([0.5 3.5])

set(gca, 'YTick', 0:5)
set(gca, 'ZTick', 0:5)
% the column coordinates are backwards from what we expect, so flip
set(gca, 'YDir', 'reverse')

ylabel('lineIndex');
zlabel('lineLayer');
xlabel('time (seconds)');

% initial view
% view([-45 45])
view([-45 20])
% view([-85 10])

% set tick marks at 1 second intervals for the whole song
xl = xlim;
set(gca, 'XTick', floor(min(xl)):(max(xl)+1))
xlim(futuretime);
% stretch out time
set(gca,'DataAspectRatio',[1/timestretch 1 1])
drawnow

%% play level
timer = tic;

% axis limits for convience
yl = ylim;
zl = zlim;

% create coordinates for a rectangle patch that is the where the player
% stands
X = zeros(1,4);
Y = [yl(1) yl(2) yl(2) yl(1)];
Z = [zl(1) zl(1) zl(2) zl(2)];
tzero = patch(X, Y, Z, 'k');
set(tzero, 'FaceAlpha', 0.2);

if displayfps == 1
    texth = text(1, 1, '0 fps', 'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
end

hat = 1;
if dohitsound == 1
    eepat = 1;
end
time = toc(timer);
play(player)
try
while time < xl(2)
    % move along the plot in time to the song
    xlim(futuretime+time);
    % update the location of the box indicating player position
    set(tzero,'XData',ones(1,4)*time)
    drawnow
    
    % play the hit sounds for any blocks that have passed the player since
    % the last frame
    if dohitsound == 1 && time >= hits3(hat)
        play(eepplayers{eepat})
        hat = hat + 1;
        % rotate through the hit sound players
        eepat = eepat + 1;
        if eepat > length(eepplayers)
            eepat = 1;
        end
    end

    % fade the markers
    if enablefading == 1
        % calculate what the alpha value of the blocks should be for the
        % current time
        alpha = (hits2 - futurefadetime(1) - time)/futurefadetime(2);
        alpha = 1-min([alpha ones(size(alpha))]'); %#ok<UDIM>
        alpha = min([alpha; ones(size(alpha))]);
        % find the blocks that are currently being displayed
        k = (hits2-time) > -0.1 & (hits2-time) < futuretime(2)+time;
        % randomly pick out only some blocks to update the alpha of, this
        % is needed because setting FaceAlpha takes a lot of time
        k(find(k == 1, 1):3:end) = 0;
        % set the face alpha of all note blocks at once
        set(allph(k), {'FaceAlpha'}, num2cell(alpha(k))')
    end
    
    % looping
    lasttime = time;
    time = toc(timer);
    if displayfps == 1
        fps = 1/(time-lasttime);
        texth.String = sprintf('%0.1f fps', fps);
    end
end
catch
    stop(player)
end
