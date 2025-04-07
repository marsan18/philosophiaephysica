%% INTRODUCTION
% This file designed to do a simple deconvolution based on the method from 
% Angle_Callibration_v2.m

% COORDINATES OF PSF


%% LOADING FILE
% main_folder = 'C:\Users\Alexander Marshall\Desktop\All_inclusive_images_Cropped'; 
main_folder = uigetdir; % Can use this instead of directory
myFiles = dir(main_folder);
filenames = {myFiles.name};
mask = endsWith(filenames, {'.tif', '.tiff'}, 'IgnoreCase', true);
ListOfImages = filenames(mask);
num_entries = length(ListOfImages);


for i=1:num_entries
    img = tiffreadVolume(strcat(main_folder, '\', string(ListOfImages(i))));    
end

% NORMALIZE INTENSITY so that we max out at brightest possible value
multiplier=((2^16)-1)/max(max(max(img)));
img=img*multiplier;


%% Deconvolution!
% In this section we attempt deconvolving the sample.
% I will try both ithe blind deconvolution and later will implement a more
% realistic  PSF.
% NOTE PSFs MUST BE NORMALIZED TO FUNCTION CORRECTLY
PSFi = ones(21,21);
PSF_airy = PSFi;
R = zeros(length(PSFi), length(PSFi));

img=double(img); % Attempting to resolve issues with double vs int16
% Must manually set PSF coordinates in stack
% PSF area is 10X10

PSF_manual=img((Coords(1)-10):(Coords(1)+10),(Coords(2)-10):(Coords(2)+10),Coords(3));
PSF_manual_norm=PSF_manual/sum(sum(PSF_manual));

%AIRY BEAM GENERATOR
% FitFactor=1.8;
%     for j=1:size(PSFi,1)
%         for k = 1:size(PSFi,2)
%             center=fix((size(PSFi,1))/2)+1;
%             r=sqrt((j-center)^2+(k-center)^2)*FitFactor;
%             R(j,k) = pi*r*back_aperture/planar_pixelsize/(1000*WL*focal_length);
%             if R(j,k)==0
%                 R=R+.000001; % gotta add something to avoid NaN error.
%             end
%             disp(R(j,k))
%             PSF_airy(j,k) = (2*FitFactor*besselj(1,R(j,k))./R(j,k))^2;
%         end
%         PSF_airy_norm = PSF_airy/sum(sum(PSF_airy));
%         Diff(FitFactor.*10)=sum(sum(abs(PSF_airy_norm-PSF_manual_norm)));
%     end

% Attempting to resolve issues
% Normalize my PSFs


img_blind_decon(:,:,:) = ones(size(img,1), size(img,2), size(img,3));
img_test_decon(:,:,:) = ones(size(img,1), size(img,2), size(img,3));
img_test_decon_lucy(:,:,:) = ones(size(img,1), size(img,2), size(img,3));
for i=1:length(zList)
    [img_blind_decon(:,:,i), PSF_blind] = deconvblind(img(:,:,i), PSFi);
    % img_test_decon(:,:,i) = deconvreg(img(:,:,i), PSF_airy_norm); 
    img_test_decon_lucy(:,:,i) = deconvlucy(img(:,:,i), PSF_manual_norm);
end

