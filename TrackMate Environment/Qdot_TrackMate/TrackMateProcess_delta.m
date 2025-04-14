%% TRACKMATE Converter 
% The point of this function is to take the TrackMate files produced by 
% TrackMate Single Particle Tracking Image Analysis
% If this code fails to run because of unknown functions, make sure you use
% the command addpath(genpath('{yourdirectory}') otherwise the subfolders
% won't be in the directory and it won't run.

% When starting matlab, run 
% addpath(genpath('C:\Users\al3xm\Documents\GitHub\HISTia\TrackMate Environment'))
clc
clear all
% close all

%% Settings
LOCAL_PARTICLES_ONLY = false;
MOBILE_PARTICLES_ONLY = false;
LocLength=0.2; % Determines localization length in μm
SPACE_UNITS = 'μm';
TIME_UNITS = '20ms frame';
main_folder = 'C:\Users\al3xm\Documents\_Local_Data\_CONSOLIDATED_DIFFUSION_CLIPPINGS\24.09.14_Diffusion_Clippings\Excellent\TOP TIER\Trackmating with Standard Settings\SimpleXMLs';

CenTrackThreshold=75;
% Can use this instead of directory
% main_folder = uigetdir; 

% VanHove Settings
% BinSize determines how many datapoints go in each bin
% InputTracks determines the tracking file that it analyzes
% TimeSteps determines the tau values we test and plot. Less is more.
BinSize=1000;
TimeSteps=[1,5,10];
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

% Create file name masks
filenames = {myFiles.name};
filemask = endsWith(filenames, {'.xml'}, 'IgnoreCase', true);
XML_List = filenames(filemask);
num_entries = length(XML_List);
XML_Paths= strings(1,num_entries);

for i=1:num_entries
     XML_Paths(i) = strcat(main_folder, '\', string(XML_List(i)));
end

%% Load in saved .mat paths 

% TrajInput = string(input("Find Simulation Trajectories? Y/N"));
TrajInput="N"; % Hard cuttoff for this. Figure out later.
if TrajInput=="Y"
    filemask = endsWith(filenames, {'.mat'}, 'IgnoreCase', true);
    mat_List = filenames(filemask);
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
    MasterTrack = [MasterTrack;tracks]; %#ok<AGROW> % concatenates all tracks together
end



%% Create Concatenated Trajectory Figure

% Sort MasterTrack By Length
[~, id] = sort(cellfun(@length,MasterTrack));
MasterTrack=MasterTrack(id);


%% Filtering
TrackLength = cellfun(@length, MasterTrack);
TrackDiff= cellfun(@diff, MasterTrack, 'UniformOutput',false);
FilterTrack={};
cuttoff = 7;
tot_tracks = numel(MasterTrack);
for n=1:tot_tracks
    if TrackLength(n)>=cuttoff
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
for n=1:numel(FilterTrack)
    X_offset = FilterTrack{n}(1, 2);
    Y_offset = FilterTrack{n}(1, 3);
    CenterTrack{n}(:,2) = CenterTrack{n}(:,2)-X_offset*ones(FilterTrackLength(n),1);
    CenterTrack{n}(:,3) = CenterTrack{n}(:,3)-Y_offset*ones(FilterTrackLength(n),1);
end


%% Model Displacement over time
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
edges=0:MaxMobility/50:max(MaxMobility);
DiscreteMaxMobility= discretize(MaxMobility, edges);
MobileParticles = sum(MaxMobility>LocLength);
TotalParticles = length(FilterLength);


LocalTrackLength=numel(LocalTrack);
MobileTrackLength=numel(MobileTrack);
disp(LocalTrackLength)
disp(MobileTrackLength)

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

[CenterTrack, CenterTrackMaximaSorted] = CreateCenterTracks(FilterTrack);


ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma = ma.addAll(FilterTrack);

  % Results are stored in the msd field of this object as a cell
  % array, one cell per particle. The array is a double array of size
  % N x 4, and is arranged as follow: [dt mean std N ; ...] where dt
  % is the delay for the MSD, mean is the mean MSD value for this
  % delay, std the standard deviation and N the number of points in
  % the average.





% Composto


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

ma = ma.computeMSD;

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

if ~htest
    [htest, pval] = ttest(alphas, 1, 0.05);
end

% Prepare string
str = { [ '\alpha = ' sprintf('%.2f ± %.2f (mean ± std, N = %d)', mean(alphas, 'omitnan'), std(alphas, 'omitnan'), numel(alphas, 'omitnan')) ] };

if htest
    str{2} = sprintf('Significantly below 1, with p = %.2g', pval);
else
    str{2} = sprintf('Not significantly differend from 1, with p = %.2g', pval);
end






%% Plotting
% Takes a row vector of ones and zeros which toggles Figure plotting
FigureKey=[0,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1,1,0,0];


% FigurePlotter [FigureKey]= function(FigureKey)
FigureKey=boolean(FigureKey);

if FigureKey(1,1)
    fig1=figure();
    histogram(speed(:,2), edges2) % This is broken!
    xlabel([ 'Speed (' SPACE_UNITS '/' TIME_UNITS ')' ])
    ylabel('# of particles')
    title('velocity of particles')
end
if FigureKey(1,2)
    fig2=figure();
    hold on
    
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
end

if FigureKey(1,3)
    fig3=figure();
    hold on

    c = jet(numel(FilterTrack));
    for s = 1 : numel(FilterTrack)
        x = FilterTrack{s}(:, 2);
        y = FilterTrack{s}(:, 3);
        plot(x, y, '.-', 'Color', c(s, :))
    end
    axis equal
    xlabel( [ 'X (' metadata.spaceUnits ')' ] )
    ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
    title('Filtered tracks')
end




if FigureKey(1,4)
    fig4=figure();
    hold on
    c = jet(numel(CenterTrack));
    for k=1:numel(CenterTrack)
        if length(CenterTrack{k})>CenTrackThreshold
            x = CenterTrack{k}(:, 2);
            y = CenterTrack{k}(:, 3);
            plot(x, y, 'Color', c(k, :))
        end
    end
    axis equal
    xlabel( [ 'X (' metadata.spaceUnits ')' ] )
    ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
    title('Centered tracks')
end

% Strange displacement plot, probably not useful.
if FigureKey(1,5)
    fig5=figure();
    hold on

    c = jet(numel(CenterTrack));
    for s = 1 : numel(CenterTrack)
        t = DispTracks{s}(:, 1);
        d = DispTracks{s}(:, 2);
        plot(t, d, 'Color', c(s, :))
    end
    xscale log
    yscale log
end
if FigureKey(1,6)
    fig6 = figure();
    histogram(MaxMobility,edges)
    xlabel(['Particle Mobility (' metadata.spaceUnits ')'])
    ylabel('Number of Particles')
    title('Maximum Mobility of Particles')
end

if FigureKey(1,7)
    fig7=figure();
    histogram(FinalDisp, edges)
    xlabel(['Particle Mobility (' metadata.spaceUnits ')'])
    ylabel('Number of Particles')
    title('Final Displacement of Particles')
end
if FigureKey(1,8)
    fig8 = figure();
    title('ma.plot tracks')
    hold on
    disp(ma)
    ma.plotTracks;
    ma.labelPlotTracks;
end

if FigureKey(1,9)
    fig9=figure();
    ma.plotMSD;
    title('plot of mean squared displacement')
    yscale("log")
    xscale("log")
end

if FigureKey(1,10)
    fig10=figure();
    ma.plotMeanMSD(gca,true)
    mmsd = ma.getMeanMSD;
    t = mmsd(:,1);
    x = mmsd(:,2);
    dx = mmsd(:,3) ./ sqrt(mmsd(:,4));
    % errorbar(t, x, dx, 'k')
    title('plotmeanMSD')
    [fo, gof] = ma.fitMeanMSD;
    plot(fo)
    ma.labelPlotMSD;
    legend off
    xscale('log')
    yscale('log')
end

if FigureKey(1,11)
    fig11=figure();
    edges2 = -1.5:0.01:1.5;
    histogram(V(:,2),edges2)
    xlabel([ 'X Velocity (' SPACE_UNITS '/' TIME_UNITS ')' ])
    ylabel('# of particles')
    title('velocity of particles')
end

if FigureKey(1,12)
    fig12=figure();
    ma.plotMeanVCorr
end





% if FigureKey(1,13)
%     fig13=figure();
%     scatter(ma.loglogfit.alpha,MaxMobility)
%     xlabel('timescale factor α')
%     ylabel('Final Displacement (μm)')
%     title('alpha distribution')
% end

% if FigureKey(1,14)
%     fig14=figure();
%     scatter(ma.loglogfit.alpha,FilterLength)
%     xlabel('timescale factor α')
%     ylabel('Track Length (frames)')
%     title('alpha distribution over frame length')
%     yscale('log')
% end


% if FigureKey(1,15)
%     fig15 = figure();
%     scatter(FinalDisp, FilterLength)
%     ylabel('Number of Frames Detected')
%     xlabel('maximum mobility (μm)')
%     title('Frames Detected vs mobility')
%     yscale('log')
%     title('Localized or Mobile')
% end


if FigureKey(1,16)
    fig16 = figure();
    hist(alphas);
    box off
    xlabel('\alpha')
    ylabel('#')
    
    yl = ylim(gca);
    xl = xlim(gca);
    text(xl(2), yl(2)+2, str, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 16)
    title('\alpha values distribution', ...
        'FontSize', 20)
    ylim([0 yl(2)+2])
end

if FigureKey(1,17) 
    fig17=figure();
    % Plots the Localization Histogram figure from Composto
    msd_length=length(ma.msd);
    LocalizationList=zeros(1,msd_length);
    % This pulls the MSD from frame tau
    tau1=3;
    for k=1:msd_length
        LocalizationList(1,k) = ma.msd{k}(tau1,2); % In microns
    end
    histogram(log(LocalizationList*1000),30); % Plot in nm
    title("Localization Histogram")
    ylabel("count")
    xlabel(strcat('[log(MSD(τ=', string(tau1), ')),nm^2]'))
end

% Many, many issues with this figure!
if FigureKey(1,18)
    fig18 = figure();
    domain=[-exp(-edgesNeg), exp(edgesPos)];
    centers = zeros((length(domain)-2),1);
    for k=1:(length(edgesPos)-1)
        centers(k)=mean([domain(k),domain(k+1)], 'omitnan');
        centers(end-k+1)=mean([domain(end-k+1), domain(end-k)], 'omitnan');
    end
    centers=centers*1000;
    title("Logarithmic Van Hove Distribution")
    ylabel("P(ΔX)")
    xlabel("ΔΧ [nm]")

hold on
for tau=time_steps
    scatter(centers, PVanHove{tau}(:,1),"filled")
end
yscale('log')
legend('dt=100ms', 'dt=1000ms')
end

if FigureKey(1,19)
    fig19=figure();
    hold on
    for tau=time_steps
        scatter(1000.*CenterPoint{tau}, EquiProb{tau},"filled")
        % Gfit{tau}=fit([1000*CenterPoint{1}]', equiProb{1}(:,1), 'gauss4')
        % plot(Gfit{tau})
    end
    yscale('log')
    legend('dt=50ms', 'dt=100 ms', 'dt=250ms', 'dt=500ms')
    title("Equal Bin Van Hove Distribution")
    ylabel("P(ΔX)")
    xlabel("ΔΧ [nm]")
end



%% VAN HOVE PLOTS
VanHoveData = CreateVanHovePlots(FilterTrack,BinSize, TimeSteps, main_folder);
% BinSize determines how many datapoints go in each bin
% InputTracks determines the tracking file that it analyzes
% TimeSteps determines the tau values we test and plot. Less is more.


FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = num2str(get(FigHandle, 'Number'));
  set(0, 'CurrentFigure', FigHandle);
  savefig(fullfile(FigFolder, [FigName '.fig']));
  saveas(FigHandle, fullfile(FigFolder, [FigName '.tif']));
end



display(MobileParticles)
display(TotalParticles)


%% Old VanHove Data which is no longer in use
% The new method is much faster, and more reliable
% The old method oftentimes creates NaN data for values at or very near to
% zero, which skews the probability.

% %% Van Hove plots
% 
% 
% % plot probability of each step size.
% 
% VanHove={};
% time_steps=[1,5,10];
% if max(time_steps)>= length(FilterTrack{end})
%     error('Please select a set of timesteps for the Van Hove Plot which are less than the length of the longest path.')
% end
% 
% for i=time_steps 
%     % create a cell struct with one cell for each tau value
% % Make sure this is outside loop or it will erase the VanHove matrix with 
% % each iteration
%  VanHove{i}=[]; %zeros(length(MobileTrack{end},4)); %preallocates VanHove to be as large as biggest MobileTrack dataset
% end
% VHTrack=FilterTrack;
% for track=1:length(VHTrack)
%     fprintf('Assembling VanHove')
%     display(track)
%     % Moves through every track in VHTracks
%     for tau = time_steps 
%         % Change this to change number of frames for each distribution.
%         BackStop=length(VHTrack{track})-tau;
%         if BackStop > 1 && tau<length(VHTrack{track})
%             % This condition works to avoid indexing errors which result
%             % when tau is bigger than the number of particles in the track
%             for t=1:BackStop 
%                 % This rosters through each position in the track 
%                 for dt=1:tau 
%                     % accomodates frame skips--checks frame step values
%                     % from 1 up to tau to see if Δt=τ
%                     if VHTrack{track}(t+dt,1) - VHTrack{track}(t,1) == tau 
%                        % if the Δt is tau...
%                        Dx = VHTrack{track}(t+dt,2)- VHTrack{track}(t,2); % write dΧ
%                        Dy = VHTrack{track}(t+dt,3) - VHTrack{track}(t,3); % write dY
%                        VanHove{tau}=vertcat(VanHove{tau},[Dx,Dy,track,t]); % records ΔΧ, ΔY, tracj number, AND start frame number
%                        % Considering we have track and frame, all steps are
%                        % fully tracable
%                     end
%                 end
%             end
%         end
%         % fprintf('for τ=%d ',tau)
%         % fprintf('found %d steps for in the file.\n', length(VHTrack{frame}))
%     end
% end
% 
% % Trim VanHove after Preallocation!
% % Trim zeroes off end of VanHove
%     % 
%     % for tau=time_steps
%     % for i=length(VanHove{tau})
%     %     if sum(VanHove{Tau}(i,:))==0
%     %        VanHove{tau}(i:end,:)=[]
%     %        break
%     %     end
%     % end
%     % end
% 
% % Now we need to change from steps into Probabilities
% 
% 
% %% Logarithmic sorting
% edgesPos=[-Inf,-5.5,-5, -4.5, -4,-3.5:0.1:log(2)];
% edgesNeg=-flip(edgesPos);
% % column 1 is x, column 2 is y, column 3 indicates if we should keep row
% for var=1
%     for tau=time_steps
%         fprintf('Log Sorting')
%         display(tau)
%         for k=1:length(VanHove{tau})
%             if VanHove{tau}(k,var)>0
%                 % should convert imaginary numbers resulting from log(negatives) to real negative numbers
%                 PosLogVanHove{tau}(k,var)=reallog(VanHove{tau}(k,var));
%                 PosLogVanHove{tau}(k,3)=1; % keep
%                 NegLogVanHove{tau}(k,var)=0;
%                 NegLogVanHove{tau}(k,3)=0; % throw out
%             else
%                 % record negative log value, throw out postive log value
%                 NegLogVanHove{tau}(k,var)=-reallog(-VanHove{tau}(k,var));
%                 NegLogVanHove{tau}(k,3)=1; % keep
%                 PosLogVanHove{tau}(k,var)=0;
%                 PosLogVanHove{tau}(k,3)=0; % throw out
%             end
%         end
%         FilterPosLogVanHove{tau}=[];
%         FilterNegLogVanHove{tau}=[];
%         for j=1:length(VanHove{tau})
%             if NegLogVanHove{tau}(j,3)==0 && PosLogVanHove{tau}(j,3)==1
%                 FilterPosLogVanHove{tau}=vertcat(FilterPosLogVanHove{tau},PosLogVanHove{tau}(j,1));
%             else
%                 FilterNegLogVanHove{tau}=vertcat(FilterNegLogVanHove{tau},NegLogVanHove{tau}(j,1));
%             end
% 
% 
%         end
%         NegPVanHove{tau}(:,var) = histcounts( FilterNegLogVanHove{tau},edgesNeg)/length(VanHove{tau});
%         PosPVanHove{tau}(:,var) = histcounts(FilterPosLogVanHove{tau},edgesPos)/length(VanHove{tau});
%         PVanHove{tau}(:,var)=vertcat(NegPVanHove{tau}(:,var), PosPVanHove{tau}(:,var));
%      end
% end
% %% Equal bin sorting 
% % Logarithmic sorting doesn't seem amazing...so let's do equal bin sorting.
% VHBinSize=50; %VHBinSize Sets number of particles per division
% % there is a strange rounding error that causes many bins to get rounded to
% % (0,0) which causes a huge probability spike at that point. This is due to
% % that fact that many, many points actually have probability 0 and they all
% % get stuck into a single bin during sorting.
% % Note HISTCOUNTS pushes stuff on the boundary UP!
% var=1; % select x or y
% SortedVanHove=VanHove; % Preallocation
% EquiDomain=zeros(length(VanHove),1);
% CountCheck={};
% for tau=time_steps
%     fprintf('Sorting into bins')
%     display(tau)
%     SortedVanHove{tau}(:,var) = sort(VanHove{tau}(:,var));
%     % floor(length(SortedVanHove{tau})/divs)
%     EquiDomain(tau,1)=SortedVanHove{tau}(end,var)-SortedVanHove{tau}(1,var);
%     EquiBins{tau}=[1,SortedVanHove{tau}(1,var)];
%     % CatEnd=[];
%     div_number=0;
%     N_particles{tau}=length(SortedVanHove{tau});
%     for k=1:N_particles{tau}
%         if mod(k,VHBinSize)==0
%             % addEnd=[k,SortedVanHove{tau}(k,1)];
%             % CatEnd(k)=[CatEnd;addEnd];
%             div_number=div_number+1;       
%             addStart=[k,SortedVanHove{tau}(k,1)]; %k+1 or k? I think k.
%             EquiBins{tau}=[EquiBins{tau};addStart];  
%             OldIndex=EquiBins{tau}(end-1,1);
%             if OldIndex>1
%                 % Because
%                 OldIndex=OldIndex+1;
%             end
%             NewIndex=EquiBins{tau}(end,1);
%             CenterPointSimple{tau}(div_number)=[mean(SortedVanHove{tau}(OldIndex:NewIndex,1))]';
%             % geometric mean of points that should be in the bin!
%         end
%     end
%     % add final bin ranging from upper regulation bin to end of the line
%     div_number=div_number+1;
%     addStart=[N_particles{tau},SortedVanHove{tau}(end,1)];
%     EquiBins{tau}=[EquiBins{tau};addStart];
%     % EquiBins{tau} is finalized now
%     % NOTE: CenterPoint should be the geometric mean of points in the bin! 
% 
%     % CenterPoint approximation!!
%     % CenterPoint{tau}(div_number)=mean([EquiBins{tau}(end,2),EquiBins{tau}(end-1,2)]);
% 
%     EquiWidth{tau}=diff(EquiBins{tau}(:,2)); %In microns
% 
%     probability_units(tau,1)=1/EquiDomain(tau,1); % Normalized Probability/micron
% 
%     [CountCheck{tau}, ~, Binz{tau}]=histcounts(SortedVanHove{tau}(:,var),EquiBins{tau}(:,2));
%     CountCheck{tau}=[CountCheck{tau}]'; % Transforms from row to column vector for easier use
%     % Particles
% 
%     if not(sum(CountCheck{tau}) == N_particles{tau})
%         error('VanHove Particle Sorting Error')
%     end
% 
%     % Sometimes bins are a bit off--end up with target +/- 1 in a bin. This
%     % occurs due to them having the exact same localization. Happens most
%     % frequently at 0.
%     EquiProb{tau}=CountCheck{tau}./EquiWidth{tau};
%     EquiProb{tau}=EquiProb{tau}.*(1/sum(EquiProb{tau}, 'omitnan'));
%     PastBin=1;
%     coords=[];
%     for k=1:length(Binz{tau})
%         CurrentBin = Binz{tau}(k,1);
%         if PastBin==CurrentBin 
%             % If our Bin remains the same and we are not on the last tick
%             % add current particle to our list of particles in the bin.
%            coords=[coords,k];
%            if k==length(Binz{tau})
%                % Conditionally takes mean of final bin positions
%                CenterPoint{tau}(PastBin)=mean(SortedVanHove{tau}(coords,1));
%            end
%         else
%             % If it does not, we take the average of all the particle 
%             % positions in our current bin and reset the list of particles 
%             % in our new bin.
%             CenterPoint{tau}(PastBin)=mean(SortedVanHove{tau}(coords,1));
%             coords=k;
%         end
%         PastBin=CurrentBin;
%     end
% end

