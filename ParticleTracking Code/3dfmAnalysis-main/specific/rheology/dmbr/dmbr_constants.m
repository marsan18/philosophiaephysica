
% 3DFM Analysis
% Magnetics/dmbr
% last modified 08/01/06
%  
% script that creates column constants for dmbr raw data matrix, of which   
% the raw data is the varforce data matrix and is derived from this and the
% video tracking data obtained from load_video_tracking.  It makes sense to
% keep the same 2D tabular matrix and add additional columns for pulse
% voltage (VOLTS), sequence identification (SEQ), and zero-volt translation
% data taken *after* a degauss routine (DEGAUSS).
%

    % the column headings should initially be the same as video tracking
    % since we want all of that information in addition to the new
    % columns/labels.
    video_tracking_constants;
    
    % new columns/labels.
    VOLTS  = 17;
    SEQ    = 18;
    DEGAUSS= 19;
    
    FORCE  = 20;
    FERR_H = 21;
    FERR_L = 22;
    
    % Creep Compliance at time points
    J      = 23;        

    % Scale space zeroth derivative (smoothed displacments)
    SX     = 24;
    SY     = 25;
    SJ     = 26;
    
    % Scale space first derivative (unsmoothed velocity)
    DX     = 27;
    DY     = 28;
    DJ     = 29;

    % Scale space first derivative (smoothed velocity/viscosity)
    SDX    = 30;
    SDY    = 31;
    SDJ    = 32;
    
    
