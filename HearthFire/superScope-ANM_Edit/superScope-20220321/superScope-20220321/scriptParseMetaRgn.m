fileid = fopen(rg);
tline = fgets(fileid);
k = strfind(tline, ', 1');
roiType = tline(3:k);

k2 = strfind(tline, ', 2');
k3 = strfind(tline, ', 3');
coorStr = tline(k2+3:k3-1);
coord = sscanf(coorStr, '%d %d'); %[left top]

nbCoordsStr = tline(strfind(tline, ', 6')+3:strfind(tline, ', 7'));
nbCoords = sscanf(nbCoordsStr, '%d');
NPOINTS = nbCoords(1);
nbCoordsXY = reshape(nbCoords(2:end), 2, [])';