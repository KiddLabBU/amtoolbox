function b = headphonefilter(fs,order)
%HEADPHONEFILTER  Combined headphone and outer ear filter.
%   Usage:  b=headphonefilter(fs,order);
%           b=headphonefilter(fs);
%           b=headphonefilter;
%
%   HEADPHONEFILTER(fs,order) computes the filter coefficients of a FIR
%   filter or order _order approximating the combined effect of headphones
%   and the outer ear. The data describes a generic set of headphones,
%   originally from Pralong et al. (1996)
%
%   HEADPHONEFILTER(fs) does the same with a FIR filter of order 512.
%
%   HEADPHONEFILTER without any input arguments returns a table
%   describing the frequency response of the headphone filter. First
%   column of the table contain frequencies and the second column
%   contains the amplitude of the frequency.
%
%   See also: middleearfilter, data_pralong1994, data_lopezpoveda2001
%
%   Demos: demo_outermiddle
%   
%R pralong1996role lopezpoveda2001hnc
  
% Author: Morten L�ve Jepsen, Peter L. Soendergaard


if nargin==1
  order = 512;    % desired FIR filter order
end;

eardrum_data = data_pralong1996;

if nargin==0
  b = eardrum_data;
else
  
  if fs<=20000
    % In this case, we need to cut the table because the sampling
    % frequency is too low to accomodate the full range.
    
    indx=find(eardrum_data(:,1)<fs/2);
    eardrum_data=eardrum_data(1:indx(end),:);
  end;  

  % Extract the frequencies and amplitudes, and put them in the format
  % that fir2 likes.
  freq=[0;...
        eardrum_data(:,1).*(2/fs);...
        1];
  ampl=[0;...
        eardrum_data(:,2);...
        0];
  
  b = fir2(order,freq,ampl);

end;
