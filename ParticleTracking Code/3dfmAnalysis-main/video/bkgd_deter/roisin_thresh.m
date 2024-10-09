function [adj_threshold]= roisin_thresh(filepath,adj)

%threshold image using roisin threshold technique
%filepath is the location of the image to threshold, or an image item,
%adj is the fraction of the tail length (a value between 0 and 1) that will
%be added to the threshold
%outputs: ints_cut is the intensity that is determined as a cut off,
%threshold is the raw calculated threshold, and adj_threshold is the
%threshold after the adjustmnet factor.

if nargin<2|| isempty(adj)
    adj=.1;
end


%get image depth and set histogram bins based on that
if isnumeric(filepath)
    imtemp=filepath;
    if isa(imtemp, 'uint8')
        bit = 8;
    elseif isa(imtemp, 'double')
        imtemp = uint8(imtemp*255);
        bit = 8;
    elseif isa(imtemp, 'uint16')
        bit = 16;
    else
        error('Image type or bit-depth unknown.');
    end        
else %is file
    imtemp=imread(filepath);
    picinfo = imfinfo(filepath);
    bit = picinfo.BitDepth;
end

% sometimes the input doesn't have a large enough dynamic range (or large
% enough number of unique elements to extract a viable smoothed histogram.
% To solve this issue, we add bits of noise until we can get non-zero
% signale from the medfilt1 function
trigger = 0;
noise_level = 50;
im_clean = imtemp;
while ~trigger  
    if bit==16
      [pixelCounts bins] = imhist(imtemp,5000);
    else
      [pixelCounts bins] = imhist(imtemp,256);
    end
    
%     pixelCounts( bins <= noise_level ) = 0;
    
    smoothedHist = medfilt1(pixelCounts, 3);
    
    if sum(smoothedHist) <= 0
        noise_level = noise_level + 1

        noise = uint8(randint(512,512, [0 noise_level]));
        imtemp = im_clean + noise;
%         imtemp( imtemp(:) < noise_level ) = 0;
        
        if noise_level >= 64 % arbitrarily setting it to 64 here to avoid infinite loop
            error('Cannot generate a smoothed histogram.');
        end
    else
        trigger = 1;
    end
    

    
end



[peak_max, pos_peak] = max(smoothedHist); 
topPoint=[pos_peak,peak_max];
ind_nonZero=find(smoothedHist>0);
last_zeroBin=ind_nonZero(end);
bottomPoint=[last_zeroBin,smoothedHist(last_zeroBin)];

best_idx = -1; 
max_dist = -1; 
for x0 = pos_peak:last_zeroBin 
    y0 = smoothedHist(x0); 
    a = topPoint - bottomPoint; 
    b = [x0,y0] -bottomPoint; 
    cross_ab = a(1)*b(2)-b(1)*a(2); 
    d = norm(cross_ab)/norm(a); 
    if(d>max_dist) 
        best_idx = x0; 
        max_dist = d; 
    end 
end
   

%accounts for bin size
if bit ==8
        ints_cut=best_idx;
        level=ints_cut/256;
elseif bit==16
        ints_cut=best_idx*13.1;
        level=ints_cut/65537;  
end


% calc threshold
  maxPixel=double(max(imtemp(:)));
  minPixel=double(min(imtemp(:)));
  threshold=(ints_cut)/((maxPixel-minPixel)+minPixel);
 
  
% possible adjustments
if bit ==16
   flat_length=maxPixel/13.1-best_idx;
   new_idx=best_idx+flat_length*(adj);
   adj_threshold=(new_idx*13.1)/((maxPixel-minPixel)+minPixel);
elseif bit ==8
    flat_length=maxPixel-best_idx;
    new_idx=best_idx+flat_length*adj;
    adj_threshold=(new_idx)/((maxPixel-minPixel)+minPixel);
end   
% find mask

param_struct.fluorescent_spot_threshold=adj_threshold;
create_cfg(param_struct, 'lai');

% debug figure
 mask = im2bw(imtemp, level);
 mask = bwareaopen(mask, 4);

figure;

subplot(2,2,1);
bar(bins, smoothedHist);
title('Smoothed Histogram');
xlabel('intensity');
ylabel('pixelCount');

subplot(2,2,2);
im=imagesc(mask);
colormap(gray(256));
title('Mask');

subplot(2,2,3);
imagesc(im_clean);
colormap(gray(256));
title('Original image');

subplot(2,2,4);
imagesc(imtemp);
colormap(gray(256));
title('Orig image + noise');

 

 
    
