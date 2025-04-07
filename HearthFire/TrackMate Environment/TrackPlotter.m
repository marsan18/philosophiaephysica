function [CenterTrack] = TrackPlotter(CenterTrack, DestDir, PlotDomain, LengthThreshold, safety)      
    arguments
        CenterTrack {iscell}
        DestDir {isfolder} = uigetdir()
        PlotDomain {ismatrix} = (length(CenterTrack)-50):length(CenterTrack)
        LengthThreshold {isscalar} = -1;
        safety {islogical}=true; % Prevents accidental printing of 1000s of tracks
    end
        TrackLength = cellfun(@length, CenterTrack);
    if LengthThreshold ~= -1
        PlotDomain = (length(CenterTrack) - sum(TrackLength>=LengthThreshold)):length(CenterTrack);
    end
    if max(PlotDomain)>length(CenterTrack) || min(PlotDomain) < 1
        error("please select a plot domain within the dataset")
    elseif length(PlotDomain)>10000 && safety
        error("Run cancelled because over 10,000 images would be generated. If this was intended, please turn off safety.")
    elseif length(PlotDomain)>1000
        warning('Very large number of figures will be produced!')
    end
    for k = PlotDomain
        fig = figure('Visible','off');
        plot(CenterTrack{k}(:,2), CenterTrack{k}(:,3), "Marker","o", "LineWidth",0.75, "Color", "red")
        title(strcat(sprintf('Track %d', k), sprintf(' of Length %d', TrackLength(k))));
        xlabel("Displacement (microns)")
        ylabel("Diplacement (microns)")
        daspect([1,1,1])
        filename = strcat(DestDir, '\TrackNumber', string(k), '.tiff');
        waitbar((k-min(PlotDomain))/length(PlotDomain))
        % figure(fig, 'Visible','off')
        exportgraphics(gcf(), filename, "Resolution",1200);
        close
    end
end

