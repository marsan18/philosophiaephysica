function movieInfo = getMovieInfo1(img,BW,constrains,calibration)
MINDIST2EDGE = 6;
MINDISTANCEBETWEENSPOTS = 3;
eliminateEdgeFlag = constrains.eliminateEdgeFlag;
areaMin           = constrains.areaMin;
areaMax           = constrains.areaMax;
[imgHeight, imgWidth, imgFrames] = size(img);
if imgFrames>=1
    movieInfo = repmat(struct('xCoord',[],'yCoord',[],'amp',[], 'bkg', []),imgFrames,1);%% Cartesian Coordinate !!
end

for i = 1 : imgFrames
    imgNow = img(:,:,i);
    BWNow  = BW(:,:,i);
%     imgNowMaximaMap = zeros(size(imgNow));
    CC = bwconncomp(BW(:,:,i));
%     numObject = CC.NumObjects;
    sTemp     = regionprops(CC,imgNow,'Area','Centroid','BoundingBox','MaxIntensity', 'MinIntensity');
    if isempty(sTemp)
        continue;
    end
    
     movieInfo(i).xCoord = [];
     movieInfo(i).yCoord = [];
     movieInfo(i).amp    = [];
     movieInfo(i).bkg    = [];
    imgNowMaximaMap = locmax2d(imgNow.*BWNow,[5 5],0);
    [rs,cs] = find(imgNowMaximaMap);
    % remove two crowed position
    pp = cat(2, rs, cs);
    if size(pp, 1)>1
        [~, dd] = knnsearch(pp, pp, 'K', 2);% find the mutal distance between each point
        pp(dd(:, 2)<MINDISTANCEBETWEENSPOTS) = [];
    end
    rs = pp(:, 1); cs = pp(:, 2);
    amp = img(rs+(cs-1)*size(imgNow,1));
    movieInfo(i).xCoord = [cs zeros(size(cs,1),1)];
    movieInfo(i).yCoord = [rs zeros(size(rs,1),1)];
    movieInfo(i).amp    = [amp zeros(size(amp,1),1)];
    movieInfo(i).bkg    = [10*ones(size(amp,1),1) zeros(size(amp,1),1)]; % just guess, could make fancy
    if eliminateEdgeFlag
        idx = movieInfo(i).xCoord(:,1)>=MINDIST2EDGE&movieInfo(i).xCoord(:,1)<=imgWidth-MINDIST2EDGE&...
            movieInfo(i).yCoord(:,1)>=MINDIST2EDGE&movieInfo(i).yCoord(:,1)<=(imgHeight-MINDIST2EDGE);
        movieInfo(i).xCoord = movieInfo(i).xCoord(idx,:);
        movieInfo(i).yCoord = movieInfo(i).yCoord(idx,:);
        movieInfo(i).amp = movieInfo(i).amp(idx, :);
        movieInfo(i).bkg = movieInfo(i).bkg(idx, :);
    end
%     if ~isempty(calibration)
%         movieInfo(i).xCoord(:,1) = movieInfo(i).xCoord(:,1)+calibration.xCoord(i);
%         movieInfo(i).yCoord(:,1) = movieInfo(i).yCoord(:,1)+calibration.yCoord(i);
%     end
end