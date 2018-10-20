clear
clc
fig = figure(99);
clf
%%

levelfolder = '.'; % folder with Expert.json and a .ogg file

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
ax(2) = axes('Position', [0.66 0.58 0.32 0.18]); % mini PSD
ax(3) = axes('Position', [0.66 0.80 0.32 0.18], 'XTickLabel', []); % samples
ax(4) = axes('Position', [0.05 0.07 0.45 0.45], 'YTickLabel', [], 'ZTickLabel', []); % 3d level display

for ii=1:2
    xlabel(ax(ii), 'Time (seconds)')
    ylabel(ax(ii), 'Frequency (Hz)')
end
ylabel(ax(3), 'Sample Level [-]')
xlabel(ax(4), 'Time (seconds)')

%% read in level
[data, Y, Fs] = loadbs(levelfolder);
