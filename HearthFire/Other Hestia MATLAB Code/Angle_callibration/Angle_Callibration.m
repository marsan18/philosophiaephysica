%% README
% I advise commenting out any figures not in use, as figure generation is
% computationally quite intensive and drastically slows the program.
%% IDEAS 
% First we need to import tiffs.
% We start from a folder of only .tiff files which are named in the
% convention ###_....tif. We create a list of file names only. 
% Then we check the first 3 digits of each file and create a 3 column
% matrix binding those digits in ascending order to its relative position
% (file 1 # - file n #) and file name. 
% We then create a 3D matrix of zeros with width(image width), 
% length(image length) and height (zmax-zmin). We then load in each file 
% into the next layer of the stack sequentially by relative position. If no
% file relative position matches a layer number, we keep it as 0s. 
% main_folder = 'C:\Users\Alexander Marshall\Desktop\Images Only Cropped';
clc
clear 'all' %#ok<CLALL>
close 'all'
tic()
%% Parameters
ROI_X = [10:20]; 
% This must be selected to be smaller than picture width
% zStart = 440; % Not in use
% zEnd = 475; % Not in use
% zList should eventually be auto-generated from file names.
zList = [440, 445, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 475];
% Eventually can meshgrid ZList with Y,Z axes.
planar_pixelsize = 0.110987791; %um
WL = 561*10^-3; % Wavelength of excitation light in microns
NA = 1.5; % NA of Objective
n_RI=1.5; % Refractive Index
back_aperture=9700; %in um
back_aperture_pixels=back_aperture/planar_pixelsize; % in pixel widths
focal_length=3333; %in microns

use_decon_lucy= 'True'; % determine if we use the deconvolved or regular image in graphs.

%FOLDER SELECTION
main_folder = 'C:\Users\Alexander Marshall\Desktop\All_inclusive_images_Cropped'; 
% main_folder = uigetdir; % Can use this instead of directory
myFiles = dir(main_folder);

%% FILE LOADER AND CHECKER
% Assumes files are rotated to desired orientation!
% For individual TIFFs, uncomment the following
% for i=1:num_entries
%     img(:,:,i) = imread(strcat(main_folder, '\', string(ListOfImages(i))));
% end
% img_profile(:,:,1) = sum(img, 1);
% Note this does not account for actual z-coordinates unless proceeding by
% 1um
% for TIFF-STACKS, uncomment the following
filenames = {myFiles.name};
mask = endsWith(filenames, {'.tif', '.tiff'}, 'IgnoreCase', true);
ListOfImages = filenames(mask);
num_entries = length(ListOfImages);


for i=1:num_entries
    img = tiffreadVolume(strcat(main_folder, '\', string(ListOfImages(i))));
end
multiplier=((2^16)-1)/max(max(max(img)));
img=img*multiplier;

img_profile(:,:,1) = sum(img, 1);
%% Deconvolution!
% In this section we attempt deconvolving the sample.
% I will try both the blind deconvolution and later will implement a more
% realistic  PSF.
% NOTE PSFs MUST BE NORMALIZED TO FUNCTION CORRECTLY
PSFi = ones(21,21);
PSF_airy = PSFi;
R = zeros(length(PSFi), length(PSFi));

img=double(img); % Attempting to resolve issues with double vs int16
PSF_manual=img(572:592,382:402,17);
PSF_manual_norm=PSF_manual/sum(sum(PSF_manual));

%% AIRY BEAM GENERATOR

FitFactor=1.8;
    for j=1:size(PSFi,1)
        for k = 1:size(PSFi,2)
            center=fix((size(PSFi,1))/2)+1;
            r=sqrt((j-center)^2+(k-center)^2)*FitFactor;
            R(j,k) = pi*r*back_aperture/planar_pixelsize/(1000*WL*focal_length);
            if R(j,k)==0
                R=R+.000001; % gotta add something to avoid NaN error.
            end
            disp(R(j,k))
            PSF_airy(j,k) = (2*FitFactor*besselj(1,R(j,k))./R(j,k))^2;
        end
        PSF_airy_norm = PSF_airy/sum(sum(PSF_airy));
        Diff(FitFactor.*10)=sum(sum(abs(PSF_airy_norm-PSF_manual_norm)));
    end

% Attempting to resolve issues
% Normalize my PSFs


img_blind_decon(:,:,:) = ones(size(img,1), size(img,2), size(img,3));
img_test_decon(:,:,:) = ones(size(img,1), size(img,2), size(img,3));
img_test_decon_lucy(:,:,:) = ones(size(img,1), size(img,2), size(img,3));
for i=1:length(zList)
    [img_blind_decon(:,:,i), PSF_blind] = deconvblind(img(:,:,i), PSFi);
    img_test_decon(:,:,i) = deconvreg(img(:,:,i), PSF_airy_norm); 
    img_test_decon_lucy(:,:,i) = deconvlucy(img(:,:,i), PSF_manual_norm); 
    % This is quite bad
end

%% TO RUN FOR DECONVOLVED IMAGE, RESET IMG TO DECONVOLVED IMG
% if use_decon_lucy
%     img=img_test_decon_lucy;
% end

%% EXPERIMENTAL UNIFORM BACKGROUND REDUCTION
% Since background is mostly flat, just removes median pixel value from all
% columns. If the value of a columns drops below 0, we force it back up to
% 0.
% Is it better to do this for columns or pixels? idk. columns feels better
% due to averaging--doing this to pixels will result in a lot of noise.

img_profile(:,:,1) = sum(img, 1);
%% UNCOMMENT FOLLOWING TO REMOVE NOISE
img_profile = img_profile-median(img_profile,1);
for m=1:length(img_profile)
    for l = 1:size(img_profile,2)
       if img_profile(m,l)<0
           img_profile(m,l)=0;
       end
    end
end



if length(zList)~=size(img,3) & length(zList)>0
    error("The number of z-position indexes does not match  " + ...
        "the number of images. Please correct zList, or" + ...
        " leave it empty if you do not want indexing.")
end

if max(ROI_X)>length(img)
    error("Selected ROI is larger than image. Please choose a valid ROI.")
end

xList = 1:length(img_profile);
xList = xList * planar_pixelsize;
xListROI=xList(ROI_X);
img_profileROI=img_profile(ROI_X,:);






x = (1:length(img_profile)).';
for k = 1:size(img_profile,2)
    y= img_profile(:,k);
    IterFit=fit(x, y,'gauss2');
    GaussFit(:,k)= IterFit(x);
end


%% I'm going to apply a mask
% If values*multiplier <  % max(img_profile(:,k), they are set to 0.
mask_multiplier=2; %EXP for w_0, 2 for FWHM, ~7 for noise reduction, etc
masked = zeros(size(img_profile,1), size(img_profile, 2));
for l=1:size(img_profile,2)
    for m=1:length(img_profile)
        if img_profile(m,l)*mask_multiplier<=max(img_profile(:,l))
            masked(m,l) = 0;
        else
            masked(m,l) = 1;
        end
    end
end
masked_img_profile = img_profile.*masked;


masked_width=sum(masked);
masked_width_conv= (masked_width*planar_pixelsize);

for k = 1:size(img_profile,2)
    y= masked_img_profile(:,k);
    IterFitMasked=fit(x, y,'gauss2');
    GaussFitMasked(:,k)= IterFit(x);
end

% plot(img_profile)
% PLOT MAX LOCATION OF EACH STACK
[VAL, COORD]= max(img_profile);
Maxima=zeros(2,length(zList));
for k=1:length(zList) %The 24th value is strange! Look into this.
    Maxima(:,k) = [COORD(k),VAL(k)];
end
% This vector represents the angle from the maxima of the first value to
% the kth value in the stack. Worth checking out rather than just reading
% the last value in case something odd happens, as values should be relatively
% consistent throughout. Theta step does the same but is the angle from one
% datapoint to the next.
theta_step = zeros(1,length(zList));
theta = zeros(1, length(zList));
for k=2:length(zList) %Must start at 2, since must have a point and a previous point
    theta_step(k) = atand((((COORD(k)-COORD(k-1))*planar_pixelsize)/(zList(k)-zList(k-1))));
    % theta_step(k) is very noisy
    theta(k) = atand((((COORD(k)-COORD(1))*planar_pixelsize)/(zList(k)-zList(1)))); % Slice 24 is misbehaving so we use 23.
end

FWHM_max = zeros(size(img_profile,2));
FWHM_min = zeros(size(img_profile,2));
for k=1:size(img_profile,2) % FWHM COORD FINDER second method. 
% 1st method is better but this is fine.
    for l=1:length(img_profile) 
       
        % if img_profile(l,k) > (Maxima(1,k)/exp(1))
        %     waist(k)=l;
        % end
        if img_profile(l,k) >= max(img_profile(:,k))/2
            FWHM_max(k)=l;
        end
        %Same thing but R->L.
        if img_profile((length(img_profile)-(l-1)),k) >= max(img_profile(:,k))/2
            FWHM_min(k)=length(img_profile)-l;
        end
    end
end
FWHM = (FWHM_max - FWHM_min)*planar_pixelsize;

% Note algorithmic FWHM much larger than manual. Unsure why.
% something odd is happening. Masked_width_conv shoud be equal here but for
% some reason the two methods are offset by 2 pixels on the first 
% iterations. Unsure why this is. Even stranger, sometimes error is not
% present!
% Testing reveals this is slightly off of our manual version, but that is
% not particularly surprising, since manual version was slightly incorrect
% itself due to inconsistent "algorithm". I usually meausred distance
% between two that were closest to half of value, rather than using a 
% strict cutoff, so a pixel or so of disagreement is unsurprising.
disp(FWHM)
disp(masked_width_conv)
methodDelta=FWHM-masked_width_conv;
disp(methodDelta)
disp(theta)
disp(theta_step)
%% Beam Waist Theoretical Computations
% Currently configured to find beam waist 1/e rather than FWHM
% NOTE: NOT 100% Sure where to input the angle correction?? At w_0? or in
% output? W_0 effects z_R.
w_0 = .85*WL/(2*NA*.6)/cosd(theta(24));
z_R = pi*w_0^2*n_RI/WL;
[~,waist_indx] = min(masked_width_conv);
waist_indx = 13; %OVERRRIDE
RelZ=zList-zList(waist_indx);
w = w_0*sqrt(1+(RelZ/z_R).^2);

FWHM_predicted_adjusted=w*sqrt(log(2)*2); 

%% Figures: UNCOMMENT TO PLOT!
% 
% 
% % Figure 1 gives an accurately scaled (if pixel width is correct) volumetric graph of the image
fig1=figure();
% 
FullProfilePlot=surf(zList, xList, img_profile); %plots 3D lightsheet
FullProfilePlot.EdgeColor='interp';
FullProfilePlot.FaceColor="interp";
% 
% 
% % Figure 2 gives an accurately scaled volumetric graph of a user-specified ROI
% fig2=figure()
% ROIProfilePlot=surf(zList, xListROI, img_profileROI);; 
% ROIProfilePlot.EdgeColor='interp';
% ROIProfilePlot.FaceColor="interp";
% 
% xlabel('Objective Position (um)')
% xticks(zList)
% 
% ylabel('Relative Position in frame (um)')
% 
% zlabel('Pixel Intensity')
% 
% % Figure 3 gives 2D line plot
% fig3 = figure()
% LinePlot = plot(xList,img_profile);
% 
% 
% % Beam waist fig
% W0_plot = figure()
% w_extrap = (-Maxima(3,:)+waist())*planar_pixelsize
% plot(zList, w_extrap)
% title('beam waist')
% FWHM_plot = figure()
% plot(FWHM)
% title('FWHM')
% 
% % Gaussian Best fit fig
figure4 = figure();
GaussFitProfilePlot=surf(zList, xList, GaussFit);
GaussFitProfilePlot.EdgeColor='none';
GaussFitProfilePlot.FaceColor="interp";

% Gives another Gauss Best Fit Fig
% figure5 = figure()
% GaussFitMaskedProfilePlot=surf(zList, xList, GaussFit)
% GaussFitMaskedProfilePlot.EdgeColor='none'; 
% Plots the raw figure of the mask
% maskedfig=figure()
% MaskedFullProfilePlot=surf(zList, xList, masked_img_profile); %plots 3D lightsheet
% MaskedFullProfilePlot.EdgeColor='none';
% MaskedFullProfilePlot.FaceColor="interp";
% title("Masked")

% Plot FWHM Values
FWHM_fig = figure();
plot(zList, masked_width_conv)
hold on
plot(zList, FWHM_predicted_adjusted)
axis([min(zList) max(zList) 0 10])
legend( 'Actual','Predicted')
title('Predicted vs Actual FWHM profile ')
xlabel('objective height (um)')
ylabel('beam waist (um)')

unaltered=figure();
imshow(img(:,:,13)/(2^16-1))
decon_blind=figure();
imshow(img_blind_decon(:,:,13)/(2^16-1));
decon_airy = figure();
imshow(img_test_decon(:,:,13)/(2^16-1));
decon_lucy=figure();
imshow(img_test_decon_lucy(:,:,13)/(2^16-1));

PSF_airy_fig=figure();
imshow(PSF_airy);
toc()