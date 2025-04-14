function [fits] = multifits_manual(x,y, shoulders, overlap, tophat, FitTypes)
% DEPRICATED--USE MULTIFITS INSTEAD!


% This function takes two column vectors as x and y inputs.
% Shoulders defines the place where the first Gaussian function should
% start.
% Overlap defines how much overlap there should be between exponential and
% wide gaussian functions.
% tophat determines the range considered as part of the "spike"
% FitTypes really isn't in use yet and should be messed with at this time.
arguments
    x {iscolumn}
    y {iscolumn}
    shoulders {isrow} = []
    overlap {double} = 0
    tophat {isrow} = [-0.15 0.15]
    FitTypes = ["exp1", "gauss1", "exp1"];
end
warning("This code is depricated. Methods are unreliable and of poor quality. Use multifits instead.")
gfit = fittype('gauss1');
expfit = fittype('exp1');
inLow = x< shoulders(1);
inMid = x<=shoulders(2) & x>=shoulders(1);
inHigh = x>shoulders(2);
inHat = and(x>tophat(1),x<tophat(2));

fLow = fit(x,y,expfit, 'Exclude', ~inLow);
fMid = fit(x,y, gfit, 'Exclude', (~inMid & inHat));
fHigh = fit(x,y, expfit, 'Exclude',~inHigh);
fHat = fit(x,y,gfit, 'Exclude', ~inHat);


linMidL=linspace(shoulders(1), tophat(1));
linMidH = linspace(tophat(2), shoulders(2));
linHat=linspace(tophat(1), tophat(2));
linLow=linspace(min(x), shoulders(1));
linHigh=linspace(shoulders(2), max(x));


evalLow = feval(fLow, linLow);
evalMidL = feval(fMid, linMidL);
evalMidH = feval(fMid, linMidH);
evalHat = feval(fHat, linHat);
evalHigh = feval(fHigh, linHigh);

%% Plotting
hold on
scatter(x,y)
yscale('log')

% plot(fLow)
% plot(fMid)
% plot(fHigh)



plot(linHat, evalHat, 'LineWidth',2, 'Color','black');
plot(linMidL, evalMidL, 'LineWidth',2, 'Color','red');
plot(linMidH, evalMidH, 'LineWidth',2, 'Color','red');
plot(linLow, evalLow, 'LineWidth',2);
plot(linHigh, evalHigh, 'LineWidth',2);


if overlap ~=0
    LOver=linspace(shoulders(1)-overlap, shoulders(1)+overlap);
    HOver=linspace(shoulders(2)-overlap, shoulders(2)+overlap);
    LOverEval = feval(fLow,LOver)+feval(fMid,LOver);
    HOverEval = feval(fMid,HOver)+ +feval(fHigh,HOver);

    plot(LOver,LOverEval, 'LineWidth',2,'Color','red');
    plot(HOver, HOverEval, 'LineWidth',2, 'Color','red');
end

axis([min(x) max(x) 10^-5 1]);
xlabel('\Delta x (microns)')
ylabel('P(\Delta x)')

hold off

fits{1} = fLow;
fits{2} = fMid;
fits{3}= fHigh;
fits{4} = fHat;

end