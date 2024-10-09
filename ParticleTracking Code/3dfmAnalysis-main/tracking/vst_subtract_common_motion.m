function outs = vst_subtract_common_motion(TrackingTable, ComTable)

    idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
    [g,~] = findgroups(idGroupsTable);
    
    TempTable = innerjoin(TrackingTable, ComTable);

    if ~isempty(TrackingTable)
        drift_free = splitapply(@(x1,x2,x3,x4,x5,x6,x7){subtract_common_mode(x1,x2,x3,x4,x5,x6,x7)}, ...
                                             TempTable.Fid, ...
                                             TempTable.Frame, ...
                                             TempTable.ID, ...
                                             TempTable.Xo, ...
                                             TempTable.Yo, ...
                                             TempTable.Xcom, ...
                                             TempTable.Ycom, ...
                                             g);    
    else
        outs = [];
        return
    end

    drift_free = cell2mat(drift_free);
    drift_free = num2cell(drift_free, 1);
    
    tmpT = table(drift_free{:},'VariableNames', {'Fid', 'Frame', 'ID', 'X', 'Y'});

    TrackingTable.X   = [];
    TrackingTable.Y   = [];
    
    outs = innerjoin(tmpT, TrackingTable);

    outs.Properties.VariableDescriptions{'X'} = 'x-location';
    outs.Properties.VariableUnits{'X'} = 'pixels';
    outs.Properties.VariableDescriptions{'Y'} = 'y-location';
    outs.Properties.VariableUnits{'Y'} = 'pixels';
    
return


function outs = subtract_common_mode(fid, frame, id, xo, yo, xcom, ycom)

        xy = [xo(:) yo(:)];
        common_xy = [xcom(:) ycom(:)];

        xy_offset = xy(1,:);
        c_offset = common_xy(1,:);
        
        xy = xy - xy_offset;        
        common_xy = common_xy - c_offset;
        
        new_xy = xy - common_xy;
        
        new_xy = new_xy + xy_offset;
        
        outs = [fid, frame, id, new_xy];
return