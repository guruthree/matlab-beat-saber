%%
% % plot((1:length(Y))/Fs, Y)
% skip = 100;
% Y2 = movmean(Y,skip);
% stime = (1:skip:length(Y))/Fs;
% signal = Y2(1:skip:end,1);
% plot(stime, signal)
% % xlim([0 5])
% % xlim([1 2])
% ylim([-1 1]);
% yl = ylim;
% 
% hold on
% ph = plot(stime(1), signal(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
% lh = line([1 1]*stime(1), yl, 'Color', 'k');
% hold off
% xl = xlim;
% xlimits = [-1 5];
% % xlimits = [-2 10];
% xlim(xlimits)