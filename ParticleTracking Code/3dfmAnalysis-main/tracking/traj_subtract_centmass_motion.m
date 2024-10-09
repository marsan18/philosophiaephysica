function [vid_table,q] = traj_subtract_centmass_motion(vid_table, traj_common, plotyn)
% at each time point, average all beads x, y, and z values to determine
% center of mass vector and subtract that from each bead's position.
% This routine is insensitive to the disapperance of old trackers or the 
% sudden existence of new trackers that would otherwise cause sudden 
% jumps in the center-of-mass, so a polyfit of the center-of-mass should be
% used.

    if nargin < 3 || isempty(plotyn)
        plotyn = 'n';
    end


    video_tracking_constants;   
    
    id_list = unique(vid_table(:,ID));
  
    order = 1;
    
    weights = traj_common.weights;

    xycom = traj_common.xy - traj_common.xy(1,:);

    px = polyfitw(traj_common.frame, xycom(:,1),order,[],weights);
    py = polyfitw(traj_common.frame, xycom(:,2),order,[],weights);
    
    driftx = polyval(px,traj_common.frame);
    drifty = polyval(py,traj_common.frame);

    
    % subtract out drift vector from each tracker
     for k = 1:length(id_list)
        idx = (  vid_table(:,ID) == id_list(k)  );
        tmp = vid_table(idx,:);

        dt = diff(tmp(:,FRAME));  % labeled as 'dt' here for 'velocity' sake, but actually it's 'dFRAME'

        my_frame_list = ( min(tmp(:,FRAME)):max(tmp(:,FRAME)) )';
        my_driftx = polyval(px,my_frame_list);
        my_drifty = polyval(py,my_frame_list);               

        vid_table(idx,X) = tmp(:,X) - my_driftx;
        vid_table(idx,Y) = tmp(:,Y) - my_drifty;    
    
        if contains(plotyn, 'y')
            figure; 
            plot(tmp(:,TIME), tmp(:,X:Y), 'or', vid_table(idx,TIME), vid_table(idx,X:Y), '.b');
            drawnow;
        end
     end

     % output average velocities for x and y (not sure what else to do
     % here, maybe polynomial coefficients?)
     % q.method
     % q.order
     % q.frame
     % q.xcoeffs
     % q.ycoeffs
     % q.xy
     
     q = [mean(diff(driftx)), mean(diff(drifty))];    % px/sec

    return;