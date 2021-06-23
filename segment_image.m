function [seg]=segment_image(I)
% This function takes an input image I in jpeg and segments it.
% The process is done by convolving the image with multiple Gabor masks.
% The function for Gabor2 below the segment function was from the
% coursework for Week 4. 
% The result is then segmented with the k-means clustering.
% Following that, the image goes through edge detection to find boundaries.
% Then the image goes through Gaussian filtering to remove some of the noise.
% Finally, the resulting image is binarized. 
% References:
% Dr Michael Spratling, King's College London. Gabor2.m. https://keats.kcl.ac.uk/course/view.php?id=86410
Itest=I;
Itest=rgb2gray(im2double(imread(I)));
maximum=0;
for v=[0,15,30,45,60,75,90,105,120,135,150,165]
    mask=gabor2(0.8,1.5,v,0.75,0);
    mask1=gabor2(0.35,1.5,v,0.75,90);
    
    conv=conv2(Itest,mask,'same');
    conv1=conv2(Itest,mask1,'same');
    
    L2_norm = sqrt((conv.^2)+(conv1.^2));
    
    maximum = max(maximum,L2_norm);
    old_norm=L2_norm;
end
old_norm=im2uint8(old_norm);
%k means of L2 norm
km=imsegkmeans(old_norm,3,'NumAttempts',150);
Icon=im2uint8(km);
Ibin=imbinarize(Icon,'adaptive');
Icon=im2uint8(Ibin);
%Canny edge detection of clustered image.
Icanny=edge(Icon,'Canny',0.5,3);
Icon=im2uint8(Icanny);
%Gaussian filtering on edge detected image.
Igfilt=imgaussfilt(Icon,1);
Icon=im2uint8(Igfilt);
%Binarizing the image for output.
Ibin=imbinarize(Icon,'adaptive');
%seg returns the binarize
seg=Ibin;
%Image output was used for testing, has been commented out here.
%figure (1), clf
%imshow(seg)

function gb=gabor2(sigma,freq,orient,aspect,phase)
%function gb=gabor2(sigma,freq,orient,aspect,phase)
%
% This function produces a numerical approximation to 2D Gabor function.
% Parameters:
% sigma  = standard deviation of Gaussian envelope, this in-turn controls the
%          size of the result (pixels)
% freq   = the frequency of the sin wave (1/pixels)
% orient = orientation of the Gabor from the vertical (degrees)
% aspect = aspect ratio of Gaussian envelope (1 = circular symmetric envelope,
%          lower values produce longer functions)
% phase  = the phase of the sin wave (degrees)

sz=fix(7*sigma./max(0.2,aspect));
if mod(sz,2)==0, sz=sz+1; end
 
[x y]=meshgrid(-fix(sz/2):fix(sz/2),fix(-sz/2):fix(sz/2));
 
% Rotation 
orient=orient*pi/180;
xDash=x*cos(orient)+y*sin(orient);
yDash=-x*sin(orient)+y*cos(orient);

phase=phase*pi/180;

gb=exp(-.5*((xDash.^2/sigma^2)+(aspect^2*yDash.^2/sigma^2))).*(cos(2*pi*xDash*freq+phase));

%ensure gabor sums to zero (so it is a valid differencing mask)
gbplus=max(0,gb);
gbneg=max(0,-gb);
gb(gb>0)=gb(gb>0)./sum(sum(gbplus));
gb(gb<0)=gb(gb<0)./sum(sum(gbneg));

