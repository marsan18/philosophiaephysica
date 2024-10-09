function drawlines(hax, x, colrx, stylex, tagx, y, colry, styley, tagy)
% DRAWLINES Draws horizontal or vertical lines onto a figure.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%
% A utility to draw horizontal or vertical lines from specified points
% usage : drawlines(axes_handle, x, colrx, stylex, tagx, y, colry, styley, tagy)
% axes_handle: handle of the axis in which lines are to be drawn [required]
% x is the vector containing points on X axis from which vertical lines are
%   to be drawn
% y is the vector containing points on Y axis from which horizontal lines
%   are to be drawn
% style? and colr? can be specified to draw customized lines
% tag? is a user-specified label to identify the line with. All horizontal
%   lines drawn with single function call will have the same label, same for
%   vertical lines. If not specified, no lable would be applied.
% As long as at least one of the two signals, x or y is supplied, all other arguments
%   could be left empty. The default values of empty or un-specified
%   arguments are as follows:
%   x, y are defaulted to empty. 
%   style is defaulted to dash-dot line '-.'
%   colrx is defaulted to 'r', colry is defaulted to 'k'
%   tagx, tagy are just not applied if not specified.
%
% Note: The lines drawn span the whole range of the given axes.
% Created 13 July 2005 by   Kalpit V. Desai
if nargin < 9 | isempty(tagy)  tagy = []; end
if nargin < 8 | isempty(styley)  styley = '-.'; end
if nargin < 7 | isempty(colry)  colry = 'k'; end
if nargin < 6 | isempty(y)  y = []; end
if nargin < 5 | isempty(tagx) tagx = []; end
if nargin < 4 | isempty(stylex)  stylex = '-.'; end
if nargin < 3 | isempty(colrx)  colrx = 'r'; end
    
axes(hax);
lastxrange = get(hax,'xlim');
lastyrange = get(hax,'ylim');
axis auto;
xrange = get(hax,'xlim');
yrange = get(hax,'ylim');
% xrange = [-Inf, Inf]; %Thre is some way to plot infinite lines, i've used it somewhere.
% yrange = [-Inf, Inf]; % But here, seems to ignore these lines altogether.
% DETERMINING THE LENGTHS OF THE LINE:
% Plot the lines so that no matter how much the use zoomes out, he sees the
% lines. For this, compare the current axis limits and the axis limits that
% would accomodate all the data points and select the largest.
xrange(1) = min(lastxrange(1), xrange(1));
xrange(2) = max(lastxrange(2), xrange(2));
yrange(1) = min(lastyrange(1), yrange(1));
yrange(2) = max(lastyrange(2), yrange(2));
% first convert the arguments into horizontal matrices
if ((~isempty(x)) & size(x,1) > size(x,2));
    x = x';
end
if ((~isempty(y)) & size(y,1) > size(y,2));
    y = y';
end
if(~isempty(x) & size(x,1) > 1)
    disp('drawlines: Error:: This function accepts only vectors as inputs');
    return;
elseif(~isempty(y) & size(y,1) > 1)
    disp('drawlines: Error:: This function accepts only vectors as inputs');
    return;
end
if(~isempty(x))
    if (isempty(tagx))
        line(repmat(x,2,1), repmat(yrange',1,size(x,2)),'LineStyle',stylex, 'Color', colrx);
    else
        line(repmat(x,2,1), repmat(yrange',1,size(x,2)),'LineStyle',stylex, 'Color', colrx, 'tag', tagx);        
    end
end
if(~isempty(y))
    if (isempty(tagy))
        line(repmat(xrange',1,size(y,2)),repmat(y,2,1),'LineStyle',styley, 'Color', colry);
    else
        line(repmat(xrange',1,size(y,2)),repmat(y,2,1),'LineStyle',styley, 'Color', colry, 'tag', tagy);
    end       
end
% Now set the viewpoint back to where it was
set(hax, 'Xlim',lastxrange);
set(hax, 'Ylim',lastyrange);
