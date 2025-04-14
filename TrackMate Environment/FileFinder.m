function paths = FileFinder(main_folder, extensions)
% Find Files in the given folder with the desired extensions
% output the paths of the files
    arguments
        main_folder {isfolder} = uigetdir()
        extensions={'.tiff', '.tiff'};
    end
    
    myFiles = dir(main_folder);
    filenames = {myFiles.name};
    mask = endsWith(filenames, extensions, 'IgnoreCase', true);
    FileList = filenames(mask);
    num_entries = length(FileList);
    
    paths = strings(1,num_entries);
    
    for i=1:num_entries
         paths(i) = strcat(main_folder, '\', string(FileList(i)));
    end
end
