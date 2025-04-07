function [frame_ind, x_vec, y_vec] = gen_spot_tracker_coord(filename)
    try
        M = csvread(filename, 1, 0);
    catch
        [M,~,~] = xlsread(filename);
    end
    frame_ind = M(:,1);
    x_vec = M(:,3);
    y_vec = M(:,4);
end