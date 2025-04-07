prefix = './r_300um_s_250';
inputfile = [prefix '.csv'];

pixels = csvread(inputfile);

output = [];
for n = 1 : length(pixels)
    volt = [fittedmodel_xv(pixels(n, 1), pixels(n, 2)), ...
            fittedmodel_yv(pixels(n, 1), pixels(n, 2))];
    output = [output;volt];
end

outfile = [prefix '_v.csv'];
csvwrite(outfile, output);