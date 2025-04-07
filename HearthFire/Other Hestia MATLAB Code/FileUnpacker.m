function newPathList = FileUnpacker(mainFolder)
    arguments
        mainFolder {isfolder} = uigetdir()
    end
    % FileUnpacker moves all files from subfolders into the main folder
    % and removes empty subfolders after the operation.
    
    % Validate that the provided folder exists
    if ~isfolder(mainFolder)
        error('The specified folder does not exist.');
    end
    
    % Retrieve all files from subdirectories recursively
    files = dir(fullfile(mainFolder, '**', '*')); 
    files = files(~[files.isdir]); % Exclude directories
    
    newPathList = {};
    % Move each file to the main folder
    for i = 1:length(files)
        oldPath = fullfile(files(i).folder, files(i).name);
        newPath = fullfile(mainFolder, files(i).name);
        
        % Rename file if a conflict exists
        if exist(newPath, 'file')
            [~, name, ext] = fileparts(files(i).name);
            counter = 1;
            while exist(newPath, 'file')
                newPath = fullfile(mainFolder, sprintf('%s_%d%s', name, counter, ext));
                counter = counter + 1;
            end
        end
        
        % Move the file to the main directory
        movefile(oldPath, newPath);
        newPathList{i} = newPath;
    end
    
    % Identify and remove empty subfolders
    subfolders = dir(mainFolder);
    subfolders = subfolders([subfolders.isdir] & ~ismember({subfolders.name}, {'.', '..'}));
    for i = 1:length(subfolders)
        rmdir(fullfile(mainFolder, subfolders(i).name), 's');
    end
    
    % Display completion message
    fprintf('All files have been moved to %s, and empty subfolders have been removed.\n', mainFolder);
end

