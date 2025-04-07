%% The primary purpose of this program is to create CSV files detailing each
%% voltage step in our LSFM LABVIEW program. They can also be used to create precise voltage diagrams.
%% We assume small angle approximations hold here so that linear voltage growth is good enough.
clear all
close all
SM1_step = .1; % ΔV for SM1 per timestep
SM2_step=5;
SM1_Vmin=-10;
SM1_Vstart = SM1_Vmin;
SM1_Vmax=10;
SM2_Vmin=-10;
SM2_Vstart = SM2_Vmin;
SM2_Vmax=10;
Zyla_V_trig=5;
Zyla_trigger_width = 100;
cycles=1;
initial_delay = 0; %sets a number of tics for which nothing happens
ETL_factor=.7;
ETL_offset = 0;


SM2_Voverride = 3;
SM2_override_active=false;
if SM2_override_active
    SM2_Vstart=SM2_Voverride;
    SM2_step = 0;
end

if SM2_step == 0
    num_tics = ((SM1_Vmax - SM1_Vmin)/SM1_step)*cycles; %total number of timesteps
else
    num_tics = (((SM1_Vmax - SM1_Vmin)/SM1_step)+(Zyla_trigger_width+1)*2) * ((SM2_Vmax - SM2_Vmin)/SM2_step + 1)*(cycles)+ initial_delay
end
disp("Number of Tics:")
disp(num_tics)
% Manual_tic_override = 10
% num_tics = manual_tic_override
% Preload tics for speed
SM1_V = zeros(1,num_tics+1);
SM2_V = zeros(1,num_tics+1);
SM2_V(1,1) = SM2_Vstart;
Zyla_V = zeros(1,num_tics+1);
SM1_V(1, 1) = SM1_Vstart;
inter_scan_delay = Zyla_trigger_width; %sets amount of time to wait between SM1 scan reverses.

%Now we just overwrite each element of the tics matrix to the desired value
SM1_Vmod = 1;
inter_scan_wait_until = 0; % should probably never be set to anything other than zero to begin with--use delay instead.
for count = (2:num_tics+1) % first tic is manually set to whatever so we start at 2.
    SM1_V(1,count) = SM1_V(1, count-1) + SM1_step*SM1_Vmod;
    frame_end = false; %resets with each cycle.
    SM2_V(1,count) = SM2_V(1, count-1);
    if count <= initial_delay
        SM1_V(1,count)=0;
    elseif  count<= inter_scan_wait_until
        SM1_V(1,count) = SM1_V(1, count-1); %freezes SM1 and whatever else I add until the inter-scan-delay is over.
    end
    if and(or(SM1_V(1,count) >= SM1_Vmax-SM1_step, SM1_V(1,count) <= SM1_Vmin), count >= inter_scan_wait_until+1) 
        %Second condition prevents infinite frame triggers
        %TODO get other diagram in here as well!
        %I'm not sure why, but we accidentally end up at 10.1 instead of 10
        %if we dont end the positive count 1 step early.
        frame_end = true; % If SM1 has reached the end of its travel, its time for frame-ending even
    end
    if frame_end
        inter_scan_wait_until = inter_scan_delay + count; % Sets a waiting period for camera or what not to prep.
         SM1_Vmod = SM1_Vmod*(-1); %reverse SM1 travel direction
         for z_count = 0:Zyla_trigger_width
              Zyla_V(count+z_count) = Zyla_V_trig;
         end
        SM2_V(1, count) = SM2_V(1, count-1) + SM2_step;
        if SM2_V(1,count)>= SM2_Vmax
            SM2_V(1,count)=SM2_Vmin;
        end
    end
end
SM2_V_repaired = SM2_V(1, 1:num_tics+1);
Zyla_V_repaired = Zyla_V(1, 1:num_tics+1);
ETL_V = SM2_V_repaired*ETL_factor + ETL_offset; %May be more complicated than this-could require some sort of function call if if a non-linear relationship.
time = 0:num_tics;
% If voltage override is less than -10, it is ignored. If it is not, it is
% applied to all steps for that steering mirror.
V_SM1_plot = figure('Name','Voltage for SM1','NumberTitle','off');
plot(time, SM1_V, ".")
ylim([-10.5 10.5])
xlim ([0,inf])

V_Zyla_plot = figure('Name','Voltage for Zyla','NumberTitle','off');
plot(time, Zyla_V_repaired, ".")
ylim([-10.5 10.5])
xlim ([0,inf])

V_SM2_plot = figure('Name','Voltage for SM2','NumberTitle','off');
plot(time, SM2_V_repaired, ".")
ylim([-10.5 10.5])
xlim ([0,inf])

Timing_diagram=figure('Name', 'timing diagram', 'NumberTitle','off');
tiledlayout(4,1)
xlabel('time')

% Top plot
nexttile
plot(time,Zyla_V_repaired, ".")
ylim([-10.5 10.5])
xlim ([0,inf])
xticklabels({})
yticklabels({})
xticks(0:300:2000)
ylabel('Zyla Voltage')

% Bottom plot
nexttile
plot(time,SM1_V,".")
ylim([-10.5 10.5])
xlim ([0,inf])
xticklabels({})
yticklabels({})
xticks(0:300:2000)
ylabel('SM1 Voltage')

nexttile
plot(time,SM2_V, ".")
ylim([-10.5 10.5])
xlim ([0,inf])
xticklabels({})
xticks(0:300:2000)
yticklabels({})
ylabel('Scanning Position')

nexttile
plot(time, ETL_V, ".")
ylim([-10.5 10.5])
xlim ([0,inf])
yticklabels({})
xticklabels({})
xticks(0:300:2000)
ylabel('ETL Voltage')
xlabel('Labview Timesteps')


% For some reason, a bunch of decimal places get stuck into the data, so we
% round to n digits with the following functions.
n=1; %number of digits to the right of the decimal point to round to. Change so that steps don't get cut off.
SM1_V_rounded = round(SM1_V, n);
SM2_V_repaired_rounded = round(SM2_V_repaired, n);
Zyla_V_rounded = round(Zyla_V, n);
writematrix(SM1_V_rounded, 'SM1_V1.txt')
writematrix(SM2_V_repaired_rounded, 'SM2_V2.txt')
writematrix(Zyla_V_rounded, 'Zyla_V.txt')
% Add ETL1, ETL2, SM1.