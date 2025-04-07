function FigCenterJuxt(CenterTrack, TopRange, BottomRange, LengthThreshold)
% TopRange gives the number of tracks from the top to examine
% BottomRange gives the number of tracks from the bottom to examine
% LengthThreshold gives the minimum number of particles in each track to
% required for inclusion
% CenterTrack should be the centralized particle tracks ordered from
% ranked in ascending order by maximum displacement from the center.
    for k=(numel(CenterTrack)-TopRange):numel(CenterTrack)
            if length(CenterTrack{k})>LengthThreshold
                x = CenterTrack{k}(:, 2);
                y = CenterTrack{k}(:, 3);
                plot(x, y, 'Color', 'red')
            end
        end
    axis equal
    xlabel( [ 'X (microns)' ] )
    ylabel( [ 'Y (microns)' ] )
    title('Centered tracks')
    
    for k=1:BottomRange
            if length(CenterTrack{k})>20
                x = CenterTrack{k}(:, 2);
                y = CenterTrack{k}(:, 3);
                plot(x, y, 'Color', 'blue')
            end
    end
    axis([-3 3 -3 3])
    % xlabel( [ 'X (' metadata.spaceUnits ')' ] )
    % ylabel( [ 'Y (' metadata.spaceUnits ')' ] )
    title('Centered tracks')
    viscircles([0,0], 0.2, 'LineStyle', ':', 'Color', 'blue')