function [ma] = TrackMateImport(main_folder, MSD_only, Particle_thresh, scaling, LOCAL_PARTICLES_ONLY, MOBILE_PARTICLES_ONLY, LocLength, save_opt)
arguments 
    main_folder string {mustBeFolder} = [] % Defaults to uigetdir()
    MSD_only logical = true % Determines if should compute everything or just the MSD. FALSE PATH CURRENTLY DEPRECIATED!
    Particle_thresh double {mustBePositive} = 7 % Defualt Composto setting
    scaling double {isscalar} = -1
    LOCAL_PARTICLES_ONLY logical  = false 
    MOBILE_PARTICLES_ONLY logical = false
    LocLength double {mustBePositive} = 0.2 % Default to Composto setting
    save_opt logical = true % by default, saves the generated ma into the source folder.   
end
%% TRACKMATE Converter 
% The point of this function is to take the TrackMate files produced by 
% TrackMate Single Particle Tracking Image Analysis
% If this code fails to run because of unknown functions, make sure you use
% the command addpath(genpath('{yourdirectory}') otherwise the subfolders
% won't be in the directory and it won't run.
% When starting matlab, run 
% addpath(genpath('C:\Users\al3xm\Documents\GitHub\HISTia\TrackMate Environment'))
% clc
% clear all
% close all
if isempty(main_folder)
    main_folder = uigetdir();
end

%% Settings
% LocLength=0.2; % Determines localization length in μm
% SPACE_UNITS = 'm';
% TIME_UNITS = 's';
% main_folder = 'C:\Users\al3xm\Documents\_Local_Data\24.08.26_PSF_troubleshooting\10k_dilution_100nm_YG_in_water_on_APTES_between_two_coverslips\tLapse_LSFM_100ms_50steps_4_2_SM2_1\Snipped Version\XML_500nm_for_localization_error';

%% Find Filesmain_folder ='C:\Users\al3xm\Documents\_Local_Data\24.10.23_Qdot_controls\24.10.23_2_1-5000_200nmYG_fluospheres_water_diffusion\Static\all_xmls';

FigFolder= strcat(main_folder, '\analysisfigures\',string(datetime('today'))) ;
if LOCAL_PARTICLES_ONLY
    FigFolder = strcat(FigFolder, '_LOCAL_PARTICLES_ONLY');
elseif MOBILE_PARTICLES_ONLY
    FigFolder = [FigFolder, '_MOBILE_PARTICLES_ONLY'];
end

UniqueFolder = false;
k=0;
while ~UniqueFolder
    NewFigFolder = strcat(FigFolder, '_', string(k));
    if ~isfolder(NewFigFolder) | k>100 % to avoid absurd numbers of folders
        mkdir(NewFigFolder);
        FigFolder=NewFigFolder;
        UniqueFolder=true;
        break
    else
        k=k+1;  
    end
end

mkdir(FigFolder);
myFiles = dir(main_folder);

filenames = {myFiles.name};
mask = endsWith(filenames, {'.xml'}, 'IgnoreCase', true);
XML_List = filenames(mask);
num_entries = length(XML_List);
XML_Paths= strings(1,num_entries);

for i=1:num_entries
     XML_Paths(i) = strcat(main_folder, '\', string(XML_List(i)));
end
if isempty(XML_Paths)
    error('Please ensure that the directory contains .xml files!')
end

% %% Load in saved .mat paths 
% 
% % TrajInput = string(input("Find Simulation Trajectories? Y/N"));
% TrajInput="N"; % Hard cuttoff for this. Figure out later.
% if TrajInput=="Y"
%     mask = endsWith(filenames, {'.mat'}, 'IgnoreCase', true);
%     mat_List = filenames(mask);
%     mat_num_entries = length(mat_List);
%     mat_Paths= strings(1,mat_num_entries);
%     for i=1:mat_num_entries
%         mat_Paths(i) = strcat(main_folder, '\', string(mat_List(i)));
%     end
% 
% SimTraj={};
% for i=1:mat_num_entries
%     SimTraj{i} = load(mat_Paths(i));
% end
% end





%% Import simplified .xml data for every entry in the list
n_tracks = zeros(num_entries, 1); % preallocate
MasterTrack = {}; % establish MasterTrack as an empty cell array
for n=1:num_entries
    file_path_tracks = XML_Paths(n);
    clipZ=true; % removes z data
    scaleT=false; % uses physical time rather than frame if applicable.
    [tracks, metadata]=importTrackMateTracks(file_path_tracks, clipZ, scaleT);
    % Note tracks just temporarily holds the input data.
    SPACE_UNITS = metadata.spaceUnits;
    TIME_UNITS = metadata.timeUnits;
    n_tracks(n) = numel(tracks);
    fprintf('found %d tracks in the file.\n', n_tracks(n))
    MasterTrack = [MasterTrack;tracks]; %#ok<AGROW> % concatenates all tracks together
end
fprintf('found a total of %d tracks in the directory\n', sum(n_tracks(n)))
% Change the x and y entries for each track by Scaling factor to move from
% pixels to the desired physical units.
if scaling ~= -1
    warning('Scaling factor active!')
    for k = 1:numel(MasterTrack)
        MasterTrack{k}(:, 2:3) = MasterTrack{k}(:, 2:3) .* scaling;
    end
end

%% Create Concatenated Trajectory Figure

% Sort MasterTrack By Length
[~, id] = sort(cellfun(@length,MasterTrack));
MasterTrack=MasterTrack(id);


%% Filtering
TrackLength = cellfun(@length, MasterTrack);
TrackDiff= cellfun(@diff, MasterTrack, 'UniformOutput',false);
FilterTrack={};
tot_tracks = numel(MasterTrack);
for n=1:tot_tracks
    if TrackLength(n)>=Particle_thresh
        FilterTrack = [FilterTrack;MasterTrack(n)]; %#ok<AGROW>
    end
end

%% Centering 
% Now, to start all move all tracks to start at (0,0). Take FilterTrack and
% center each coordinate by finding where it starts and offseting the
% entire trajectory by that amount.s
FilterTrackLength = cellfun(@length, FilterTrack);
CenterTrack = FilterTrack;
% Num_FilterTrack = numel(FilterTrack);
FilterLength= cellfun(@length, FilterTrack);





if LOCAL_PARTICLES_ONLY
    FilterTrack=LocalFilterTrack;
    warning('plotting only tracks longer than threshold length')
    warning('plotting only tracks which move <loc_length')
elseif MOBILE_PARTICLES_ONLY
    FilterTrack=MobileFilterTrack;
    warning('plotting only tracks longer than threshold length')
    warning('plotting only tracks which move >loc_length')
else
    warning('plotting only tracks longer than threshold length')
end

% [CenterTrack, CenterTrackMaximaSorted] = CreateCenterTracks(FilterTrack);


ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma = ma.addAll(FilterTrack);
ma = ma.computeMSD;
%% Supplemental Code
% I reccommend using CenterTracks and other designated functions as
% necessary instead of using the following code, but I am leaving it in
% place for legacy purposes
    if not(MSD_only) % cuts out most stuff to improve speed if MSD_only is true.
      % Model Displacement over time
        for n=1:numel(FilterTrack)
            X_offset = FilterTrack{n}(1, 2);
            Y_offset = FilterTrack{n}(1, 3);
            CenterTrack{n}(:,2) = CenterTrack{n}(:,2)-X_offset*ones(FilterTrackLength(n),1);
            CenterTrack{n}(:,3) = CenterTrack{n}(:,3)-Y_offset*ones(FilterTrackLength(n),1);
        end
    DispTracks={};
    MobileTrack = {};
    MobileFilterTrack={};
    LocalFilterTrack = {};
    LocalTrack = {};
    MaxMobility=[];
    for n=1:numel(CenterTrack)
       DispTracks{n}(:,1) = CenterTrack{n}(:,1);
       DispTracks{n}(:,2) = ((CenterTrack{n}(:,2)).^2 + (CenterTrack{n}(:,3).^2)).^(0.5);
       DispTrackLength=length(DispTracks{n}(:,2));
       % Mobile or Local
       MobilityTrigger=0;
       for k = 1:DispTrackLength
            if DispTracks{n}(k,2)>=LocLength
                MobilityTrigger=1;
            end
       end
       if MobilityTrigger==1   
            MobileTrack=[MobileTrack; DispTracks{n}]; %#ok<AGROW>
            MobileFilterTrack=[MobileFilterTrack;FilterTrack{n}]; %#ok<AGROW>
       else
            LocalTrack = [LocalTrack; DispTracks{n}]; %#ok<AGROW>
            LocalFilterTrack=[LocalFilterTrack;FilterTrack{n}]; %#ok<AGROW>
       end
       % Mobility Binning
       MaxMobility(n)=max(DispTracks{n}(:,2)); %#ok<SAGROW>
       FinalDisp(n) = DispTracks{n}(end,2); %#ok<SAGROW>
    end
    %edges=0:MaxMobility/50:max(MaxMobility);
    %DiscreteMaxMobility= discretize(MaxMobility, edges);
    MobileParticles = sum(MaxMobility>LocLength);
    TotalParticles = length(FilterLength);
    
    
    LocalTrackLength=numel(LocalTrack);
    MobileTrackLength=numel(MobileTrack);
    disp(LocalTrackLength)
    disp(MobileTrackLength)
    
    
        
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
        for n=1:length(V)
            speed(n,1)=V(n,1);
            speed(n,2)=sqrt((V(n,2)^2+V(n,3)^2));
        end
        
        
        
        
        
        ma=ma.computeVCorr;
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
        mean_alpha= mean(ma.loglogfit.alpha, 'omitnan'); %#ok<NOPTS>
        display(mean_alpha)
        if mean_alpha < 0.9
            fprintf('probably confined')
        else
            fprintf('probably free')
        end
        fprintf('\n')
        
        
        
        
        
        r2fits = ma.loglogfit.r2fit;
        alphas = ma.loglogfit.alpha;
        
        R2LIMIT = 0;
        
        % Remove bad fits
        bad_fits = r2fits < R2LIMIT;
        fprintf('Keeping %d fits (R2 > %.2f).\n', sum(~bad_fits), R2LIMIT);
        alphas(bad_fits) = [];
        
        % T-test
        [htest, pval] = ttest(alphas, 1, 0.05, 'left');
        
        % if ~htest
        %     [htest, pval] = ttest(alphas, 1, 0.05);
        % end
        % 
        % % Prepare string
        % str = { [ '\alpha = ' sprintf('%.2f ± %.2f (mean ± std, N = %d)', mean(alphas, 'omitnan'), std(alphas, 'omitnan'), numel(alphas, 'omitnan')) ] };
        % 
        % if htest
        %     str{2} = sprintf('Significantly below 1, with p = %.2g', pval);
        % else
        %     str{2} = sprintf('Not significantly differend from 1, with p = %.2g', pval);
        % end
    
      
    end
end