clear


windowsize = 1; % in secods
songfile = 'song.ogg';
[Y,Fs] = audioread(songfile);
player = audioplayer(Y, Fs);

%%
% samplesPerWindow = windowsize * Fs;
% 
% Pxx = zeros(Fs,32769);
% for ii=1:Fs
%     Pxx(ii,:) = periodogram(Y(ii:ii+Fs-1,1));
% end
% for ii=1:10:1000; plot(Pxx(ii,1:500)); disp(ii), pause(0.1); end

%%
% plot((1:length(Y))/Fs, Y)
skip = 100;
Y2 = movmean(Y,skip);
stime = (1:skip:length(Y))/Fs;
signal = Y2(1:skip:end,1);
plot(stime, signal)
% xlim([0 5])
% xlim([1 2])
ylim([-1 1]);
yl = ylim;

hold on
ph = plot(stime(1), signal(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
lh = line([1 1]*stime(1), yl, 'Color', 'k');
hold off
xl = xlim;
xlimits = [-1 5];
% xlimits = [-2 10];
xlim(xlimits)

%%
timer = tic;
time = toc(timer);
tat = 1;
play(player)
try
    while time < xl(2)
        xlim(xlimits+time);
        k = find(time >= stime, 1, 'last');
        set(ph, 'XData', stime(k), 'YData', signal(k))
        set(lh, 'XData', [1 1]*time)
        drawnow

        % looping
        lasttime = time;
        time = toc(timer);
        fps = 1/(time-lasttime);
    end
catch
    stop(player)
end
