function v = visc_ps(f, ps, a, cutoff)
% VISC_PS computes the viscosity of a solution using the power spectrum of stage/bead translation from the 3DFM
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford)
%
% This function computes the viscosity of a solution using the 
% power spectrum of stage/bead translation from the 3DFM.
%
% v = visc_ps(f, psd, bead_radius, cutoff);
%
% where:  f = frequency vector in [Hz]
%         psd = power spectra of bead-position in [m^2/Hz]
%         bead_radius = bead radius in [m]
%         cutoff = cutoff frequency for linear-fit in [Hz]
%   

% constants
k = 1.38e-23;
T = 298;

% determine if first frequency is zero
% if so, omit it
if f(1) == 0
    f = f(2:end,1);
    ps=ps(2:end,1);
end

% cutoff section of data I don't want (i.e. not linear)
data = find(f<=cutoff);
f = f(data);
ps = ps(data);

% Take log transform
f = log10(f);
ps= log10(ps);

p = polyfit(f, ps, 1);
fit = polyval(p, f);

B = p(2);
n = (k * T) / (6*pi^3*10^B*a);

n_water = 0.001;  % Pa sec
n_karo  = 1.6; % Pa sec

Bwater = log10( (k*T) / (6*pi^3*a*n_water) );
Bkaro  = log10( (k*T) / (6*pi^3*a*n_karo)  );
water = Bwater - 2*f;
karo = Bkaro - 2*f;

figure; 
plot(f, [ps fit], f, water, '--k', f, karo, '--r');
% axis([min(f) max(f) -17 -13]);
xlabel('log_{10}(frequency [Hz])');
ylabel('log_{10}(Power [m^2/Hz])');
legend('sample ps', 'sample fit', 'water fit', 'karo fit (1.6)');
pretty_plot;


v.visc = n;
v.slope = p(1);
v.icept = p(2);
