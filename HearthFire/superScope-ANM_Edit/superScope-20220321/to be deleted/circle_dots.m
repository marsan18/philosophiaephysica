%center = [907.3125, 1329.8];
pix_per_um = 1;

centerx = 640
centery = 512;
samples = 250;
radius_um = 300;   % 65um ~= 600 pixels
radius_pix = radius_um * pix_per_um;

step = (pi*2)/samples;
xp = [];
yp = [];

for n = 0 : samples-1
	xp = [xp cos(step*n)*radius_pix+centerx];
	yp = [yp -sin(step*n)*radius_pix+centery];
end

outfile = ['r_', num2str(radius_um),'um_s_', num2str(samples), '.csv'];
csvwrite(outfile, [xp.' yp.']);