function [xv, yv] = index_to_volts(ind, varargin)
    
    if nargin ==    1
        startXV = 10;
        startYV = -10;
        stepX = -1;
        stepY = 1;
        rowSize = 21;
    else
        paras = varargin{1};
        startXV = paras(1);
        startYV = paras(2);
        stepX = paras(3);
        stepY = paras(4);
        rowSize = 2*abs(startXV/stepX)+1;
    end

	xv = startXV + (fix((ind-1)/rowSize) * stepX);
	yv = startYV + (mod(ind-1, rowSize) * stepY);
end