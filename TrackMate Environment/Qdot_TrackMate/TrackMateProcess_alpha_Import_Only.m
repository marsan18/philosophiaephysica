%% TRACKMATE Converter 
% The point of this function is to take the TrackMate files produced by 
% TrackMate Single Particle Tracking Image Analysis

%FOLDER SELECTION
main_folder = 'C:\Users\al3xm\Documents\_Local_Data\24.09.14_Diffusion_Clippings\Excellent\TOP TIER\TRACKMATED\\Simple_XML_Exports'; 
% main_folder = uigetdir; % Can use this instead of directory
myFiles = dir(main_folder);


filenames = {myFiles.name};
mask = endsWith(filenames, {'.xml'}, 'IgnoreCase', true);
XML_List = filenames(mask);
num_entries = length(XML_List);

XML_Paths = strings(1,num_entries);

for i=1:num_entries
     XML_Paths(i) = strcat(main_folder, '\', string(XML_List(i)));
end

file_path_tracks = XML_Paths(1);
tracks=importTrackMateTracks(file_path_tracks);
n_tracks = numel(tracks);
fprintf('found %d tracks in the file.\n', n_tracks)


