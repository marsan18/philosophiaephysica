function centerFigures()
% This simple script simply attempts to center all figures on the current
% display
    % Get screen size
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    
    % Define figure size (adjust if needed)
    figWidth = 600;  
    figHeight = 400;  
    
    % Compute centered position
    centerX = (screenWidth - figWidth) / 2;
    centerY = (screenHeight - figHeight) / 2;
    
    % Get all figure handles
    figHandles = findall(0, 'Type', 'figure');

    % Reposition all figures to the same centered location
    for i = 1:numel(figHandles)
        set(figHandles(i), 'Position', [centerX, centerY, figWidth, figHeight]);
    end
end