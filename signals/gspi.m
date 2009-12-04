function s=gspi()
%GSPI  Load the 'glockenspiel' test signal.
%
%   GSPI loads the 'glockenspiel' signal. The is 262144 samples long,
%   mono, recorded at 44100 Hz using 16 bit quantization.
%   
%   The signal, and other similar audio tests signals, can be found on
%   http://andrew.csie.ncyu.edu.tw/html/mpeg4/sound.media.mit.edu/mpeg4/audio/sqam/index.html
%
  
%   AUTHOR : Peter Soendergaard
  
if nargin>0
  error('This function does not take input arguments.')
end;

% Load audio signal
s = wavread([amtbasepath,'signals',filesep,'gspi.wav']);