function movieInfo = getMovieInfo(img,BW,constrains,calibration)

MINDIST2EDGE = 6;

eliminateEdgeFlag = constrains.eliminateEdgeFlag;
areaMin           = constrains.areaMin;
areaMax           = constrains.areaMax;
[imgHeight, imgWidth, imgFrames] = size(img);
if imgFrames>=1
    movieInfo = repmat(struct('xCoord',[],'yCoord',[],'amp',[]),imgFrames,1);%% Cartesian Coordinate !!
end

for i = 1 : imgFrames
    CC = bwconncomp(BW(:,:,i));
%     numObject = CC.NumObjects;
    sTemp     = regionprops(CC,img(:,:,i),'Area','Centroid','BoundingBox','MaxIntensity', 'MinIntensity');
    if isempty(sTemp)
        continue;
    end
    stats  = sTemp(([sTemp.Area]>=areaMin)&([sTemp.Area]<=areaMax));  %reject from puntum size
%     if eliminateEdgeFlag
%         centroid = reshape([sTemp.Centroid],2,[]);
% 
%         stats    = sTemp(([sTemp.Area]>=areaMin)&([sTemp.Area]<=areaMax)&(centroid(1,:)>=3)&...
%         (centroid(1,:)<=(imgWidth-2))&(centroid(2,:)>=3)&(centroid(2,:)<=(imgHeight-2)) ) ;  
%     else
%     stats     = sTemp(Idx);
%     numObject = length(stats);
    coords    = reshape([stats.Centroid],2,[]);  
    amp       = [stats.MaxIntensity];
    bkg       = [stats.MinIntensity];
    movieInfo(i).xCoord = [coords(1,:)' zeros(size(coords,2),1)];
    movieInfo(i).yCoord = [coords(2,:)' zeros(size(coords,2),1)];
    movieInfo(i).amp    = [amp' zeros(size(coords,2),1)];
    movieInfo(i).bkg    = [bkg' zeros(size(coords,2),1)];
    if ~isempty(calibration)
        movieInfo(i).xCoord(:,1) = movieInfo(i).xCoord(:,1)+calibration.xCoord(i);
        movieInfo(i).yCoord(:,1) = movieInfo(i).yCoord(:,1)+calibration.yCoord(i);
    end

    if eliminateEdgeFlag
        nnnn = size([movieInfo(i).xCoord],1);
        idx  = [];
        for j = 1 : nnnn
            if movieInfo(i).xCoord(j,1)<=MINDIST2EDGE||movieInfo(i).xCoord(j,1)>(imgWidth-MINDIST2EDGE)||...
                    movieInfo(i).yCoord(j,1)<=MINDIST2EDGE||movieInfo(i).yCoord(j,1)>(imgHeight-MINDIST2EDGE)
                idx = cat(1,idx,j);
            end
        end
        movieInfo(i).xCoord(idx,:) = [];
        movieInfo(i).yCoord(idx,:) = [];
        movieInfo(i).amp(idx,:)    = [];
        movieInfo(i).bkg(idx,:)    = [];
    else
        movieInfo(i).xCoord = movieInfo(i).xCoord((movieInfo(i).xCoord(:,1)>0)&(movieInfo(i).xCoord(:,1)<imgWidth),:);
        movieInfo(i).yCoord = movieInfo(i).yCoord(movieInfo(i).xCoord(:,1)>0&movieInfo(i).xCoord(:,1)<imgWidth,:);
        movieInfo(i).amp    = movieInfo(i).amp(movieInfo(i).xCoord(:,1)>0&movieInfo(i).xCoord(:,1)<imgWidth,:);
        movieInfo(i).bkg    = movieInfo(i).bkg(movieInfo(i).xCoord(:,1)>0&movieInfo(i).xCoord(:,1)<imgWidth,:);
        movieInfo(i).yCoord = movieInfo(i).yCoord(movieInfo(i).yCoord(:,1)>0&movieInfo(i).yCoord(:,1)<imgHeight,:);
        movieInfo(i).xCoord = movieInfo(i).xCoord(movieInfo(i).yCoord(:,1)>0&movieInfo(i).yCoord(:,1)<imgHeight,:);
        movieInfo(i).amp    = movieInfo(i).amp(movieInfo(i).yCoord(:,1)>0&movieInfo(i).yCoord(:,1)<imgHeight,:);
        movieInfo(i).bkg    = movieInfo(i).bkg(movieInfo(i).yCoord(:,1)>0&movieInfo(i).yCoord(:,1)<imgHeight,:);
    end
end
end