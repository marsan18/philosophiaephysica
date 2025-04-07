function PlotVanHoveEquiTauStructReader(SuperStruct, tspec, CircSize)
% This function opens a VanHoveData struct and plots exactly one time step
% It then divides the CenterPoint (the x data) by the timestep to give the
% implied velocity in m/s of that step.

arguments
   SuperStruct {isstruct}
   tspec {isrow} = [] % defaults to running everything
   CircSize {isinteger}=10
end
    TimeUnits=SuperStruct.TimeUnits;
    SpaceUnits=SuperStruct.SpaceUnits;
    VanHoveData = SuperStruct.VanHoveData;
    % CenterPoint=VanHoveData.CenterPoint;
    % TimeUnits=VanHoveData.TimeUnits;
    EquiProb = VanHoveData.EquiProb;
    
    if isempty(tspec)
        time_step = VanHoveData.tau(1,1);
    else 
        time_step = tspec;
    end

    frame_dt = VanHoveData.FrameTime;
    %% Plotting
    hold on
    
    for tau=time_step
        if length(VanHoveData.CenterPoint{tau}) == length(EquiProb{tau})
            scatter(VanHoveData.CenterPoint{tau}/(tau*frame_dt), EquiProb{tau},CircSize, "filled")
        else
            % Not sure why but sometimes we get an extra bin which causes
            % the plot to fail
            warning(strcat('Incompatible Sizes for tau=', string(tau)))
        end
        % Gfit{tau}=fit([1000*VanHoveData.CenterPoint{1}]', EquiProb{tau}, 'gauss4')
        % plot(Gfit{tau})
    end

    yscale('log')
    TimeLabel = string(time_step * frame_dt) +' '+ TimeUnits;
    legend(TimeLabel)
    title(strcat("Van Hove Distribution for fps ", string(1/frame_dt)))
    ylabel(strcat('P(\Deltax)(', SpaceUnits, ')'))
    xlabel(strcat('\Deltax (', SpaceUnits, ')'))

    hold off
end