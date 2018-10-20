clear
clc
fig = figure(99);

%%
fig.Color = 'w';
pos = fig.Position;
pos(3) = 1280;
pos(4) = 720;
fig.Position = pos;
fig.Resize = 'off';
fig.ToolBar = 'figure';
fig.MenuBar = 'none';