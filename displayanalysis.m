function displayanalysis(ax)

%%
% ylog = 0;
Ylog = 1;

logbase = 32;
mylog = @(x)log(x)/log(logbase);

clf
drawnow
ptime = (1:numFFTs)*(FFTlength/FFToverlap)/Fs;
if ylog == 0
    pcolor(ptime, F, log10(allPxx'))
    ylim([0 1000])
%     ylim([0 8000])
%     ylim([0 16000])
%     ylim([0 FFTlength/2])
else
    pcolor(ptime, mylog(F), log10(allPxx'))
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
lh = line([1 1]*ptime(1), yl, 'Color', 'w');
hold off
xl = xlim;
% xlimits = xl;
xlimits = [-1 20];
xlim(xlimits)

