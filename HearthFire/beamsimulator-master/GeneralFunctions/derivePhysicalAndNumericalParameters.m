%% set physical and numerical parameters

%% set constants

True=1;
False=0;

%% set physical parameters
disp('***** Derving Physical Parameters *****')

phys_par.l_med = phys_par.l_0 / phys_par.n_med;     % wavelength in medium
phys_par.k_0 = 2 * pi / phys_par.l_0;               % k-vector in freespace [�m^-1]
phys_par.k_med = phys_par.k_0 * phys_par.n_med;     % k-vector in medium

%% numerical parameters
disp('***** Deriving Numerical Parameters *****')

num_par.dy = phys_par.l_med/num_par.l_pixel;        % scaling (�m/pixel) - determined by wavelength in medium!!
                                                    % corresponds to spatial resolution dx

num_par.dk = 2*pi/num_par.pad_y_array_size/num_par.dy;      % resolution in k-space

num_par.k_max = (num_par.pad_y_array_size-2)/2*num_par.dk;  % max k-value that will be included in the analysis (after fft-shift)
                                                        % i.e. we will analyze k-values from -k_max ... k_max+dk
num_par.y_max = (num_par.pad_y_array_size-2)/2*num_par.dy;  % the same holds for position space

num_par.dx = num_par.scale_dx*num_par.dy;       % step size for the propagator


if flags.sym
    num_par.x_max = (num_par.x_array_size-1)*num_par.dx; 
else
num_par.x_max = (num_par.x_array_size-2)/2*num_par.dx;    % plot from -z_max ... -z_max+dz (see above)
end
%%
disp(['Lateral array Size: ' num2str(num_par.y_array_size) ' x ' num2str(num_par.y_array_size) ' pixels = ' num2str(num_par.y_array_size*num_par.dy) ' x ' num2str(num_par.y_array_size*num_par.dy) ' �m'])
disp(['Axial array Size: ' num2str(num_par.x_array_size) ' pixels = ' num2str(num_par.x_array_size*num_par.dx) ' �m'])
disp(['Lambda in medium: ' num2str(num_par.l_pixel) ' pixels = ' num2str(phys_par.l_med)])
disp(['NA: ' NA])
disp(['Excitation type: ' excitation])
