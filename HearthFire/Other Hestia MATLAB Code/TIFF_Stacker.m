%% TIFF STACKER
% The idea here is to stack all tiffs in each folder inidicated
% Folder must only contain the images you want.
% There should be nothing in your source folder except for folders with
% images in them!
% Ok this was a huge waste of time! Moving on then...
%% Find Files
clc
clear 'all'
close 'all'


MainFolder = uigetdir(); 
cd(MainFolder)
subs=input("Should I search subfolders? Answer with string. [Y/N]");
if subs=="Y"
   % folder_indicator=input("What do the folders names? Input a struct.");
   % this not currently in use--designed to include only folders with
   % certain words in thier name.
   masterDir = dir(MainFolder);
   myFolders= masterDir([masterDir(:).isdir]) ;
   myFolderNames = {myFolders(3:end).name};
   disp(myFolderNames)
   CheckIn = input("Are these subfolders correct? Answer with string. [Y/N]");
    if CheckIn=="Y"
    else 
        error("User did not continue.")
    end
    FolderListLength = numel(myFolderNames);
else
    FolderListLength=1;
end
%% Search and Save
% Find .tiff files in each of the list of subfolders.
% Read each .tiff file into a layer of a 3-D matrix.
% Save each 3-D structure as a multistacked .tiff file with the name of the
% folder it came from.
for n=1:FolderListLength
    folder=[MainFolder,'\',myFolderNames{n}];
    myFiles = dir(folder);
    extensions={'.tiff', '.tif'};
    
    filenames = {myFiles.name};
    mask = endsWith(filenames, extensions, 'IgnoreCase', true);
    FileList = filenames(mask);
    num_entries = length(FileList);
    
    paths = strings(1,num_entries); % preallocate
    
    for i=1:num_entries
         paths(i) = strcat(folder, '\', string(FileList(i)));
    end

    % Preallocation
    ImSamp=imread(paths(1));
    % Data type
    Stack = zeros(size(ImSamp,1), size(ImSamp,2),num_entries, 'uint8');

    % Image Stack Creation
    for i=1:num_entries
        Stack(:,:,i)=imread(paths(i));
    end
    % TiffName = [myFolderNames{n}, '.tiff'];
    % TiffStack=Tiff(t, 'w');
    %     setTag(t,"Photometric",Tiff.Photometric.MinIsBlack)
    %     setTag(t,"Compression",Tiff.Compression.None)
    %     setTag(t,"BitsPerSample",8)
    %     setTag(t,"SamplesPerPixel",4)
    %     setTag(t,"SampleFormat",Tiff.SampleFormat.UInt)
    %     setTag(t,"ExtraSamples",Tiff.ExtraSamples.Unspecified)
    %     setTag(t,"ImageLength",size(ImSamp,1))
    %     setTag(t,"ImageWidth",size(ImSamp,2))
    %     % setTag(t,"TileLength",32)
    %     % setTag(t,"TileWidth",32)
    %     % setTag(t,"PlanarConfiguration",Tiff.PlanarConfiguration.Chunky)
    waitbar(n/FolderListLength, string([string(n), " of ", string(FolderListLength)]))

    % Saving the Image Stack
    StackName=[MainFolder,'\',myFolderNames{n}, '.tiff'];
    imwrite(Stack, StackName)
    write(TiffStack,Stack)
    close(TiffStack)
end

