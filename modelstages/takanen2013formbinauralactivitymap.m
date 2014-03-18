function [activityMap colorGains colorMtrx levels] = takanen2013formbinauralactivitymap(thetaL,thetaR,eL,eR,fs,fc,printFigs,printMap)
%TAKANEN2013FORMBINAURALACTIVITYMAP Steer the "what" cues on a topographic map using the "where" cues                 
%   Usage: [activityMap colorGains colorMtrx levels] = takanen2013formbinauralactivitymap(thetaL,thetaR,eL,eR,fs,fc,printFigs);
%
%   Input parameters:
%        thetaL    : "where" cue of the left hemisphere
%        thetaR    : "where" cue of the right hemisphere
%        eL        : "what" cue of the left hemisphere
%        eR        : "what" cue of the right hemisphere
%        fs        : sampling rate
%        fc        : characteristic frequencies
%        printFigs : boolean value describing whether the computations in
%                    *contralateralcomparison* are illustrated or not
%        printMap  : optional boolean value describing whether the
%                    resulting activity map is plotted (by default) or not. 
%
%   Output parameters:
%        activityMap : Matrix that describes in which of the six frequency
%                      ranges there is activation on a given location on
%                      the map at a specific time instant
%        colorGains  : Matrix that describes the signal level dependent
%                      gains for the different activation values on the
%                      activityMap
%        colorMtrx   : RGB color codes employed for the different frequency
%                      ranges on the binaural activity map
%        levels      : vector specifying the left/right location
%
%   This function takes as input the where cue values of the left and right
%   hemisphere and the respective what cues. The principle is to create an
%   image for each what cues on the map at locations specified by the where
%   cues, and to enhance the contrast between the hemispheres with a method
%   denoted as contralateral comparison. In each position of the map, there
%   is thought to exist several frequency-selective neurons. For
%   illustrative purposes, the frequencies are divided into six frequency
%   areas and different colors are used for each of them. In the resulting
%   map, different colors indicate different frequencies, brightness of the 
%   colors indicate the energy and the location indicates the direction of
%   the activity.
%
%   See also: takanen2013, takanen2013contracomparison
%
%   References: takanen2014

%   AUTHOR: Marko Takanen, Olli Santala, Ville Pulkki
%
%   COPYRIGHT (C) 2013 Aalto University
%                      School of Electrical Engineering
%                      Department of Signal Processing and Acoustics
%                      Espoo, Finland

%% ------ Set parameter values --------------------------------------------

levels = -90:10:90;
%the frequency ranges for different color codes are specified as presented
%in the article******* as 124 Hz, 440 Hz, 1050 Hz, 2.20 kHz 4.40 kHz, 8.7
%kHz and 15.3 kHz

ranges = [1 find(fc>=440,1,'first') find(fc>=1050,1,'first') find(fc>=2200,1,'first') ...
     find(fc>=4400,1,'first') find(fc>8700,1,'first') length(fc)+1];
%the corresponding colors for each frequency area are specified here
colorMtrx = zeros(length(ranges),3);
colorMtrx(1,:) = [1 1 1]; % black
colorMtrx(7,:) = [0 0.5 1];% blueish
colorMtrx(2,:) = [1 0 1];% magenta 
colorMtrx(4,:) = [1 0 0]; %red
colorMtrx(3,:) = [1 1 0]; %yellow
colorMtrx(6,:) = [0 1 0]; %green
colorMtrx(5,:) = [0 1 1]; %cyan
 
dims = size(thetaR);

%the output variables are initialized here
nXBins= length(levels)*(size(colorMtrx,1)-1);
activityMap = zeros(dims(1),nXBins);
colorGains = zeros(dims(1),nXBins);

%% ------ Computation -----------------------------------------------------
%the what cues (i.e. the spectral information) is derived from the
%periphery model outputs using the max-outputs for a pink noise at 60 dB
load takanen2013_periphenergyaverages.mat -mat
eR = eR./(ones(dims(1),1)*averageEnerg);
eL = eL./(ones(dims(1),1)*averageEnerg);
max_val = max(eL(:));
scaleVal = max(1,max_val/5);
eL = eL./(scaleVal);
max_val = max(eR(:));
scaleVal = max(1,max_val/5);
eR = eR./(scaleVal);


bands = 1:dims(2);
for bandInd =1:(length(ranges)-1)
   temp = (bands>=ranges(bandInd)).*(bands<ranges(bandInd+1));
   %if desired, the operations involved in *contralateralcomparison*
   %procedure are illustrated on one frequency area
   if bandInd==2
       [mapTemp gainTemp] = takanen2013contracomparison(thetaL(:,temp==1),thetaR(:,temp==1),levels,eL(:,temp==1),eR(:,temp==1),fs,printFigs);
   else
       [mapTemp gainTemp] = takanen2013contracomparison(thetaL(:,temp==1),thetaR(:,temp==1),levels,eL(:,temp==1),eR(:,temp==1),fs,0);
   end
   activityMap(:,bandInd:length(ranges)-1:nXBins) = mapTemp*bandInd;
   colorGains(:,bandInd:length(ranges)-1:nXBins) = gainTemp;
end
clear thetaL thetaR eL eR gainTemp mapTemp

%An image of the activation is plotted
colorGains(colorGains>1) =1;
%a 3-D matrix is created to store the rgb-values of the figure for
%each time and activation instant
outputMtrx = single(zeros(dims(1),nXBins,3));
for colorInd=1:size(colorMtrx,1)
    temp = find((activityMap==(colorInd-1))==1);
    outputMtrx(temp) = colorGains(temp)*colorMtrx(colorInd,1);
    outputMtrx(temp+dims(1)*nXBins) = colorGains(temp)*colorMtrx(colorInd,2);
    outputMtrx(temp+2*dims(1)*nXBins) = colorGains(temp)*colorMtrx(colorInd,3);
end
if(printMap==1)
    figure(99);
    imagesc(levels./90,(dims(1)-1:-20:0)/fs,outputMtrx(1:20:end,:,:));
    set(gca,'Xtick', -.95:0.38:.95);
    set(gca,'XtickLabel',-1:0.4:1);
    xlabel('Activation location');
    ylabel('Time [s]');
end