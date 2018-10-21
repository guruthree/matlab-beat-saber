displayfps = 1; % display a frame rate counter in the top right
dohitsound = 1; % play hitsound when a box should be hit


hitsound = 'Wild Eep.wav';


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

% sort all of the hits in order for playing the hitsound
[hits2, k] = sort(hits);
allph = allph(k); % reorder the patch handles for play order
allph = allph(hits2 > 0); % do not count hits at time zero
hits2 = hits2(hits2 > 0);
% we only need to play the sound once
if dohitsound == 1
    hits3 = unique(hits2);
end

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




% fprintf('playing')
% pause(3)
% fprintf('...\n')
% timer = tic;
% stime = toc(timer);
% tat = 1;
% play(player) % CurrentSample? TimerFcn?
% try
%     while stime < xl(2)
%         xlim(xlimits+stime);
% %         k = find(stime >= stime, 1, 'last');
% %         set(ph, 'XData', stime(k), 'YData', signal(k))
%         set(lh, 'XData', [1 1]*stime)
%         drawnow
% 
%         % looping
%         lasttime = stime;
%         stime = toc(timer);
%         fps = 1/(stime-lasttime);
%     end
% catch
%     stop(player)
% end
