%% TRACKMATE Converter 
% The point of this function is to take the TrackMate files produced by 
% TrackMate Single Particle Tracking Image Analysis
clc
clear all
close all
%% Find Files
main_folder = 'C:\Users\al3xm\Documents\_Local_Data\24.09.14_Diffusion_Clippings\Excellent\TOP TIER\TRACKMATED\Simple_XML_Exports'; 
% main_folder =
% 'C:\Users\al3xm\Documents\_Local_Data\24.09.14_Diffusion_Clippings\Excellent\TOP
% TIER\TRACKMATED'; % FOR NON-SIMPLE IMPORTS
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
%% Import simplified .xml data
    file_path_tracks = XML_Paths(1);
    clipZ=true; % removes z data
    scaleT=false; % uses physical time rather than frame if applicable.
    [tracks, metadata]=importTrackMateTracks(file_path_tracks, clipZ, scaleT);
    n_tracks = numel(tracks);
    fprintf('found %d tracks in the file.\n', n_tracks)
    
     
    % Tracks are stored in cell array of matricies. each matrix is of the form
    % [T, X, Y, Z] and can be access by using the commmand 
    % tracks{DesiredTrack}(DesiredFrame, :)
    % If the track is in 2D, the z-number will be set to 0 unless you enable
    % clipZ
    
    % tracks{1}(5,:)
    % metadata

%% Create a trajectory figure
fig1=figure()
hold on
c = jet(n_tracks);
for s = 1 : n_tracks
    x = tracks{s}(:, 2);
    y = tracks{s}(:, 3);
    plot(x, y, '.-', 'Color', c(s, :))
end
axis equal
xlabel( [ 'X (' metadata.spaceUnits ')' ] )
ylabel( [ 'Y (' metadata.spaceUnits ')' ] )