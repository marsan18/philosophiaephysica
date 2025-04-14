%% TRACKMATE Converter 
% The point of this function is to take the TrackMate files produced by 
% TrackMate Single Particle Tracking Image Analysis
% If this code fails to run because of unknown functions, make sure you use
% the command addpath(genpath('{yourdirectory}') otherwise the subfolders
% won't be in the directory and it won't run.
clc
clear all
close all

%% Settings
LocLength=0.2; % Determines localization length in μm
SPACE_UNITS = 'μm';
TIME_UNITS = 'frame';
%% Find Files
main_folder ='C:\Users\al3xm\Documents\_Local_Data\CONSOLIDATED_DIFFUSION_CLIPPINGS\24.09.14_Diffusion_Clippings\Excellent\TOP TIER\TRACKMATED\Simple_XML_Exports';
% main_folder = uigetdir; % Can use this instead of directory
FigFolder= strcat(main_folder, '\analysisfigures\',string(datetime('today')));
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

%% Load in saved .mat paths 

% TrajInput = string(input("Find Simulation Trajectories? Y/N"));
TrajInput="N"; % Hard cuttoff for this. Figure out later.
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
    MasterTrack = [MasterTrack;tracks]; %#ok<AGROW> % concatenates all tracks together
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
        FilterTrack = [FilterTrack;MasterTrack(n)]; %#ok<AGROW>
    end
end

fig3=figure();
hold on
Num_FilterTrack = numel(FilterTrack);
FilterLength= cellfun(@length, FilterTrack);
c = jet(Num_FilterTrack);
for s = 1 : Num_FilterTrack
    x = FilterTrack{s}(:, 2);
    y = FilterTrack{s}(:, 3);
    plot(x, y, '.-', 'Color', c(s, :))
end
axis equal
xlabel( [ 'X (' metadata.spaceUnits ')' ] )
ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
title('Filtered tracks')
%% Centering 
% Now, to start all move all tracks to start at (0,0). Take FilterTrack and
% center each coordinate by finding where it starts and offseting the
% entire trajectory by that amount.s
FilterTrackLength = cellfun(@length, FilterTrack);
CenterTrack = FilterTrack;
for n=1:Num_FilterTrack
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
        if DispTracks{n}(k,2)>=LocLength
            MobilityTrigger=1;
        end
   end
   if MobilityTrigger==1   
        MobileTrack=[MobileTrack; DispTracks{n}]; %#ok<AGROW>
   else
        LocalTrack = [LocalTrack; DispTracks{n}]; %#ok<AGROW>
   end
   % Mobility Binning
   MaxMobility(n)=max(DispTracks{n}(:,2)); %#ok<SAGROW>
   FinalDisp(n) = DispTracks{n}(end,2); %#ok<SAGROW>
end
edges=0:0.5:max(MaxMobility);
DiscreteMaxMobility= discretize(MaxMobility, edges);
MobileParticles = sum(MaxMobility>0.2);
TotalParticles = length(FilterLength);
fig5=figure();
hold on
Cen_tracks = numel(CenterTrack);
c = jet(Cen_tracks);
for s = 1 : Cen_tracks
    t = DispTracks{s}(:, 1);
    d = DispTracks{s}(:, 2);
    plot(t, d, 'Color', c(s, :))
end
xscale log
yscale log

LocalTrackLength=numel(LocalTrack);
MobileTrackLength=numel(MobileTrack);
disp(LocalTrackLength)
disp(MobileTrackLength)

fig6 = figure();
histogram(MaxMobility,edges)
xlabel(['Particle Mobility (' metadata.spaceUnits ')'])
ylabel('Number of Particles')
title('Maximum Mobility of Particles')

fig7=figure();
histogram(FinalDisp, edges)
xlabel(['Particle Mobility (' metadata.spaceUnits ')'])
ylabel('Number of Particles')
title('Final Displacement of Particles')

%% MSD analyzer TRIAL ch1
fig8 = figure();
title('ma.plot tracks')
hold on
ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma = ma.addAll(FilterTrack);
disp(ma)
ma.plotTracks;
ma.labelPlotTracks;

ma = ma.computeMSD;
  % Results are stored in the msd field of this object as a cell
  % array, one cell per particle. The array is a double array of size
  % N x 4, and is arranged as follow: [dt mean std N ; ...] where dt
  % is the delay for the MSD, mean is the mean MSD value for this
  % delay, std the standard deviation and N the number of points in
  % the average.





% Composto
fig9=figure();
ma.plotMSD;
title('plot of mean squared displacement')
yscale("log")
xscale("log")

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
fig11=figure();
edges2 = -1.5:0.01:1.5;
histogram(V(:,2),edges2)
xlabel([ 'X Velocity (' SPACE_UNITS '/' TIME_UNITS ')' ])
ylabel('# of particles')
title('velocity of particles')

fig1=figure();
histogram(speed(:,2), edges2)
xlabel([ 'Speed (' SPACE_UNITS '/' TIME_UNITS ')' ])
ylabel('# of particles')
title('velocity of particles')


ma=ma.computeVCorr;
fig12=figure();
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
mean_alpha= mean(ma.loglogfit.alpha); %#ok<NOPTS>
display(mean_alpha)
if mean_alpha < 0.9
    fprintf('probably confined')
else
    fprintf('probably free')
end
fprintf('\n')

fig13=figure();
scatter(ma.loglogfit.alpha,MaxMobility)
xlabel('timescale factor α')
ylabel('Final Displacement (μm)')
title('alpha distribution')

fig14=figure();
scatter(ma.loglogfit.alpha,FilterLength)
xlabel('timescale factor α')
ylabel('Track Length (frames)')
title('alpha distribution over frame length')
yscale('log')

fig15 = figure();
scatter(FinalDisp, FilterLength)
ylabel('Number of Frames Detected')
xlabel('maximum mobility (μm)')
title('Frames Detected vs mobility')
yscale('log')


title('Localized or Mobile')

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
str = { [ '\alpha = ' sprintf('%.2f ± %.2f (mean ± std, N = %d)', mean(alphas), std(alphas), numel(alphas)) ] };

if htest
    str{2} = sprintf('Significantly below 1, with p = %.2g', pval);
else
    str{2} = sprintf('Not significantly differend from 1, with p = %.2g', pval);
end

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

%% Van Hove plots


% plot probability of each step size.

VanHove={};
time_steps=1:20;

for i=time_steps 
% create a cell struct with one cell for each tau value
% Make sure this is outside loop or it will erase the VanHove matrix with 
% each iteration
 VanHove{i}=[];
end
VHTrack = FilterTrack;
for track=1:length(VHTrack) 
    % Moves through every track in VHTracks
    for tau = time_steps 
        % Change this to change number of frames for each distribution.
        BackStop=length(VHTrack{track})-tau;
        if BackStop > 1 && tau<length(VHTrack{track})
            % This condition works to avoid indexing errors which result
            % when tau is bigger than the number of particles in the track
            for t=1:BackStop 
                % This rosters through each position in the track 
                for dt=1:tau 
                    % accomodates frame skips--checks frame step values
                    % from 1 up to tau to see if Δt=τ
                    if VHTrack{track}(t+dt,1) - VHTrack{track}(t,1) == tau 
                       % if the Δt is tau...
                       Dx = VHTrack{track}(t+dt,2)- VHTrack{track}(t,2); % write dΧ
                       Dy = VHTrack{track}(t+dt,3) - VHTrack{track}(t,3); % write dY
                       VanHove{tau}=vertcat(VanHove{tau},[Dx,Dy,track,t]); % records ΔΧ, ΔY, tracj number, AND start frame number
                       % Considering we have track and frame, all steps are
                       % fully tracable
                    end
                end
            end
        end
        % fprintf('for τ=%d ',tau)
        % fprintf('found %d steps for in the file.\n', length(VHTrack{frame}))
    end
end
fprintf("VanHove calculation took")
toc

% Now we need to change from steps into Probabilities


%% Logarithmic sorting
edgesPos=[-Inf,-3:0.1:log(2)];
edgesNeg=-flip(edgesPos);
% column 1 is x, column 2 is y, column 3 indicates if we should keep row
for var=1:2
    for tau=1:length(VanHove)
        for k=1:length(VanHove{tau})
            if VanHove{tau}(k,var)>0
                % should convert imaginary numbers resulting from log(negatives) to real negative numbers
                PosLogVanHove{tau}(k,var)=reallog(VanHove{tau}(k,var));
                PosLogVanHove{tau}(k,3)=1; % keep
                NegLogVanHove{tau}(k,var)=0;
                NegLogVanHove{tau}(k,3)=0; % throw out
            else
                % record negative log value, throw out postive log value
                NegLogVanHove{tau}(k,var)=-reallog(-VanHove{tau}(k,var));
                NegLogVanHove{tau}(k,3)=1; % keep
                PosLogVanHove{tau}(k,var)=0;
                PosLogVanHove{tau}(k,3)=0; % throw out
            end
        end
        FilterPosLogVanHove{tau}=[];
        FilterNegLogVanHove{tau}=[];
        for j=1:length(VanHove{tau})
            if NegLogVanHove{tau}(j,3)==0 && PosLogVanHove{tau}(j,3)==1
                FilterPosLogVanHove{tau}=vertcat(FilterPosLogVanHove{tau},PosLogVanHove{tau}(j,1));
            else
                FilterNegLogVanHove{tau}=vertcat(FilterNegLogVanHove{tau},NegLogVanHove{tau}(j,1));
            end

           
        end
        NegPVanHove{tau}(:,var) = histcounts( FilterNegLogVanHove{tau},edgesNeg)/length(VanHove{tau});
        PosPVanHove{tau}(:,var) = histcounts(FilterPosLogVanHove{tau},edgesPos)/length(VanHove{tau});
        PVanHove{tau}(:,var)=vertcat(NegPVanHove{tau}(:,var), PosPVanHove{tau}(:,var));
     end
end
%% Equal bin sorting 

%% Plotting
fig18 = figure();
domain=[-exp(-edgesNeg), exp(edgesPos)];
centers = zeros((length(domain)-2),1);
for k=1:(length(edgesPos)-1)
    centers(k)=mean([domain(k),domain(k+1)]);
    centers(end-k+1)=mean([domain(end-k+1), domain(end-k)]);
end
centers=centers*1000;
title("Van Hove Distribution")
ylabel("P(ΔX)")
xlabel("ΔΧ [nm]")
hold on
for tau=[1,10]
    scatter(centers, PVanHove{tau}(:,1))
end
yscale('log')

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
