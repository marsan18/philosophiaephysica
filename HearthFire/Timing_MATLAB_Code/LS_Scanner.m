function [CSV] = LS_Scanner(X_start, X_increment, X_end, filepath)
%% ETL Callibration File
% The main idea behind this file is to iteratively move through ETL and
% sterring mirror samples so as to do an angle callibration through the
% sample. At some point I should create a "beam profiler" function to
% automate FWHM and what not.
% Should be run with "capture every image" on, and reasonably long exposure
% rates to avoid frame drops.
% Note with ETL3, we get something like 3mA/micron of translation. So a
% translation of +/- 30 mA should give +/- 10 microns in each direction.
arguments
    X_start double {isnumeric} = -1
    X_increment double {isnumeric} = 0.01
    X_end double {isnumeric} = 1
    filepath string {isfolder} = ''
end

% Note that spinTIRF seems to run froma about -4 to 4V, so that should be
% plenty. We can always refine range as we get closer.

% X_start = 5;
% X_increment = -.5;
% X_end = -5;

SMX_cycle = X_start: X_increment: X_end;

total_steps = length(SMX_cycle);
ETL_cycle = zeros(total_steps,1);
CSV=zeros(total_steps,3);
for l=1:total_steps
   CSV(l,3) = ETL_cycle(l);
   CSV(l,2) = SMX_cycle(l);
   CSV(l,1)=-SMX_cycle(l);
end

disp(total_steps)
if isempty(filepath)
    filepath = uigetdir();
end
    filename = strcat(filepath, "\", "PYR_LS.txt");
writematrix(CSV, filename, 'Delimiter', ',')
end