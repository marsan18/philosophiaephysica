%% ETL Callibration File
% The main idea behind this file is to iteratively move through ETL and
% sterring mirror samples so as to do an angle callibration through the
% sample. At some point I should create a "beam profiler" function to
% automate FWHM and what not.
% Should be run with "capture every image" on, and reasonably long exposure
% rates to avoid frame drops.
% Note with ETL3, we get something like 3mA/micron of translation. So a
% translation of +/- 30 mA should give +/- 10 microns in each direction.
clc 
clear 'all'


% Note that spinTIRF seems to run froma about -4 to 4V, so that should be
% plenty. We can always refine range as we get closer.
Y_start = -5.1;
Y_increment = .5;
Y_end = 5.1;
X_start = 5.5;
X_increment = -.5;
X_end = -5.51;
ETL_start = 0;
ETL_increment = 1;
ETL_end = 0;
SMX_cycle = X_start: X_increment: X_end;
SMY_cycle = Y_start: Y_increment: Y_end;
ETL_cycle = ETL_start:ETL_increment:ETL_end;

total_steps = length(SMX_cycle)*length(SMY_cycle)*length(ETL_cycle);
CSV=zeros(total_steps,3);
step=0;
for l=1:length(SMX_cycle)
    for m=1:length(SMY_cycle)
        for n=1:length(ETL_cycle)
            step=step+1;
            CSV(step,3) = ETL_cycle(n);
            CSV(step,2) = SMY_cycle(m);
            CSV(step,1)=SMX_cycle(l);
        end
         
    end
  
end
disp(total_steps)
filepath = uigetdir();
filename = strcat(filepath, "\", "ETL_Callib.txt");
writematrix(CSV, filename, 'Delimiter', ',')