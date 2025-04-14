function PlotVanHove(SpaceUnits, TimeUnits, CenterPoint, EquiProb, time_steps, CircSize,  frame_dt)
% This function just sets up our VanHove plot based on input parameters.
% I should create something to make a dynamic legend at some point.
% Need to figure out units.
arguments
    SpaceUnits {isstring}
    TimeUnits {isstring}
    CenterPoint {iscell}
    EquiProb {iscell}
    time_steps {isrow, isinteger} = [1,2,10]
    CircSize {isinteger, isscalar}= 10
    frame_dt {isscalar} = 1
end
    FigVH=figure();
    hold on
    for tau=time_steps
        if length(CenterPoint{tau}) == length(EquiProb{tau})
            scatter(CenterPoint{tau}, EquiProb{tau},CircSize, "filled")
        else
            % Not sure why but sometimes we get an extra bin which causes
            % the plot to fail
            warning(strcat('Incompatible Sizes for tau=', string(tau)))
        end
        % Gfit{tau}=fit([1000*CenterPoint{1}]', EquiProb{tau}, 'gauss4')
        % plot(Gfit{tau})
    end
    yscale('log')
    TimeLabel = string(time_steps * frame_dt) +' '+ TimeUnits;
    legend(TimeLabel)
    title("Equal Bin Van Hove Distribution")
    ylabel(strcat('P(\Deltax)(', SpaceUnits, ')'))
    xlabel(strcat('\Deltax (', SpaceUnits, ')'))
    hold off
end