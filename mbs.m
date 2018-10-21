close all
clear
clc
fig = figure(99);
clf(fig)

%%

levelfolder = '.'; % folder with Expert.json and a .ogg file
currenttime = 0; % start time
timewindow = [-1 9]; % focus for zoomed in plots

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

handles(4) = displaybs(ax(4), data, currenttime);
xlim(ax(4), timewindow+currenttime)
