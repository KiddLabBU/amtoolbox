function f=fftreal(f,N,dim);
%FFTREAL   FFT for real valued input data.
%   Usage: f=fftreal(f);
%          f=fftreal(f,N,dim);
%
%   FFTREAL(f) computes the coefficients correcsponding to the positive
%   frequencies of the FFT of the real valued input signal f.
%   
%   The function take exactly the same arguments as FFT. See the help on
%   FFT for a thorough description.
%M
%   See also:  ifftreal

%   AUTHOR    : Peter Soendergaard
%   TESTING   : TEST_PUREFREQ
%   REFERENCE : OK
  
error(nargchk(1,3,nargin));

if nargin<3
  dim=[];  
end;

if nargin<2
  N=[];
end;

if ~isreal(f)
  error('Input signal must be real.');
end;


[f,N,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,N,dim,'FFTREAL');

N2=floor(N/2)+1;

f=comp_fftreal(f);

% Set the new size in the first dimension.
permutedsize(1)=N2;

f=assert_sigreshape_post(f,dim,permutedsize,order);

