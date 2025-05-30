function [realtime_CompMSD, loc_error] = FigMeanMSD(SpaceUnits, TimeUnits, InputMa, timestep, D_expect, PlotMSDs, LineColor, MinorLineColor)
% NOTE: UNITS ARE SOMEWHAT SCREWY! 
% Assumes the input MSD is already precomputed by TrackMateImport
% Input an ma struct generated by MSD analyzer
% timestep gives the Δt per frame in seconds (i.e. exposure)
% D_expect gives the theoretical displacement unit in (distance^2)/(time)
% To avoid comparison, set D_expect to -1.
% PlotMSDs is a boolean which determines if we should plot all MSDs in
% light gray or not.
%  Results are returned as a N x 4 double array, and ordered as
% following: [ dT M STD N EXP_M] with:
% - dT the delay vector
% - M the weighted mean of MSD for each delay
% - STD the weighted standard deviation
% - N the number of degrees of freedom in the weighted mean
% (see http://en.wikipedia.org/wiki/Weighted_mean)
% - EXP_M gives predicted MSD value at that time
% InputMa has   Results are stored in the msd field of this object as a cell
% array, one cell per particle. The array is a double array of size
% N x 4, and is arranged as follow: [dt mean std N ; ...] where dt
% is the delay for the MSD, mean is the mean MSD value for this
% delay, std the standard deviation and N the number of points in
% the average.
    arguments
        SpaceUnits {isstring}
        TimeUnits {isstring}
        InputMa
        timestep (1,1) double {mustBeScalarOrEmpty(timestep)}
        D_expect (1,1) double {mustBeScalarOrEmpty} = -1
        PlotMSDs = false
        
        LineColor string = 'black'
        MinorLineColor string = '#D3D3D3'
    end
    ma=InputMa;
    if isempty(ma.msd)
        % This prevents errors in case the imput struct has not had
        % computeMSD method run on it yet.
        ma=ma.computeMSD;
    end
    mean_MSD = ma.getMeanMSD;
    realtime_CompMSD = mean_MSD;
    realtime_CompMSD(:,1) = mean_MSD(:,1).*timestep;
    realtime_CompMSD(:,5) = 4*D_expect.*realtime_CompMSD(:,1);
    figure()
    hold on
    if PlotMSDs
        for k=1:numel(ma.msd)
             plot(ma.msd{k}(:, 1).*timestep, ma.msd{k}(:,2), 'LineWidth', 0.1, 'Color', MinorLineColor );
        end
    end
    MeanPlot = plot(realtime_CompMSD(:,1), realtime_CompMSD(:,2), 'LineWidth',3, 'Color', LineColor);
    if not(D_expect==-1)
        plot(realtime_CompMSD(:,1), realtime_CompMSD(:,5), 'LineWidth',1, 'Color','red', 'Marker','.');
    end
    % legend(MeanPlot='Experimental Mean MSD', x='Individual Experimental MSDs',strcat('Predicted MSD (D=', num2str(D_expect), ')')
    xlabel(TimeUnits)
    SqSpaceUnits = strcat('(', SpaceUnits, ')^2');
    ylabel(SqSpaceUnits)
    xscale('log')
    yscale('log')
    hold off
end