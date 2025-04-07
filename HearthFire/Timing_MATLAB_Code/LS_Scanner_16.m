function [CSV] = LS_Scanner_16(filepath, SM1, SM2, bookends, AUX_PIN, AX1, laser, SM1_correct, AltReadoutMode)
    %% ETL Callibration File
    % This program generates a .csv file which may be  imported into LABVIEW.
    % This .csv may be imported to create a wavefunction and run Hestia.
    % The filepath determines the place where the .csv is saved.
    % SM1 is a 2XN matrix which gives the desired values for X,Y at each step.
    % SM2 is a 1X2 matrix which may simply be set to the desired pair of values.
    % The first Aux setting is desinged to progress once per mirror scan.
    % AUX_PIN determines the output pin of AUX matrix 1.
    % AX1 matrix is a (1X3) which determines start, increment, end.
    % Laser gives AOTF voltage settings from 0-10V. Defaults to max power for
    % 488nm. Automatically turns of when LS scan is finished.
    % ORDER FOLLOWS PINOUT ORDER {LABVIEW LABELS 0-15}
    % 1)	AOTF: 405nm laser
    % 2)	AOTF: 488nm laser
    % 3)	AOTF: 514nm laser
    % 4)	AOTF: 561nm laser
    % 5)	AOTF: Blanking
    % 6)	STEERING MIRROR X1. STD OFFSET: 4
    % 7)	STEERING MIRROR Y1 STD OFFSET: -0.3
    % 8)	STEERING MIRROR X2 STD OFFSET -4
    % 9)	STEERING MIRROR Y2 STD OFFSET -4
    % 10)	ICC4C Dev 0
    % 11)	ICC4C Dev 1
    % 12)	ICC4C Dev 2
    % 13)	ICC4C Dev 3
    % 14)	ANDOR TRIGGER
    % 15)	PIEZO CONTROL X
    % 16)	PIEZO CONTROL Y
    
    arguments
        filepath string {isfolder} = "C:\Users\al3xm\Desktop"
        SM1 (2,:) double = vertcat(-1: 0.01 : 1, 1: -0.01: -1);
        SM2 (1, 2) double = [0,0];
        bookends double {isnumeric} = 1; % If this is set to 0, the lasers won't shut off.
        AUX_PIN = -1;
        AX1 (1, :) double = [0: 1: 5];
        laser (1,5) double = [0, 10, 0, 0, 10];
        SM1_correct = true;
        AltReadoutMode  = false; % Add functionality to invert scan after a brief readout period rather than resetting mirror to initial position
    end
    
   
    
    labels = ["405nm laser", "488nm laser", "514nm laser", "561nm laser", "Blanking", "SM1 X", "SM1 Y", "SM2 X","SM2 Y", "ICC4C 0",  "ICC4C 1",  "ICC4C 2",  "ICC4C 3", "EXT TRIG", "PZ X", "PX Y"];
    
    bookmarks = bookends;
    
    SM1_mod = vertcat(ones(1, length(SM1))*4, ones(1, length(SM1))*-0.3);
    if SM1_correct
        SM1 = SM1 + SM1_mod;
    end
    
    total_steps = length(SM1);
    
    % Preallocate matrix
    
    CSV=zeros(total_steps,16);
    
    
    
    CSV_Aux= [];
    if AUX_PIN == -1 % If no auxiliary outer loop exists, do the inner loop
         for j=1:total_steps 
           CSV(j, 14) = 5;
           CSV(j,2) = 10;
           CSV(j,5)= 10;
           CSV(j,6) = SM1(1,j);
           CSV(j,7)=SM1(2,j);
           CSV(j,8) = SM2(1);
           CSV(j,9) = SM2(2);
        end
    else % Loop inner loop inside outer loop and write the outer loop to AUX_PIN.
        for k=1:length(AX1)
            for j=1:total_steps + bookmarks
               if j <= total_steps
                   CSV(j, 14) = 5;
                   CSV(j,1:5) = laser;
                   CSV(j,6) = SM1(1,j);
                   CSV(j,7) = SM1(2,j);
                   CSV(j,8) = SM2(1);
                   CSV(j,9) = SM2(2);
                   CSV(j,AUX_PIN) = AX1(k);
               else % Re-initialize starting point
                   CSV(j, 14) = 0;
                   CSV(j,2) = 0;
                   CSV(j,5)= 10;
                   CSV(j,6) = SM1(1,1);
                   CSV(j,7)=SM1(2,1);
                   CSV(j,AUX_PIN) = AX1(k);
                   CSV(j,8) = SM2(1);
                   CSV(j,9) = SM2(2);
               end
           end
            CSV_Aux = vertcat(CSV_Aux, CSV);
        end
    end
    if ~ isempty(CSV_Aux)
        CSV = CSV_Aux;
    end
    CSV_bookend = CSV(1, :); %CSV_bookend is just the initial value.
   
    CSV_bookend(1,14)= 0; % Camera shuts off
    CSV_bookend(1,2) = 0; % Laser shuts off
    
    if bookends ~= 0
        for j= 1:bookends
            CSV = vertcat(CSV_bookend, CSV, CSV_bookend);
        end
    end
    
    % Use loop for additional bookend steps
    
    if isempty(filepath)
        filepath = uigetdir();
    end
    filename = strcat(filepath, "\", "PYR_LS.txt");
    writematrix(CSV, filename, 'Delimiter', ',')
    
        for col = 1:size(CSV,2)
            if sum(CSV(:, col)) ~= 0 % Plots any non-zero channel
                figure; % Create a new figure
                plot(1:size(CSV,1), CSV(:, col), 'LineWidth', 1.5); % Plot column data
                xlabel('Row Index');
                ylabel('Value');
                title(labels{col});
                grid on;
            end    
        end
        if length(labels) == size(CSV,2) % Adds chart titles
            CSV_table = array2table(CSV, 'VariableNames', labels);
            disp(CSV_table);
        else
            disp(CSV);
        end
        seqLength = fprintf("Sequence length is %d \n", size(CSV,1));
end
