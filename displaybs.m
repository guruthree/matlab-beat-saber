% needs boxes around symbols
% diagonals are wrong

% level settings
levelfile = 'Expert.json';
songfile = 'song.ogg';

% player settings
hitsound = 'Wild Eep.wav';
futuretime = [0 4]; % how much of the map to see in advance
enablefading = 0; % enable fading in of notes, big performance hit
futurefadetime = [1 3.5]; % if fading is enabled, the range to fade over

clear

fid = fopen(levelfile', 'r');

contents = '';
while ~feof(fid)
    contents = sprintf('%s %s', contents, fgetl(fid));
end

fclose(fid);

data = jsondecode(contents);

[Y,Fs] = audioread(songfile);

player = audioplayer(Y, Fs);
% play(player)

[eepY,eepFs] = audioread(hitsound);
eepplayers = cell(1,20);
for ii=1:length(eepplayers)
    eepplayers{ii} = audioplayer(eepY, eepFs); %#ok<TNMLP>
end

notes = data.x_notes;
bpm = data.x_beatsPerMinute;

%%

dirs = {'^', 'v', '<', '>', 'x', 'x', 'x', 'x', 'o'};
colors = {'r', 'b'};
TX = ones(1,3);
TYo = [0 6 3]-3;
TZo = [0 0 4.8]-4.8/2;
TYo = TYo*0.1;
TZo = TZo*0.1;

angles = [0 180 90 270 315 45 135 225];

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

r = 0.2;
ang = 0:(pi/4):2*pi;
cang = cos(ang);
sang = sin(ang);
xp=cang'*r;
yp=sang'*r;
TY{end}=xp;
TZ{end}=yp;

% return

clf
hold on
hits = zeros(size(notes));
allph = cell(size(notes));
for ii=1:length(notes)
    
    x = notes(ii).x_time/bpm*60;
    hits(ii) = x;
    y = notes(ii).x_lineIndex + 1;
    z = notes(ii).x_lineLayer + 1;
    c = colors{notes(ii).x_type+1};
%     d = dirs{notes(ii).x_cutDirection+1};
    d = notes(ii).x_cutDirection+1;
    
%     allph{ii} = scatter3(x, y, z, d, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', c);%, 'MarkerSize', 20);
%     allph{ii}.SizeData = 800;
    allph{ii} = patch(ones(size(TY{d}))*x, TY{d}+y, TZ{d}+z, c);
    allph{ii}.FaceAlpha = 0.5;
    
end
hold off 

[hits2, k] = sort(hits);
allph = allph(k);
hits3 = unique(hits2);

axis image
grid on
% xlim([0 5])
% xlim([5 30])
% xlim([30 60])

ylim([0.5 4.5])
zlim([0.5 3.5])

set(gca, 'YTick', 0:5)
set(gca, 'ZTick', 0:5)
set(gca, 'YDir', 'reverse')

box on

ylabel('lineIndex');
zlabel('lineLayer');
xlabel('time (seconds)');

% view([-45 45])
view([-45 20])
% view([-85 10])

xl = xlim;
set(gca, 'XTick', floor(min(xl)):(max(xl)+1))
xlim(futuretime);
set(gca,'DataAspectRatio',[0.5 1 1])
drawnow

%%
% for ii=1:1%length(allph)
%     x = allph{ii}.XData;
% %     c = [allph{ii}.Color 0.5];
%     m = allph{ii}.MarkerHandle.get;
%     c = m.FaceColorData;
%     c(4) = 127;
% %     allph{ii}.Color = c;
%     m.FaceColorData = c;
%         m.FaceColorData 
% end
% drawnow

%%
timer = tic;
pos = 0;

yl = ylim;
zl = zlim;
X = zeros(1,4);
Y = [yl(1) yl(2) yl(2) yl(1)];
Z = [zl(1) zl(1) zl(2) zl(2)];
tzero = patch(X, Y, Z, 'k');
set(tzero, 'FaceAlpha', 0.2);
set(gcf,'Renderer','painters')

hat = 1;
eepat = 1;
time = toc(timer);
play(player)
while time < xl(2)
    xlim(futuretime+time);
    set(tzero,'XData',ones(1,4)*time)
    drawnow
    
    if time >= hits3(hat)
        play(eepplayers{eepat})
        hat = hat + 1;
        eepat = eepat + 1;
        if eepat > length(eepplayers)
            eepat = 1;
        end
    end

    % fade the markers
    if enablefading == 1
        alpha = (hits2 - futurefadetime(1) - time)/futurefadetime(2);
        alpha = 1-min([alpha ones(size(alpha))]'); %#ok<UDIM>
        alpha = min([alpha; ones(size(alpha))]);
        k = (hits2-time) > -0.1 & (hits2-time) < futuretime(2)+time;
        k(find(k == 1, 1):3:end) = 0;
        cellfun(@(x,y)set(x, 'FaceAlpha', y), allph(k), num2cell(alpha(k))')
        for ii=1:length(hits)
            if hits(ii) - futurefadetime(1) - time <= 0
                allph{ii}.FaceAlpha = 1;
            elseif hits(ii) - futurefadetime(2) - time > 0
                allph{ii}.FaceAlpha = 0.2;
            end
                
            set(allph{ii}, 'FaceAlpha', alpha(ii))
        end
    end
    lasttime = time;
    time = toc(timer);
%     1/(time-lasttime)
end


%%


clear player eepplayers
