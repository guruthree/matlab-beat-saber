function [data, Y, Fs] = loadbs(folder, levelfile, songfile)
    % [data, Y, Fs] = loadbs(folder, levelfile, songfile)
    %
    % load in Beat Saber level levelfile and music songfile from folder
    % folder returning json data music samples Y at samplerate Fs
    
    % assume levelfile and songfile if not set
    if ~exist('levelfile', 'var') || isempty(levelfile)
        levelfile = 'Expert.json';
    end
    if ~exist('songfile', 'var') || isempty(songfile)
        % it seems song files aren't guaranteed to be song.ogg, so search
        % for the first ogg file in the folder and go with that
        list = dir(folder);
        k = cellfun(@(x)~isempty(x), strfind({list(:).name}, 'ogg'));
        songfile = list(find(k == 1, 1)).name;
    end

    %% read in json file
    fid = fopen(sprintf('%s%s%s', folder, filesep, levelfile), 'r');
    contents = '';
    while ~feof(fid)
        contents = sprintf('%s %s', contents, fgetl(fid));
    end
    fclose(fid);
    data = jsondecode(contents);

    %% open song file
    [Y,Fs] = audioread(sprintf('%s%s%s', folder, filesep, songfile));
