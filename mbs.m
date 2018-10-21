close all
clear
clc
fig = figure(99);
clf(fig)

%%

levelfolder = '.'; % folder with Expert.json and a .ogg file
currenttime = 0; % start time
timewindow = [-1 9]; % focus for zoomed in plots
hitsound = 'Wild Eep.wav';
displayfps = 1; % display a frame rate counter in the top right

%% setup figure
fig.Color = 'w';
pos = fig.Position;
pos(3) = 1280;
pos(4) = 720;
fig.Position = pos;
fig.Resize = 'off';
fig.ToolBar = 'figure';
fig.MenuBar = 'none';

%% setup axes
ax(1) = axes('Position', [0.05 0.58 0.57 0.4]); % main PSD
ax(2) = axes('Position', [0.67 0.58 0.32 0.19]); % mini PSD
ax(3) = axes('Position', [0.67 0.79 0.32 0.19]); % samples
ax(4) = axes('Position', [0.05 0.07 0.45 0.45]); % 3d level display
drawnow
xlabel(ax(4), 'Time (seconds)')

%% read in level
[data, Y, Fs] = loadbs(levelfolder);

%% psd plot

% TODO cache analysis results
[allPxx, F, ptime] = analysesong(Y, Fs);
handles(1) = displayanalysis(ax(1), allPxx, F, ptime, currenttime);
xlim(ax(1), timewindow+currenttime)
drawnow
handles(2) = displayanalysis(ax(2), allPxx, F, ptime, currenttime);

%% samples plot

[handles(3), stime, samples] = displaysamples(ax(3), Y, Fs, currenttime);
xlim(ax(3), xlim(ax(2)));

disp('done')

%% main plot of level

[handles(4), hits] = displaybs(ax(4), data, currenttime);
xlim(ax(4), timewindow+currenttime)

%% interface controls

buttonwidth = 0.05;
buttonheight = 0.04;
buttons(1) = uicontrol('Style', 'pushbutton', 'String', 'Play All', 'Units', 'normalized', ...
    'Position', [0.4 0.02 buttonwidth buttonheight]);

% TODO stop button
% TODO play selection button

if displayfps == 1
    handles(5) = text(ax(3), 1, 1, '0 fps', 'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
else
    handles(5) = [];
end

%% setup playing

global eepplayers lasttime
lasttime = 0;

if ~isempty(hitsound)
    % open hit sound
    [eepY,eepFs] = audioread(hitsound);
    eepplayers = cell(20,2);
    % setup multiple players for the sound so that we can play sound effect in
    % rapid succession
    for ii=1:length(eepplayers)
        eepplayers{ii,1} = audioplayer(eepY, eepFs); %#ok<TNMLP>
        eepplayers{ii,2} = 0;
    end
    eepplayers{1,2} = 1;
    
    % sort all of the hits in order for playing the hitsound
    hits2 = sort(hits);
    % we only need to play the sound once
    hits2 = unique(hits2(hits2 > 0));
else
    % no hit sounds
    eepplayers = [];
end

% setup music player
player = audioplayer(Y, Fs);
player.TimerPeriod = 1/30; % target 60 fps?
player.TimerFcn = @(object, event_obj)doplay(object, ax, handles, timewindow, stime, samples, hits2);
buttons(1).Callback = @(src, event)play(player);