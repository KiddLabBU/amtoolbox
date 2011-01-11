function freq = audtofreq(aud,varargin);
%AUDTOFREQ  Converts auditory units to frequency (Hz)
%   Usage: freq = audtofreq(aud);
%  
%   AUDTOFREQ(aud,scale) converts values on the selected auditory scale to
%   values on the frequency scale measured in Hz.
%
%   See the help on FREQTOAUD to get a list of the supported values of the
%   scale parameter. 
%
%   See also: freqtoaud, audspace, audfiltbw

%   AUTHOR: Peter L. Soendergaard

%% ------ Checking of input parameters ---------

if nargin<1
  error('%s: Too few input parameters.',upper(mfilename));
end;


if ~isnumeric(aud) ||  all(aud(:)<0)
  error('%s: aud must be a non-negative number.',upper(mfilename));
end;

definput.flags.scale={'missingflag','mel','bark','erb','erb83'};
[flags,kv]=ltfatarghelper({},definput,varargin);

if flags.do_missingflag
  flagnames=[sprintf('%s, ',definput.flags.scale{2:end-2}),...
             sprintf('%s or %s',definput.flags.scale{end-1},...
                     definput.flags.scale{end})];
  error('%s: You must specify one of the following flags: %s.',upper(mfilename),flagnames);
end;

%% ------ Computation --------------------------
  
if flags.do_mel
  freq = 700*(exp(aud/1127.01048)-1);
end;

if flags.do_erb
freq = (1/0.00437)*(exp(aud/9.2645)-1);
end;

if flags.do_bark
  % This one was found through http://www.ling.su.se/STAFF/hartmut/bark.htm
  freq = 1960./(26.81./(aud+0.53)-1);
end;

if flags.do_erb83
    freq = 14363./(1-exp((aud-43.0)/11.7))-14675;
end;
