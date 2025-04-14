function figs = SaveAllFigs(path);
arguments
    path {isfolder} = uigetdir()
end
figs = findall(0, 'Type', 'figure');

% Loop through each figure
for i = 1:length(figs)
    fig = figs(i);
    
    % Create a filename like "Figure_1.png", "Figure_2.png", etc.
    filename = sprintf('Figure_%d.png', fig.Number);
    
    % Save the figure as a PNG
    saveas(fig, filename);
    
    fprintf('Saved figure %d as %s\n', fig.Number, filename);
end

disp('All open figures saved.');