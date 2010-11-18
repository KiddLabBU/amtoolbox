function [ out ] = averagingfb( in,bw,fstart,fend,fs )
%AVERAGINGFB Averaging rectangular filter bank according to Langendijk
% Usage:        averagingfb( in,bw,fstart,fend,fs )
% Input arguments:
%     in:       impulse response or complex spectrum
%     bw:       bandwidth of one filter as partial of an octave,
%               bw={3,6,12,24};                     default: 6
%     fstart:   start frequency; minimum: 0,5kHz;   default: 2kHz
%     fend:     end frequency;                      default: 16kHz
%     fs:       sampling frequency;                 default: 48kHz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robert Baumgartner, OEAW Acoustical Research Institute
% latest update: 2010-07-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default settings
if ~exist('bw','var')
    bw=6;
end
if ~exist('fstart','var')
    fstart=2000;
end
if ~exist('fend','var')
    fend=16000;
end
if ~exist('fs','var')
    fs=48000;
end

% calculation
j=0:log(fend/fstart)/log(2)*bw; 
if max(imag(in))==0
    if length(in) <=2^11
        zp=nextpow2(length(in))-4;   % zero padding for higher frequency resolution 
    else
        zp=0;
    end
    nfft =2^(nextpow2(length(in))+zp);   % next power of 2 from length of input signal
    y = abs(fft(in,nfft,1));
else  % input signal already in frequency domain
    y = abs(in);
    nfft=length(in);
end
n=round(2.^((j)/bw)*fstart/fs*nfft); %startbins
ybw=zeros(length(j)-1,size(in,3)); %initialisation
for ind=j(1)+1:j(end)
    nj=n(ind+1)-n(ind);
    for ch=1:size(in,3)
        ybw(ind,ch)=sqrt(1/(nj)*sum(y(n(ind):n(ind+1)-1,ch).^2));
    end
end

out=20*log10(ybw);
end

