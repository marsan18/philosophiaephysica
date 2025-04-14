function [x,y] = PlotVanHoveStructReader(SuperStruct, tspec, CircSize)
% This function just sets up our VanHove plot based on input parameters.
% I should create something to make a dynamic legend at some point.
% Need to figure out units.
arguments
    SuperStruct {isstruct}
    tspec {isrow} = []
    CircSize {isinteger, isscalar}= 10
end
    % TimeUnits=VanHove.TimeUnits;
    VanHove = SuperStruct.VanHoveData;
    
    
    if isempty(tspec)
        % Just plot all tau if no tspec is set by the user
        tspec = VanHove.tau;
    end

    frame_dt = VanHove.FrameTime;
    
    FigVH=figure();
    
    hold on
    
    for tau=tspec
        if length(VanHove.CenterPoint{tau}) == length(VanHove.EquiProb{tau})
            scatter(VanHove.CenterPoint{tau}, VanHove.EquiProb{tau},CircSize, "filled")
        else
            % Not sure why but sometimes we get an extra bin which causes
            % the plot to fail
            warning(strcat('Incompatible Sizes for tau=', string(tau)))
        end
        % Gfit{tau}=fit([1000*CenterPoint{1}]', EquiProb{tau}, 'gauss4')
        % plot(Gfit{tau})
    end
    
    yscale('log')
    TimeLabel = string(tspec * frame_dt) +' '+ SuperStruct.TimeUnits;
    legend(TimeLabel)
    title(strcat("Van Hove Distribution for fps", string(1/frame_dt)))
    ylabel(strcat('P(\Deltax)(', SuperStruct.SpaceUnits, ')'))
    xlabel(strcat('\Deltax (', SuperStruct.SpaceUnits, ')'))

    hold off

    x=VanHove.CenterPoint;
    y=VanHove.EquiProb;
end