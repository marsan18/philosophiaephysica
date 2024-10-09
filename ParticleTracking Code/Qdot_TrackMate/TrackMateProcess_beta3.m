%% TRACKMATE Converter 
% The point of this function is to take the TrackMate files produced by 
% TrackMate Single Particle Tracking Image Analysis
clc
clear all
close all
%% Settings
LockLength=0.2; % Determines localization length in μm
SPACE_UNITS = 'μm';
TIME_UNITS = 'frame';
%% Find Files
% main_folder =    'C:\Users\al3xm\Desktop\SIMULATED_DIFFUSION\CompostoSim\AUTO II 2048x2048\SIMPLE_TRACKS'; 
% main_folder =
% 'C:\Users\al3xm\Documents\_Local_Data\24.09.14_Diffusion_Clippings\Excellent\TOP
% TIER\TRACKMATED'; % FOR NON-SIMPLE IMPORTS
main_folder = uigetdir; % Can use this instead of directory
myFiles = dir(main_folder);





filenames = {myFiles.name};
mask = endsWith(filenames, {'.xml'}, 'IgnoreCase', true);
XML_List = filenames(mask);
num_entries = length(XML_List);
XML_Paths= strings(1,num_entries);
for i=1:num_entries
     XML_Paths(i) = strcat(main_folder, '\', string(XML_List(i)));
end

%% Load in saved .mat paths 

TrajInput = input("Find Simulation Trajectories? Y/N");
if TrajInput=="Y"
    mask = endsWith(filenames, {'.mat'}, 'IgnoreCase', true);
    mat_List = filenames(mask);
    mat_num_entries = length(mat_List);
    mat_Paths= strings(1,mat_num_entries);
    for i=1:mat_num_entries
        mat_Paths(i) = strcat(main_folder, '\', string(mat_List(i)));
    end

SimTraj={};
for i=1:mat_num_entries
    SimTraj{i} = load(mat_Paths(i));
end
end





%% Import simplified .xml data for every entry in the list

MasterTrack = {}; % establish MasterTrack as an empty cell array
for n=1:num_entries
    file_path_tracks = XML_Paths(n);
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

%% Create single trajectory figure

% c = jet(n_tracks);
% for s = 1 : n_tracks
%     x = tracks{s}(:, 2);
%     y = tracks{s}(:, 3);
%     plot(x, y, '.-', 'Color', c(s, :))
% end
MasterTrack = [MasterTrack;tracks]; % concatenates all tracks together
end



%% Create Concatenated Trajectory Figure

% Sort MasterTrack By Length
[~, id] = sort(cellfun(@length,MasterTrack));
MasterTrack=MasterTrack(id);

fig2=figure();
hold on
tot_tracks = numel(MasterTrack);
c = jet(tot_tracks);
for s = 1 : tot_tracks
    x = MasterTrack{s}(:, 2);
    y = MasterTrack{s}(:, 3);
    plot(x, y, '.-', 'Color', c(s, :))
end
axis equal
xlabel( [ 'X (' metadata.spaceUnits ')' ] )
ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
title('All tracks')

%% Filtering
TrackLength = cellfun(@length, MasterTrack);
FilterTrack={};
cuttoff = 7;
for n=1:tot_tracks
    if TrackLength(n)>=cuttoff
        FilterTrack = [FilterTrack;MasterTrack(n)];
    end
end

fig3=figure();
hold on
Fil_tracks = numel(FilterTrack);
c = jet(Fil_tracks);
for s = 1 : Fil_tracks
    x = FilterTrack{s}(:, 2);
    y = FilterTrack{s}(:, 3);
    plot(x, y, '.-', 'Color', c(s, :))
end
axis equal
xlabel( [ 'X (' metadata.spaceUnits ')' ] )
ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
title('Tracks with more than 7 datapoints')
%% Centering 
% Now, to start all move all tracks to start at (0,0). Take FilterTrack and
% center each coordinate by finding where it starts and offseting the
% entire trajectory by that amount.s
FilterTrackLength = cellfun(@length, FilterTrack);
CenterTrack = FilterTrack;
for n=1:Fil_tracks
    X_offset = FilterTrack{n}(1, 2);
    Y_offset = FilterTrack{n}(1, 3);
    CenterTrack{n}(:,2) = CenterTrack{n}(:,2)-X_offset*ones(FilterTrackLength(n),1);
    CenterTrack{n}(:,3) = CenterTrack{n}(:,3)-Y_offset*ones(FilterTrackLength(n),1);
end

fig4=figure();
hold on
Cen_tracks = numel(CenterTrack);
c = jet(Cen_tracks);
for s = 1 : Cen_tracks
    x = CenterTrack{s}(:, 2);
    y = CenterTrack{s}(:, 3);
    plot(x, y, 'Color', c(s, :))
end
axis equal
xlabel( [ 'X (' metadata.spaceUnits ')' ] )
ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
title('Centered tracks')
%% Model Displacement over time
DispTracks={};
MobileTrack = {};
LocalTrack = {};
for n=1:Cen_tracks
   DispTracks{n}(:,1) = CenterTrack{n}(:,1);
   DispTracks{n}(:,2) = ((CenterTrack{n}(:,2)).^2 + (CenterTrack{n}(:,3).^2)).^(0.5);
   DispTrackLength=length(DispTracks{n}(:,2));
   % Mobile or Local
   MobilityTrigger=0;
   for k = 1:DispTrackLength
        if DispTracks{n}(k,2)>=LockLength
            MobilityTrigger=1;
        end
   end
   if MobilityTrigger==1   
        MobileTrack=[MobileTrack; DispTracks{n}];
   else
        LocalTrack = [LocalTrack; DispTracks{n}];
   end
   % Mobility Binning
   MaxMobility(n)=max(DispTracks{n}(:,2));
   FinalDisp(n) = DispTracks{n}(end,2);
end
edges=0:5:50;
DiscreteMaxMobility= discretize(MaxMobility, edges);

fig5=figure();
hold on
Cen_tracks = numel(CenterTrack);
c = jet(Cen_tracks);
for s = 1 : Cen_tracks
    t = DispTracks{s}(:, 1);
    d = DispTracks{s}(:, 2);
    plot(t, d, 'Color', c(s, :))
end

LocalTrackLength=numel(LocalTrack);
MobileTrackLength=numel(MobileTrack);
disp(LocalTrackLength)
disp(MobileTrackLength)

fig6 = figure();
histogram(MaxMobility,edges)
xlabel(['Particle Mobility (' metadata.spaceUnits ')'])
ylabel('Number of Particles')
title('Maximum Mobility of Particles')

fig12=figure()
histogram(FinalDisp, edges)
xlabel(['Particle Mobility (' metadata.spaceUnits ')'])
ylabel('Number of Particles')
title('Final Displacement of Particles')

%% MSD analyzer TRIAL ch1
fig7 = figure();
title('ma.plot tracks')
hold on
ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma = ma.addAll(FilterTrack);
disp(ma)
ma.plotTracks;
ma.labelPlotTracks;
ma = ma.computeMSD;
fig8=figure();
ma.plotMSD;
fig9=figure();
ma.plotMeanMSD(gca,true)
mmsd = ma.getMeanMSD;
t = mmsd(:,1);
x = mmsd(:,2);
dx = mmsd(:,3) ./ sqrt(mmsd(:,4));
errorbar(t, x, dx, 'k')

[fo, gof] = ma.fitMeanMSD;
plot(fo)
ma.labelPlotMSD;
legend off

% Retrieve instantaneous velocities, per track
 trackV = ma.getVelocities;

 % Pool track data together
 TV = vertcat( trackV{:} );

 % Velocities are returned in a N x (nDim+1) array: [ T Vx Vy ...]. So the
 % velocity vector in 2D is:
 V = TV(:, 2:3);

 % Compute diffusion coefficient
varV = var(V);
mVarV = mean(varV); % Take the mean of the two estimates
Dest = mVarV / 2 * 1;


ma = ma.fitMSD;
good_enough_fit = ma.lfit.r2fit > 0.8;
Dmean = mean( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;
Dstd  =  std( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;

fprintf('Estimation of the diffusion coefficient from linear fit of the MSD curves:\n');
fprintf('D = %.3g ± %.3g (mean ± std, N = %d)\n', ...
    Dmean, Dstd, sum(good_enough_fit));


fprintf('Estimation from velocities histogram:\n');
fprintf('D = %.3g %s' ,Dest, [SPACE_UNITS '²/' TIME_UNITS]);
%% Velocity autocorrelation
% how long does particle remember its prior movements?
% should be ~0 for brownian motion, higher for other stuff.
v = ma.getVelocities;
V=vertcat(v{:});

fig8=figure();
hist(V(:,2:end),100)
xlabel([ 'Velocity (' SPACE_UNITS '/' TIME_UNITS ')' ])
ylabel('# of particles')

ma=ma.computeVCorr;
fig9=figure();
ma.plotMeanVCorr
% We get stuff centering about 0, but it increases over time as we have few
% tracks which are 500 frames long so there is much more noise in the
% signal.
bmean = mean( ma.lfit.b(good_enough_fit) );
sigma_locmean = 0.5 * sqrt(bmean);
%% 
% Standard deviation derived by variance composition
sigma_sigma_locmean = 0.5 * std( ma.lfit.b(good_enough_fit) ) / sigma_locmean;

fprintf('Localization error estimated to be s = %.3e ± %.3e (mean ± std, N = %d),\n', ...
    sigma_locmean, sigma_sigma_locmean, sum(good_enough_fit));

% Confined Motions!
% Diffusion occurs with t^a for a=1 for diffusive motion, a<1 for confined
% motions. We can do a log-log fit and find a for each particle.
% Note we can also figure out something about the confinement from this
% process.
ma = ma.fitLogLogMSD(0.5);
mean_alpha= mean(ma.loglogfit.alpha);
if mean_alpha < 0.9
    fprintf('probably confined')
else
    fprintf('probably free')
end

fig11=figure()
scatter(ma.loglogfit.alpha,MaxMobility)
xlabel('timescale factor α')
ylabel('Final Displacement (μm)')



