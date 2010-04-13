function outsig = itdildsin(f,itd,ild,fs)
%ITDILDSIN Generate a sinusoid with a interaural time difference
%   Usage: outsig = itdildsin(f,itd,ild,fs)
%
%   Input parameters:
%       f       - carrier frequency of the sinusoid (Hz)
%       itd     - interaural time difference of the left signal, this can be
%                 positive or negative (ms)
%       ild     - interaural level difference of the right signal, this can be
%                 positive or negative (dB)
%       fs      - sampling rate (Hz)
%
%   Output parameters:
%       outsig  - two channel 1 s long sinusoid
%
%   ITDILDSIN(f,itd,ild,fs) generates a sinusoid with a interaural time 
%   difference of itd, a interaural level difference of ild and a frequency of 
%   f.
%
%R moore2003introduction
%

% AUTHOR: Hagen Wierstorf


% ------ Checking of input parameters ---------

error(nargchk(4,4,nargin));

if ~isnumeric(f) || ~isscalar(f) || f<0
    error('%s: f must be a positive scalar.',upper(mfilename));
end

if ~isnumeric(itd) || ~isscalar(itd)
    error('%s: itd must be a scalar.',upper(mfilename));
end

if ~isnumeric(ild) || ~isscalar(ild)
    error('%s: ild must be a scalar.',upper(mfilename));
end

if ~isnumeric(fs) || ~isscalar(fs) || fs<=0
    error('%s: fs must be a positive scalar!',upper(mfilename));
end


% ------ Computation --------------------------

% Create a one second time 
t = (1:fs)/fs;
% Right signal
sigr = sin(2*pi*f.*t);
% Time shift in samples
itdsamples = ceil(fs * abs(itd)/1000);
% Left signal with ITD shift
sigl = [zeros(1,itdsamples) sin(2*pi*f.*t(1:end-itdsamples))];
% Combine left and right signal to outsig
% Check if we have a positive or negative ITD and switch left and right signal
% for negative ITD
if itd<0
    % Apply ILD
    sigl = gaindb(sigl,ild);
    outsig = [sigr' sigl'];
else
    % Aplly ILD
    sigr = gaindb(sigr,ild);
    outsig = [sigl' sigr'];
end
% Scale outsig
outsig = outsig / (max(abs(outsig(:)))+eps);
