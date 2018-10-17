% needs boxes around symbols
% diagonals are wrong
% catch ctrl-c and stop music
% enable fps display

clear

% level settings
levelfile = 'Expert.json';
songfile = 'song.ogg';

% player settings
dohitsound = 1;
hitsound = 'Wild Eep.wav';
futuretime = [0 4]; % how much of the map to see in advance
enablefading = 0; % enable fading in of notes, big performance hit
futurefadetime = [1 3.5]; % if fading is enabled, the range to fade over

%% read in json file
fid = fopen(levelfile, 'r');
contents = '';
while ~feof(fid)
    contents = sprintf('%s %s', contents, fgetl(fid));
end
fclose(fid);
data = jsondecode(contents);

% settings from json
notes = data.x_notes;
bpm = data.x_beatsPerMinute;

%% open song file
[Y,Fs] = audioread(songfile);
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
dirs = {'^', 'v', '<', '>', 'x', 'x', 'x', 'x', 'o'};
colors = {'r', 'b'};
TX = ones(1,3);
% coordinates to draw a triangle poly
TYo = ([0 6 3]-3)*0.1;
TZo = ([0 0 4.8]-4.8/2)*0.1;

% the angles at which blocks are rotated
angles = [0 180 90 270 315 45 135 225];

% rotate the triangle coordinates appropriately
TY = cell(size(dirs));
TZ = cell(size(dirs));
for ii=1:length(angles)
    theta = angles(ii);
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    point = [TYo; TZo];
    point = R*point;
    TY{ii} = point(1,:);
    TZ{ii} = point(2,:);
end

% create a circle for the circle blocks
ang = 0:(pi/4):2*pi;
cang = cos(ang);
sang = sin(ang);
xp=cang'*0.2;
yp=sang'*0.2;
TY{end}=xp;
TZ{end}=yp;

clf
hold on
hits = zeros(size(notes));
allph = cell(size(notes));
% loop through all notes in the json and draw them at the appriate
% coordiantes
for ii=1:length(notes)

    % convert the note position to time in seconds
    x = notes(ii).x_time/bpm*60;
    hits(ii) = x;
    y = notes(ii).x_lineIndex + 1;
    z = notes(ii).x_lineLayer + 1;
    c = colors{notes(ii).x_type+1};
    d = notes(ii).x_cutDirection+1;
    
    allph{ii} = patch(ones(size(TY{d}))*x, TY{d}+y, TZ{d}+z, c);
    allph{ii}.FaceAlpha = 0.5;
    
end
hold off 

% sort all of the hits in order for playing the hitsound
[hits2, k] = sort(hits);
allph = allph(k); % reorder the patch handles for play order
% we only need to play the sound once
if dohitsound == 1
    hits3 = unique(hits2);
end

axis image
grid on
box on

ylim([0.5 4.5])
zlim([0.5 3.5])

set(gca, 'YTick', 0:5)
set(gca, 'ZTick', 0:5)
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
set(gca,'DataAspectRatio',[0.5 1 1])
drawnow

%% play level
timer = tic;
pos = 0;

yl = ylim;
zl = zlim;

% create coordinates for a rectangle patch that is the where the player
% stands
X = zeros(1,4);
Y = [yl(1) yl(2) yl(2) yl(1)];
Z = [zl(1) zl(1) zl(2) zl(2)];
tzero = patch(X, Y, Z, 'k');
set(tzero, 'FaceAlpha', 0.2);

hat = 1;
if dohitsound == 1
    eepat = 1;
end
time = toc(timer);
play(player)
while time < xl(2)
    xlim(futuretime+time);
    set(tzero,'XData',ones(1,4)*time)
    drawnow
    
    if dohitsound == 1 && time >= hits3(hat)
        play(eepplayers{eepat})
        hat = hat + 1;
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
        cellfun(@(x,y)set(x, 'FaceAlpha', y), allph(k), num2cell(alpha(k))');
    end
    
    % looping
    lasttime = time;
    time = toc(timer);
%     1/(time-lasttime)
end

%% clean up
clear player eepplayers
