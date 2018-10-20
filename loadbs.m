function [data, Y, Fs] = loadbs(folder, levelfile, songfile)
    

    %% read in json file
    fid = fopen(levelfile, 'r');
    contents = '';
    while ~feof(fid)
        contents = sprintf('%s %s', contents, fgetl(fid));
    end
    fclose(fid);
    data = jsondecode(contents);

    % settings from json
    notes = data.x_notes;
    bpm = data.x_beatsPerMinute;

    %% open song file
    [Y,Fs] = audioread(songfile);
    player = audioplayer(Y, Fs);
