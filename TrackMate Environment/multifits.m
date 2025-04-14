function [fitCell] = multifits(x,y, shoulders, tophat, tau)
% Creates alogirthmically optomized curves fits for a scatterplot.


% It takes two input column vectors and fits a curve to the
% scatterplot of these vectors. Shoulders defines the place where the first
% Gaussian function should start. Overlap defines how much overlap there
% should be between exponential and wide gaussian functions. tophat
% determines the range considered as part of the "spike" FitTypes really
% isn't in use yet and should be messed with at this time.

% It has the following nested functions, calling other nested functions.

% Analyfit checks the plot's error then plots it.
% fit test returns GOF for optomization as efficiently as possible.

% The following nested functions perform indpendent functions in the code.

% SafeTest checks that params don't cause any issues with data analysis.
% ZoneComp creates the zones for each fit to apply to.
% MasterFitter creates fits based on these zones and returns a GoF measure.

arguments
    x {iscolumn}
    y {iscolumn}
    shoulders {isrow} = [-0.7,0.7]
    tophat {isrow} = [-0.15 0.15]
    tau = []
end
start_param = [shoulders, tophat];
%% Parameters
% mp defines the midpoint used for symmetric data.
mp=0;

% Our optomization method is fminsearch, which gets stuck at local minima.
% We therefore use perturbations to avoid this issue.

% Number of starting points. More take longer but try to optomize over
% larger range of starting positions.
ShoulderRange = 6;
HatRange = 4;
% Size of starting perturbations. Should be small so the function is likely
% to thoroughly search the area.
s_iter_mag = 0.1;
h_iter_mag = 0.025;

% disallows zones to get squeezed narrower than this. Setting this too low
% will cause errors, as fit() will be attempted over insufficient domains.
% Used by SafeTest.
safeZone = 0.1;


% These determine the fit types used by analyfit and compfit
gfit = fittype('gauss1');
expfit = fittype('exp1');

% The following option enables/disables plotting all improved error graphs.
plotImprovements = false;

%% Input Checks
start_zones = ZoneComp(start_param);
if size(x) ~= size(y)
    error("Please make x and y column vectors of the same length")
elseif sum(isnan(x))~=0||sum(isnan(y))~=0
    error("There are NaN values in the inputs.")
elseif not(SafeTest(start_param, start_zones))
    error("Invalid initial parameters.")
end


%% Initial analysis
if length(start_param) == 4
    shoulder_bot = start_param(1,1);
    shoulder_top = start_param(1,2);
    hat_bot = start_param(1,3);
    hat_top = start_param(1,4);
end

figure()
[InitFits,InitSSR]=analyFit(start_param);

if ~isempty(tau)
    titletxt = strcat("\tau = ", string(tau), " Blind Fitting Attempt");
else
    titletxt = '  Blind Fitting Attempt';
end
title(titletxt)


%% Optomization
options = optimset('TolX',1e-4);

nsteps = (2*ShoulderRange+1)*(2*HatRange+1);
counter=0;
bestSSR = Inf;
bestParams = start_param; % this will prevent errors if nothing beats initial settings

% To combat local minima, try  evenly spaced starting points around the
% initial guesses
for i = -ShoulderRange:ShoulderRange

    for j = -HatRange:HatRange
        counter=counter+1;
        fprintf(strcat("Optomization ", string(floor(100*counter/nsteps)), " pcnt complete   \r"));
        
        if length(start_param) == 4
            randTophat(1,1) = hat_top - h_iter_mag*j;
            randTophat(1,2) = hat_bot+h_iter_mag*j;
            randShoulders(1,1) = shoulder_bot - s_iter_mag*i;
            randShoulders(1,2) = shoulder_top +s_iter_mag*i;
            initParams = [randShoulders, randTophat];
        else
            initParams = [start_param(1)+s_iter_mag*i,  start_param(2)+ h_iter_mag*j];
        end

        % Optomization occurs here!
        [optParams, optSSR] = fminsearch(@fit_test, initParams, options);

        % If the fit is better, plot it. This can be turned off in params.
        if (optSSR < bestSSR)
            bestSSR = optSSR;
            bestParams = optParams;
            if plotImprovements
                figure()
                [~, ~] = analyFit(bestParams);
                title(strcat("i=" ,string(i), "   j=",string(j)))
            end
        end
    end
    % Run fminsearch with this new initialization Keep track of the best
    % solution
end

figure()
[FinalFits,FinalSSR] = analyFit(bestParams);
titletxt2 = strcat('Optimized Fit.', ' Improvement of ',string(InitSSR-FinalSSR'));

if ~isempty(tau)
    titletxt2 = strcat("\tau = ", string(tau), "  ", titletxt2);
end

title(titletxt2);

fitCell{1,1} = InitFits;
fitCell{1,2} = InitSSR;
fitCell{1,3} = start_param;
fitCell{2,1} = FinalFits;
fitCell{2,2} = FinalSSR;
fitCell{2,3} = bestParams;

    function err = fit_test(params)
        % Input is a param (a row vector) Output is error measurement

        % This function finds the sum of squared residuals for after
        % fitting the given functions to the requested domains. It is
        % designed to be called by fminsearch to minimize ssr by adjusting
        % params It operates similarly to analyFit, but without the extra
        % steps uneeded for this task.
        
        % Check input parameters for validity and sufficient spacing.
        [Zones, ~] = ZoneComp(params);
        SafeT = SafeTest(params, Zones);
        
        % if the parameters pass, test it!
        if SafeT
            [~, err] = MasterFitter(Zones);
        else
            % If we get a bad parameter input, return infinite error. This
            % avoids insufficient data errors and/or hopefully nonsense
            % fits.
            % If fit() returns an error due to insufficient data, something
            % is wrong with SafeTest, as it should check for that.
            err = inf;
            return;
        end
    end

    function [fits, PlotSSR]=analyFit(params)
        %% Computations
        % Fits and plots based on Shoulders, Tophat.

        %
        % % create fits, excluding everything not in thier zone. The
        % exception % is f.Mid, which must exclude anything in the tophat
        % zone as well % as everything not in thier zone f.Low =
        % fit(x,y,expfit, 'Exclude', ~Zones.Low); f.Mid = fit(x,y, gfit,
        % 'Exclude', (~Zones.Mid)); fHat = fit(x,y,gfit, 'Exclude',
        % ~Zones.Hat); fHigh = fit(x,y, expfit, 'Exclude',~Zones.High);
        % resLow = y(Zones.Low) - feval(f.Low, x(Zones.Low)); resMid =
        % y(Zones.Mid & ~Zones.Hat) - feval(f.Mid, x(Zones.Mid &
        % ~Zones.Hat)); resHigh = y(Zones.High) - feval(fHigh,
        % x(Zones.High)); resHat = y(Zones.Hat) - feval(fHat,
        % x(Zones.Hat)); Save the fits to the output cells
        [Zones, Lin] = ZoneComp(params);

        SafeT = SafeTest(params, Zones);
        % Check input parameters for validity and sufficient spacing.
        if SafeT
            % if the parameters pass, test it!
            
            [fits, err] = MasterFitter(Zones);
        else
            fits=struct();
            PlotSSR = inf;
            warning('attempted to plot bad params. should not happen.')
            return;
        end

        % Evaluate the fitted functions across thier respective domains so
        % we can plot them.
        evalLow = feval(fits.Low, Lin.Low);
        evalMidL = feval(fits.Mid,  Lin.MidL);
        evalMidH = feval(fits.Mid,  Lin.MidH);
        evalHat = feval(fits.Hat,  Lin.Hat);
        evalHigh = feval(fits.High,  Lin.High);

        % compute the sum of the squred residuals (ssr) to provide an
        % metric for goodness of fit.

        PlotSSR = err;

        %% plotting
        % Set up the plot
        hold on
        yscale('log')
        axis([min(x) max(x) 10^-5 1]);
        xlabel('\Delta x (microns)')
        ylabel('P(\Delta x)')

        % Labelthe plot with the ssrs
        subtitle(strcat("residuals =", string(PlotSSR)))

        % Plot everything
        scatter(x,y)
        plot(Lin.Hat, evalHat, 'LineWidth',2, 'Color','black');
        plot(Lin.MidL, evalMidL, 'LineWidth',2, 'Color','red');
        plot(Lin.MidH, evalMidH, 'LineWidth',2, 'Color','red');
        plot(Lin.Low, evalLow, 'LineWidth',2);
        plot(Lin.High, evalHigh, 'LineWidth',2);

        hold off
    end

    function [Zones, Lin] = ZoneComp(params)
        % This function uses params for zones
        if ~isrow(params)
            error('params must be a row vector of length two or four')
        end
        %% Asymmetric settings
        if length(params)==4
            % outputs zones set by whatever the user sets the bounds to.
            sb = params(1:2); % shoulder bounds
            hb = params(3:4); % tophat bounds
            Zones.Low = x < sb(1);
            Zones.Mid = x >= sb(1) & x <= sb(2);
            Zones.High = x > sb(2);
            Zones.Hat = x > hb(1) & x < hb(2);
            Zones.Mid = (x >= sb(1) & x <= sb(2)) & ~Zones.Hat;

            Lin.MidL=linspace(sb(1), hb(1));
            Lin.MidH = linspace(hb(2), sb(2));
            Lin.Hat=linspace(hb(1), hb(2));
            Lin.Low=linspace(min(x), sb(1));
            Lin.High=linspace(sb(2), max(x));
            %% Symmetric Settings
        elseif length(params)==2
            % outputs zones whcih are symmetrical about the midpoint
            sw = abs(params(1)); % tophat radius
            hw = abs(params(2)); % shoulder radius
            % Uses midpoint from main section.
            Zones.Low = (x < (mp-sw));
            Zones.High = (x > (mp+sw));
            Zones.Hat = x > (mp-hw) & x < (hw+mp);
            Zones.preMid = x >= (mp-sw) & x <= (mp+sw);
            Zones.Mid = Zones.preMid & ~Zones.Hat;

            Lin.MidL=linspace(mp-sw, mp-hw);
            Lin.MidH = linspace(mp+hw, mp+sw);
            Lin.Hat=linspace(mp-hw, mp+hw);
            Lin.Low=linspace(min(x), mp-sw);
            Lin.High=linspace(mp+sw, max(x));
        else
            error('params must be of length two or four')
        end
    end

    function SafeT = SafeTest(params, Zones)
        % Inputs: params row vector

        % Ouputs: SafeT boolean value which attempt to predict if a given
        % params input will cause errors or be nonsense (i.e. overlapping,
        % out of order, etc.) Returns true for valid params.

        % If issues persist, recode this to run ZoneComp to check if there
        % are sufficient points over a specific domain.

        if length(params)==4
            
            % Ensure valid parameter ordering during optomization by
            % returning infinite error if the boundaries get offset to
            % problematic values.
            expShoulder = params(1:2);
            expTophat = params(3:4);
            botBorderTest= expShoulder(1) >= expTophat(1)+safeZone;
            hatSizeTest = expTophat(2)- expTophat(1)<safeZone;
            topBorderTest = expTophat(2)+safeZone >= expShoulder(2);
            BorderTest = botBorderTest||topBorderTest;
            floorTest = (mp + expShoulder(2))< (min(x) + safeZone*1);
            ceilTest = expShoulder(2)+mp+safeZone>= max(x);
            
            % if any test fails, return false
            if (floorTest||hatSizeTest ||BorderTest||ceilTest)
                SafeT = false;
                return;
            else
                SafeT = true;
            end
        elseif length(params)==2
            floorTest = (mp - params(1))< (min(x) + safeZone*1);
            BorderTest = params(1)<=params(2)+safeZone;
            hatSizeTest = params(2)*2 < safeZone;
            ceilTest = mp+params(1)+safeZone >= max(x);
            % kills any runaway process where the limits get too low
            % meaning either the hat is too narrow or the gaussian is too
            % near to the hat
            if  (floorTest||BorderTest|| hatSizeTest || ceilTest)
              
                SafeT = false;
                return;
            else
                SafeT = true;
            end
        else
            SafeT = false;
            return;
        end
        
        % Manual Zone Data Container Check
        % Ensures there are at least 3 datapoints per zone
        LowChk = (sum((Zones.Low .*y)>0))<=2;
        MidChk = (sum((Zones.Mid .*y)>0))<=2;
        HighChk =sum((Zones.High .*y)>0)<=2;
        HatChk = sum((Zones.Hat .*y)>0)<=2;

        if LowChk||MidChk||HighChk||HatChk
            SafeT=false;
        end

    end

    function [f, err] = MasterFitter(Zones)
        % Fit the functions everywhere except where they aren't active.
        f.Low = fit(x,y,expfit, 'Exclude', ~Zones.Low);
        f.Mid = fit(x,y, gfit, 'Exclude', ~Zones.Mid);
        f.Hat = fit(x,y,gfit, 'Exclude', ~Zones.Hat);
        f.High = fit(x,y, expfit, 'Exclude',~Zones.High);

        % Create masks of each function by evaluating them over the domain
        % and then multiplying them element-wise by thier zones, which are
        % zero everywhere except for where they should be active
        LowMask = feval(f.Low, x).*Zones.Low;
        MedMask = feval(f.Mid, x).*Zones.Mid;
        HighMask = feval(f.High, x).*Zones.High;
        HatMask = feval(f.Hat, x).*Zones.Hat;

        % Concatenate the column vectors along narrow (row) dimension.
        % Without overlaps, each should only be active where all others are
        % zero.
        StackedMask = cat(2,LowMask,MedMask,HighMask,HatMask);

        % Sum the rows to produce a single vector of values.
        fulleval = sum(StackedMask,2);

        % Find the error. Currently set to use normalized residuals to
        % avoid ignoring small residuals from the wings which have very
        % small magnitude.
        
        % Introduced log to fix other weighting issues. Not sure if it does
        % well or not. Likely needs to be revised!

        % I think this is the best method. An X% decrease in the gap
        % between y and y' prodcues the same reduction in residual 
        % regardless of their order of magnitude.
        resid = log10(abs((y-fulleval)));

        % OTHER WAYS TO DO THIS??
        % resid = log10(abs((y-fulleval))./y);
        %  resid = abs((y-fulleval))./y);
        % resid = y-fulleval
        % What others?

        err = sum(resid);
    end
end