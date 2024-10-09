%% Simulated bead diffusion

% in_struct = param_check(in_struct);
% logentry('All parameters set');
%     numpaths     = in_struct.numpaths;
%     bead_radius  = in_struct.bead_radius;    % [m]
%     frame_rate   = in_struct.frame_rate;     % [frames/sec]
%     duration     = in_struct.duration;       % [sec]
%     field_width  = in_struct.field_width;    % [pixels]
%     field_height = in_struct.field_height;   % [pixels]
%     calib_um     = in_struct.calib_um;       % [um/pixel]
%     scale        = in_struct.scale;          % [scaling factor]
%     intensity    = in_struct.intensity;      % [max intensity of image]
%     background   = in_struct.background;     % [mean intensity, image matrix, or filename]
%     SNR          = in_struct.SNR;
%     seed         = in_struct.seed;           %  #ok<NASGU>
%     viscosity    = in_struct.viscosity;      % [Pa s]
%     tempK        = in_struct.tempK;          % [K]
%     xdrift_vel   = in_struct.xdrift_vel;     % [m/frame]
%     ydrift_vel   = in_struct.ydrift_vel;     % [m/frame]
%     rad_confined = in_struct.rad_confined;   % [m]
%     alpha        = in_struct.alpha;          % slope of loglog(MSD) plot
%     modulus      = in_struct.modulus;        % [Pa]

close all
clear all
clc

RootFolder = uigetdir();
k=input('How many videos would you like?');
k=int16(k);
if isinteger(k) && k<=100 && k>0
    fprintf("Input Accepted")
else
    error("Please input an integer from 1 to 100")
end
ins.numpaths = 100;
ins.bead_radius = 0.1e-6; % This gives a beam diameter of 200nm
ins.frame_rate = 25; %40 ms exposures
ins.duration = 30; % this is what composto does
ins.field_width = 2048;
ins.field_height = 2048;
ins.calib_um = 0.11;
ins.scale = 1;
ins.intensity = 235;
ins.background = 10;
ins.SNR = 10;
ins.viscosity = 0.001;
ins.tempK = 273+23;
ins.xdrift_vel = 0;
ins.ydrift_vel = 0;

grid='y';

for n=1:k
    seednum = randi(100000);
    ins.seed=seednum; 
    DestinationFolder= [RootFolder, '/Seed ', int2str(seednum)];
    mkdir(DestinationFolder)
    cd(DestinationFolder)
    
    video_sim(ins, grid)
    waitbar(n/k, string([string(n), " of ", string(k)]))
end

