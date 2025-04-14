function [outDir, SuperStruct] = MasterSaveD(monkier, dt, ma,...
    main_folder, minTrackLength, SpaceUnits, TimeUnits, VanHoveData, ...
    saveDir)
% This should eventually be converted to a class defintion once all the
% data storage needs are figured out.
    
arguments
        monkier {isstring}
        dt {isscalar}
        ma {isstruct}
        main_folder {isfolder}
        minTrackLength {isscalar}
        SpaceUnits {isstring}
        TimeUnits {isstring}
        VanHoveData {isstruct} = struct()
        saveDir {isfolder}=...
            "C:\Users\al3xm\Documents\GitHub\HISTia\" 
    end

    % UNTITLED Summary of this function goes here
    % Detailed explanation goes here
    SuperStruct.msdanalyzer = ma;
    SuperStruct.source = main_folder;
    SuperStruct.dt = dt;
    SuperStruct.minTrackLength = minTrackLength;
    SuperStruct.TimeUnits = TimeUnits;
    SuperStruct.SpaceUnits = SpaceUnits;
    SuperStruct.VanHoveData = VanHoveData;
    SuperStruct.TimeStamp = ...
        datetime('now','TimeZone','local','Format','yyyy-MM-dd.HH.mm.ss');
    SuperStruct.version=1.1;
    outDir = strcat(saveDir, '\SuperStructs\', monkier);
    
    if isfile(outDir)
        outDir = strcat(outDir, ...
            datetime('now','TimeZone','local','Format','yyyy-MM-dd.HH.mm.ss'));
    end
    outDir = strcat(outDir, '.mat');
    
    save(outDir,'SuperStruct', '-mat')
end

