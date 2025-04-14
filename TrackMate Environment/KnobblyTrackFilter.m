function [SelectTracks] = TrackFilter(SuperStruct)
    % The idea of this function is to accept a SuperStruct and output a
    % list of interesting track numbers.
    arguments
        SuperStruct {isstruct}
    end
    TrackLengths = cellfun(@length, SuperStruct.msdanalyzer.tracks);
    VHDiffs = SuperStruct.VanHoveData.Data;
    % Sort into Tracks
    SingleFrameDiffs = VHDiffs{1,1}
    SingleFrameTrackDiffs = {};
    
    % So my idea was to check for step size autocorrelation but I'm not
    % sure that is working too well...Seems to be a very rather poor indicator of
    % interesting tracks...
    % However, perhaps a larger autocorrelation step will help

    % The below creates a list of n frame differences by Track
    for k=1:length(VHDiffs)
         n=0;
        if ~isempty(VHDiffs{k,1})
            for num = 1:length(VHDiffs{k,1})
                tracknum =  VHDiffs{k,1}(num, 3);
                if tracknum ==  VHDiffs{k,1}(num-n, 3)
                    n=n+1;
                else
                    n=0;
                end
                FrameTrackDiffs{k,tracknum}(n+1,1:2) = VHDiffs{k,1}(num, 1:2);
            end
        else
            warning("")
        end
    end
    % Now to do autocorrelation by track
    absacf = zeros(length(FrameTrackDiffs),2);
    acf = zeros(length(FrameTrackDiffs),2);
    lags=5
    for k=1:length(FrameTrackDiffs)
        absacf(k, 1:lags+1)= autocorr(abs(FrameTrackDiffs{1,k}(:,1)), 'NumLags', lags);
        acf(k, 1:lags+1)=autocorr((FrameTrackDiffs{1,k}(:,1)), 'NumLags', lags);
        % Remove NaNs?
    end
    % Returns a sorted list of Track number, acf
   [ absacfsorted(:,2),absacfsorted(:,1)] =  sort(absacf(:,2), 'ComparisonMethod', 'abs');
   plot(absacfsorted)
  
end