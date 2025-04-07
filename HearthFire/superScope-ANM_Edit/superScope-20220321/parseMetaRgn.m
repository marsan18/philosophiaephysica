function pixList = parseMetaRgn(filename, cameraSize)

fileid = fopen(filename);
tline = fgets(fileid);
k = strfind(tline, ', 1');
roiType = tline(3:k);

k2 = strfind(tline, ', 2');
k3 = strfind(tline, ', 3');
coorStr = tline(k2+3:k3-1);
coord = sscanf(coorStr, '%d %d'); %[left top]


if isempty(strfind(tline, ', 7'))
    nbCoordsStr = tline(strfind(tline, ', 6')+3:end);
else
    nbCoordsStr = tline(strfind(tline, ', 6')+3:strfind(tline, ', 7'));
end
nbCoords = sscanf(nbCoordsStr, '%d');
NPOINTS = nbCoords(1); % how many points
nbCoordsXY = reshape(nbCoords(2:end), 2, [])';

roiMask = poly2mask(nbCoordsXY(:, 1), nbCoordsXY(:, 2), cameraSize(1), cameraSize(2));
status = regionprops(roiMask, 'PixelList');
pixList = status.PixelList;