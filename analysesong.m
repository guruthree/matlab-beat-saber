function [allPxx, F, ptime] = analysesong(Y, Fs)


%     FFTlength = 2048;
%     FFTlength = 4096;
%     FFTlength = 8192;
    FFTlength = 16384;
%     FFToverlap = 1;
%     FFToverlap = 2;
%     FFToverlap = 4;
    FFToverlap = 8;

    numFFTs = floor(length(Y)/FFTlength/FFToverlap)*FFToverlap*FFToverlap;
    ptime = (0:(numFFTs-1))*(FFTlength/FFToverlap)/Fs;
    allPxx = zeros(numFFTs,FFTlength/2+1);

    tic
    fprintf('doing fft... ');
    % take advantage of parallel if it exists, both inner loops should be
    % the same
    if ~exist('parfor', 'builtin')
        for ii=1:numFFTs
            
            FFTindex = (ii-1)*(FFTlength/FFToverlap)+1;
            subY = Y(FFTindex:FFTindex+FFTlength-1,1); % this is the left channel?
            % TODO do both audio channels
            allPxx(ii,:) = pwelch(subY, [], [], FFTlength, Fs);

            if mod(ii,100) == 0
                fprintf('.');
            end
            
        end
    else
        [~, F] = pwelch(1:FFTlength, [], [], FFTlength, Fs); % to get F in case a parfor loop is used
        parfor ii=1:numFFTs
            
            FFTindex = (ii-1)*(FFTlength/FFToverlap)+1;
            subY = Y(FFTindex:FFTindex+FFTlength-1,1); %#ok<PFBNS> % this is the left channel?
            % TODO do both audio channels
            allPxx(ii,:) = pwelch(subY, [], [], FFTlength, Fs);

            if mod(ii,100) == 0
                fprintf('.');
            end
            
        end
    end
    fprintf('done. ');
    toc


% return


%%
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
