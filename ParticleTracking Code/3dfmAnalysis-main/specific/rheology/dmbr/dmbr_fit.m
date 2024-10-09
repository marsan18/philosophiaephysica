function [G, eta, ct_fit, R_square] = dmbr_fit(rheo_table, fit_type)

    dmbr_constants;

    idx = find(rheo_table(:,VOLTS) ~= 0);
    
    if ~isempty(idx)
        table = rheo_table(idx,:);

        t  = table(:,TIME);
        t  = t - t(1);
        ct = table(:,J);
        
        switch fit_type
            case 'Newtonian'
                fit = polyfit(t, ct, 1);          
                ct_fit = polyval(fit, t);
                err = uncertainty_in_linefit(t, ct, fit);
                R2 = corrcoef(t, ct);
                R_square = R2(1,2);
                eta_dc = 1/fit(1); 
                G = 0;
                eta = eta_dc;
            case 'Maxwell'
                [G_mm, eta_mm, R_square] = MM_step_fit(t, ct, 'n');
                ct_fit = MM_step_fun([G_mm, eta_mm],t,ct);
                G = G_mm;
                eta = eta_mm;
            case 'Kelvin-Voight'
                [G_kv, eta_kv, R_square] = KV_step_fit(t, ct, 'n');
                ct_fit = KV_step_fun([G_kv, eta_kv],t,ct);
                G = G_kv;
                eta = eta_kv;
            case 'Jeffrey'
                [G_kv, eta_kv, eta_dc, R_square] = jeffrey_step_fit(t, ct, 'n');
                ct_fit = jeffrey_step_fun([G_kv, eta_kv, eta_dc],t,ct);                
                G = G_kv;
                eta = [eta_kv, eta_dc];
            case 'Stretched Exponential'
                [x_zero, tau, h, R_square]= stretched_exponential_fit(t, x, 'n');
                ct_fit = stretched_exp_fun([x_zero, tau, h, R_square], t, xt);
                % need to fix the way fits are expressed in this code.
                % each fit should have its own parameters defined
            case 'Ke model #1'
                [G_ke, eta_ke] = ke_fun_fit(t, x, f);
            case 'Power Law'
                [A0,alpha,G0,R_square] = power_law_fitting(t,ct);
                G = G0;
                eta = NaN;
                ct_fit = A0*t.^alpha;
            case 'Power Law (Fabry)'
                [J0,beta,R_square] = power_law_fitting_fabry(t,ct);
                G = 1/J0;
                eta = beta; %DANGEROUS. NOT ETA.
                ct_fit = J0*t.^beta;
                                
            otherwise
                ct_fit = NaN;
                G = NaN;
                eta = NaN;
                R_square = NaN;
        end
    else
        logentry('No data selected during active voltage period.  These models are specific to that period.');

        switch fit_type
            case 'Jeffrey'
                G   = NaN;
                eta = [NaN NaN];
            otherwise
                G = NaN;
                eta = NaN;
        end
        
        ct_fit = NaN;
        R_square = NaN;
    end

    return;


    function logentry(txt)

    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_fit: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;
