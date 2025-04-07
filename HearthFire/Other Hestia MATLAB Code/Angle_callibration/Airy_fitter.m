%% AIRY BEAM FITTER
tic
FitFactor=4;
stepsize=.001
for FitFactor = 1:10000
    for j=1:size(PSFi,1)
        for k = 1:size(PSFi,2)
            center=fix((size(PSFi,1))/2)+1;
            r=sqrt((j-center)^2+(k-center)^2)*stepsize*FitFactor;
            R(j,k) = pi*r*back_aperture/planar_pixelsize/(1000*WL*focal_length);
            if R(j,k)==0
                R=R+.000001; % gotta add something to avoid NaN error.
            end
            PSF_airy(j,k,FitFactor) = (2*.001*besselj(1,R(j,k))./R(j,k))^2;
        end
        PSF_airy_norm(:,:, FitFactor) = PSF_airy(:,:,FitFactor)/sum(sum(PSF_airy(:,:,FitFactor)));
        
    end
end
for delta=1:100
    DIFF(:,:,delta)=(PSF_airy_norm(:,:,delta)-PSF_manual_norm).^2;
end
SumDIFF =sum(sum(DIFF));
[minimum, FitIndx]= min(SumDIFF);
FitFactorAdj = FitIndx*stepsize
toc
% BESTLAYER, BESTDIFF=min