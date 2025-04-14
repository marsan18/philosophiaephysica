function UniDomainFigCenterJuxt(SpaceUnits, CenterTrack, TopRange, BottomRange, LengthThreshold, dt,  TopBool, BotBool, Thinner)
    % Thinner culls tracks at random, reducing the number plotted by a factor of n.
    % Note: all tracks start at 0 at t=1, so must have LengthThreshold>1.
    % TopRange gives the number of tracks from the top to examine
    % BottomRange gives the number of tracks from the bottom to examine
    % LengthThreshold gives the minimum number of particles in each track to
    % allow inclusion.
    % dt determines the number of timepoints plotted, i.e. the number of frames
    % from the particle's origin which display
    % In this version, the partices are all graphed over ONLY
    % t=1:LengthThreshold.
    % CenterTrack should be the centralized particle tracks ordered from
    % ranked in ascending order by maximum displacement from the center.
    % WE SHOULD UPDATE THIS TO DO TIME RATHER THAN FRAMES!!
    % BotBool includes lowest CenterTrack, which should be low displacement
    % TopBool includes highest CenterTrack, which should be high displacement
    arguments
        SpaceUnits {isstring}
        CenterTrack {iscell}
        TopRange {isinteger} = length(CenterTrack)
        BottomRange {isinteger} = 1
        LengthThreshold {isinteger} = 1
        dt = 1
        TopBool {islogical}= true
        BotBool {islogical}= false
        Thinner {isinteger} = 1
    end

    if TopRange> length(CenterTrack) || BottomRange > length(CenterTrack)
        error('Please Ensure that the top or bottom tracks to plot are not greater than the number of tracks.')
    elseif TopRange+BottomRange > length(CenterTrack)
        error('overlap of bottom and top ranges')
    end

    for k=1:numel(CenterTrack)
        % Centers time so that all frame numbers are converted to begin at 0
        % while preserving relative temporal data
        T{k}(:, 1) = 1:length(CenterTrack{k});
        T_diff{k}(:,1)= CenterTrack{k}(:, 1)-T{k};
        T_adj{k} = T_diff{k}-T_diff{k}(1,1)+1;
        CenterTrack{k}(:, 1) = T_adj{k};
    end
   figure()
      
       hold on
       if TopBool
           for k=(numel(CenterTrack)-TopRange):numel(CenterTrack)
                    if length(CenterTrack{k})>LengthThreshold && randi(Thinner)==Thinner
                        x = CenterTrack{k}(1:dt, 2);
                        y = CenterTrack{k}(1:dt, 3);
                        for j = 1:length(x)
                            if CenterTrack{k}(1:LengthThreshold, 1) > LengthThreshold
                                x(j,1)=[];
                                y(j,1)=[];
                            end
                        end
                        mobile = plot(x, y, 'Color', 'red', 'LineWidth', 0.5);
                    end
           end
       end
        axis equal
        xlabel(SpaceUnits)
        ylabel(SpaceUnits)
        title('Centered tracks')
        if BotBool
            for k=1:BottomRange
                    if length(CenterTrack{k})>LengthThreshold && randi(Thinner)==Thinner
                        x = CenterTrack{k}(1:LengthThreshold, 2);
                        y = CenterTrack{k}(1:LengthThreshold, 3);
                        localized = plot(x, y, 'Color', 'blue', 'LineWidth', 0.5);
                    end
            end
            % viscircles([0,0], 0.2, 'LineStyle', ':', 'Color', 'blue')
        end
        
        axis([-5 5 -5 5])
        title('Centered tracks')
      if TopBool && BotBool
             %  legend([localized mobile], {'Localized', 'Mobile'})
      end
        hold off
end