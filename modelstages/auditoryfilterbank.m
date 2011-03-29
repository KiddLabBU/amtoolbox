function [outsig, fc] = auditoryfilterbank(insig, fs, varargin);
%AUDITORYFILTERBANK   Linear auditory filterbank
%   Usage: [outsig, fc] = auditoryfilterbank(insig,fs);
%          [outsig, fc] = auditoryfilterbank(insig,fs,...);
%
%   Input parameters:
%     insig  : input acoustic signal.
%     fs     : sampling rate.
%  
%   AUDITORYFILTERBANK(insig,fs) applies an auditory filterbank to the
%   imput signal insig sampled with a frequency of fs Hz. The filterbank
%   is composed of gammatone filters with 1 ERB wide filters.
%  
%   [outsig,fc]=AUDITORYFILTERBANK(...) additionally returns the center frequencies of
%   the filter bank.
%
%   The following parameters may be passed at the end of the line of
%   input arguments:
%
%-     'flow',flow   - Set the lowest frequency in the filterbank to
%                    flow. Default value is 80 Hz.
%
%-     'fhigh',fhigh - Set the highest frequency in the filterbank to
%                    fhigh. Default value is 8000 Hz.
%
%-     'basef',basef - Ensure that the frequency basef is a center frequency
%                    in the filterbank. The default value of [] means
%                    no default.
%
%-     'langendijk'  - Use rectangular filters as in Langendijk (2002).        

%   AUTHOR : Peter L. Soendergaard
  
% ------ Checking of input parameters ------------

if nargin<2
  error('%s: Too few input arguments.',upper(mfilename));
end;

if ~isnumeric(insig) 
  error('%s: insig must be numeric.',upper(mfilename));
end;

if ~isnumeric(fs) || ~isscalar(fs) || fs<=0
  error('%s: fs must be a positive scalar.',upper(mfilename));
end;

definput.import={'auditoryfilterbank'};

[flags,keyvals,flow,fhigh]  = ltfatarghelper({'flow','fhigh'},definput,varargin);

% ------ do the computation -------------------------

% find the center frequencies used in the filterbank, 1 ERB spacing
fc = erbspacebw(flow, fhigh, keyvals.bwmul, keyvals.basef);

if flags.do_gammatone
  % Calculate filter coefficients for the gammatone filter bank.
  [gt_b, gt_a]=gammatone(fc, fs, 'complex');
  
  % Apply the Gammatone filterbank
  outsig = 2*real(ufilterbankz(gt_b,gt_a,insig));
end;

if flags.do_langendijk
    
  % calculation
  jj=0:log(kv.fhigh/kv.flow)/log(2)*bw; 
  if max(imag(insig))==0

    if length(insig) <=2^11
      zp=nextpow2(length(insig))-4;   % zero padding for higher frequency resolution 
    else
      zp=0;
    end
    nfft =2^(nextpow2(length(insig))+zp);   % next power of 2 from length of input signal
    y = abs(fft(insig,nfft,1));
  
  else  % input signal already in frequency domain

    y = abs(insig);
    nfft=length(insig);
  
  end
  
  n=round(2.^((jj)/bw)*kv.flow/fs*nfft); %startbins
  ybw=zeros(length(jj)-1,size(insig,3)); %initialisation
  
  for ind=jj(1)+1:jj(end)
    nj=n(ind+1)-n(ind);
    for ch=1:size(insig,3)
      ybw(ind,ch)=sqrt(1/(nj)*sum(y(n(ind):n(ind+1)-1,ch).^2));
    end
  end
  
  outsig=20*log10(ybw);    
  
end;


