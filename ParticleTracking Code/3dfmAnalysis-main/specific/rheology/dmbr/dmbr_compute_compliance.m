function v = dmbr_compute_compliance(rheo_table, params)

    dmbr_constants;

    % we have to "fudge" the zero voltage compliance a bit because there is no
    % force.  However, for convenience, we would like the plotted compliance to
    % start at the last compliance computed for the "force on" part of the data.
    idx1 = find(rheo_table(:,VOLTS) ~= 0);
    idx0 = find(rheo_table(:,VOLTS) == 0);

    % pull out relevant constants
    a = params.bead_radius * 1e-6; % um -> m

    % get the zero position of the bead.
    x = rheo_table(:,X);
    y = rheo_table(:,Y);
    F = rheo_table(:,FORCE);
   
    % neutralize signals to begin at zero.
    if ~isempty(x)
        x = x - x(1);
        y = y - y(1);
    end
    
    
    % compute the x and y compliances and plant into output data table.
    % compliance during the period of no force is calculated using the
    % average of the force over the period which it was applied.
    
    % force compliance
    rheo_table(idx1,J) = 6 * pi * a * sqrt(x(idx1).^2 + y(idx1).^2) ./ F(idx1);
    
    %no force compliance
    rheo_table(idx0,J) = 6 * pi * a * sqrt(x(idx0).^2 + y(idx0).^2) ./ mean(F(idx1));

    %rheo_table(:,J) = 2 * pi * a * (4/9) * sqrt(x.^2 + y.^2) ./ F;
    
    % adjust the zero voltage values and plant into output data table.  If 
    % there is no data during the zero voltage region, i.e. all elements of
    % idx1 are zero, then set the recovery compliance to NaN.
    if sum(idx1) > 0
        rheo_table(idx0,J) = rheo_table(idx0,J) ./ max(rheo_table(idx0,J)) .* max(rheo_table(idx1,J));
    else
        rheo_table(idx0,J) = NaN;
    end
    
    % output the results
    v = rheo_table;


