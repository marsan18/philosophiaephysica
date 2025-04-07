
    [frame_ind, x_coord, y_coord] = gen_spot_tracker_coord(filename);
	
    x_volts = [];
    y_volts = [];
    
    for ind = frame_ind
        [xv, yv] = index_to_volts(ind);
        x_volts = [x_volts xv];
        y_volts = [y_volts yv];
    end
