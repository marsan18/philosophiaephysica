function d = rod_msd(files, window, frame_rate, calib_um)
% ROD_MSD plots the graph of mean square displacement versus tau for an aggregate number of rod trackers 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
% This function computes the mean-square displacements (via 
% the Stokes-Einstein relation) for an aggregate number of rod trackers.
%  
%  [d] = msd;
%  [d] = msd(files, calib_um, window);
%   
%  where "files" is the filename containing video tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%
%  
% Notes: - No arguments will run a 2D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - assumption: rod diffusion is a 2-dimensional process
%

if (nargin < 4) | isempty(calib_um) calib_um = 0.152; end;
if (nargin < 3) | isempty(frame_rate) frame_rate = []; end;
if (nargin < 2) | isempty(window) window = [1 2 5 10 20 50 100 200 500 1000 1001];  end
if (nargin < 1) | isempty(files)  files = '*.mat'; end

% load in the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;

% load video data
v = load_video_tracking(files, frame_rate, 'm', calib_um, 'relative', 'yes', 'matrix');

% for every bead
for beadID = 0 : get_beadmax(v);
    
    b = get_bead(v, beadID);    
    framemax = max(b(:,FRAME));

    % for every window size (or tau)
    for w = 1:length(window)
        
        %  for all frames
        A1 = b(1:end-window(w),X);
        A2 = b(1:end-window(w),Y);
        A3 = b(1:end-window(w),Z);
        AYAW = b(1:end-window(w),YAW) * pi/180;
        
        B1 = b(window(w)+1:end,X);
        B2 = b(window(w)+1:end,Y);
        B3 = b(window(w)+1:end,Z);
        BYAW = b(window(w)+1:end,YAW) * pi/180;
        
        S  = sqrt( ( B1 - A1 ).^2 + ( B2 - A2 ).^2 ) ;
         
        alpha = atan2( (B2-A2) , (B1 - A1) );
        theta = AYAW;
        phi = 90 - theta - alpha;
                
        msd_parallel = (S .* sin(phi)).^2;
        msd_normal = (S .* cos(phi)).^2;
        msd_radial = (BYAW - AYAW).^2;         
 
        msd_p(w, beadID+1) = nanmean(msd_parallel');
        msd_n(w, beadID+1) = nanmean(msd_normal');
        msd_r(w, beadID+1) = nanmean(msd_radial');
        
        tau(w, beadID+1) = window(w) * mean(diff(b(:,TIME)));
         
        D_p = (msd_p(w, beadID+1)) / (2*tau(w, beadID+1));
        D_n = (msd_n(w, beadID+1)) / (2*tau(w, beadID+1));
        D_r = (msd_r(w, beadID+1)) / (4*tau(w, beadID+1));
        
        
    end   
end

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd_p = log10(msd_p);
logmsd_n = log10(msd_n);
logmsd_r = log10(msd_r);

mean_logtau = nanmean(logtau');
mean_logmsd_p = nanmean(logmsd_p');
mean_logmsd_n = nanmean(logmsd_n');
mean_logmsd_r = nanmean(logmsd_r');

Ntrackers = sum(~isnan(logmsd_p),2);

ste_logtau   = nanstd(logtau')  ./ sqrt(Ntrackers');
ste_logmsd_p = nanstd(logmsd_p') ./ sqrt(Ntrackers');
ste_logmsd_n = nanstd(logmsd_n') ./ sqrt(Ntrackers');
ste_logmsd_r = nanstd(logmsd_r') ./ sqrt(Ntrackers');

	figure;
	errorbar(repmat(mean_logtau',1,3), [mean_logmsd_p' mean_logmsd_n' mean_logmsd_r'], ...
                          [ste_logmsd_p' ste_logmsd_n' ste_logmsd_r']);
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;

dlmwrite('file.msd.txt', [mean_logtau(:), mean_logmsd_p(:), mean_logmsd_n(:), mean_logmsd_r(:), ste_logmsd_p(:), ste_logmsd_n(:), ste_logmsd_r(:)], '\t');    

% outputs
d.tau = tau;
d.msd_p = msd_p;
d.msd_n = msd_n;
d.msd_r = msd_r;
d.D_p = D_p;
d.D_n = D_n;
d.D_r = D_r;
d.Ntrackers = Ntrackers; % because beadID's are indexed by 0.


