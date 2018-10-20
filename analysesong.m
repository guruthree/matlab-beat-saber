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

% FFTlength = 2048;
% FFTlength = 4096;
% FFTlength = 8192;
FFTlength = 16384;
% FFToverlap = 1;
% FFToverlap = 2;
% FFToverlap = 4;
FFToverlap = 8;
% numFFTs = floor(length(Y)/(FFTlength/FFToverlap));
numFFTs = floor(length(Y)/FFTlength/FFToverlap)*FFToverlap*FFToverlap;
% window = ones(1,FFTlength);
window = hann(FFTlength);
allPxx = zeros(numFFTs,FFTlength/2+1);

Ymean = mean(Y,2);
tic
fprintf('doing fft... ');
[~, F] = pwelch(1:FFTlength, [], [], FFTlength, Fs); % to get F in case a parfor loop is used
parfor ii=1:numFFTs
    FFTindex = (ii-1)*(FFTlength/FFToverlap)+1;
    subY = Y(FFTindex:FFTindex+FFTlength-1,1); % this is the left channel?
%     [Pxx,F] = periodogram(subY, window, FFTlength, Fs);
%     [Pxx, F] = pwelch(subY, [], [], FFTlength, Fs);
    Pxx = pwelch(subY, [], [], FFTlength, Fs);
    allPxx(ii,:) = Pxx;
%     plot(F, Pxx)
%     xlim([0 1000])
%     ylim([0 1e-2])
%     drawnow
    if mod(ii,100) == 0
        fprintf('.');
    end
end
fprintf('done. ');
toc

%%
% ylog = 0;
Ylog = 1;

logbase = 32;
mylog = @(x)log(x)/log(logbase);

clf
drawnow
stime = (1:numFFTs)*(FFTlength/FFToverlap)/Fs;
if ylog == 0
    pcolor(stime, F, log10(allPxx'))
    ylim([0 1000])
%     ylim([0 8000])
%     ylim([0 16000])
%     ylim([0 FFTlength/2])
else
    pcolor(stime, mylog(F), log10(allPxx'))
    ylim(mylog([32 8192]))
end
shading flat

cb = colorbar();
caxis([-10 -2])

xlabel('Time (seconds)')
ylabel('Frequency (Hz)')
ylabel(cb, 'signal (dB)') % maybe?
drawnow

if ylog == 1
    yts = get(gca, 'YTick');
    lab = cellfun(@(x)sprintf('%.0f', x), num2cell(logbase.^yts), 'UniformOutput', 0);
    set(gca, 'YTickLabel', lab);
end

% bin the frequencies like a graphic equaliser? according to notes?
% f = round(2^((p-69)/12)*440) 

% return
%%
yl = ylim;
hold on
lh = line([1 1]*stime(1), yl, 'Color', 'w');
hold off
xl = xlim;
% xlimits = xl;
xlimits = [-1 20];
xlim(xlimits)


% return
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

%%
fprintf('playing')
pause(3)
fprintf('...\n')
timer = tic;
stime = toc(timer);
tat = 1;
play(player) % CurrentSample? TimerFcn?
try
    while stime < xl(2)
        xlim(xlimits+stime);
%         k = find(stime >= stime, 1, 'last');
%         set(ph, 'XData', stime(k), 'YData', signal(k))
        set(lh, 'XData', [1 1]*stime)
        drawnow

        % looping
        lasttime = stime;
        stime = toc(timer);
        fps = 1/(stime-lasttime);
    end
catch
    stop(player)
end
