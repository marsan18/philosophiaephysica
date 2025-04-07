function [CenterTrack, CenterTrackMaximaSorted] = CreateCenterTracks(FilterTrack)
% Edits FilterTrack so that all particles start at (0,0)
% Then sorts them by length. 
    CenterTrack = FilterTrack;
    FilterLength= cellfun(@length, FilterTrack);
    for n=1:numel(FilterTrack)
        X_offset = FilterTrack{n}(1, 2);
        Y_offset = FilterTrack{n}(1, 3);
        CenterTrack{n}(:,2) = CenterTrack{n}(:,2)-X_offset*ones(FilterLength(n),1);
        CenterTrack{n}(:,3) = CenterTrack{n}(:,3)-Y_offset*ones(FilterLength(n),1);
    end
    
    % Sorting CenterTracks by displacement
    
    for k=1:numel(CenterTrack)
        CenterTrack{k}(:,4)=CenterTrack{k}(:,2).^2 + CenterTrack{k}(:,3).^2;    
    end
    CenterTrackMaxima=cellfun(@max, CenterTrack, 'UniformOutput', false);
    
    for k=1:numel(CenterTrackMaxima)
        CTMM(k,1) = CenterTrackMaxima{k}(:,4);
    end
    [~, center_id]=sort(CTMM);
    CenterTrack=CenterTrack(center_id);
    CenterTrackMaximaSorted=cellfun(@max, CenterTrack, 'UniformOutput', false);
end