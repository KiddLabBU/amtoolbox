function ild = interauralleveldifference(insigleft,insigright)
%INTERAURALLEVELDIFFERENCE Extract the ILD between the two given signals
%
%   Usage: ild = interauralleveldifference(insigleft,insigright)
%
%   Input parameters:
%       insigleft   - left ear signal. This can also be a matrix containing
%                     left signals for different frequency bands
%       insigright  - the same as insigleft, but for the right ear
%
%   Output parameters:
%       ild         - ILD for the given signals. A single value for two
%                     given signals or a vector with values for every
%                     frequency band
%
%   INTERAURALLEVELDIFFERENCE(insigleft,insigright) extractes the ILD between
%   the left and right signal(s) by subtracting the dB value of the left
%   signal(s) from the dB value of the right signal(s). 

% AUTHOR: Hagen Wierstorf


%% ------ Checking of input parameters ----------------------------------
nargmin = 2;
nargmax = 2;
error(nargchk(nargmin,nargmax,nargin));
% FIXME: we need the helper functions in AMToolbox
isargmatrix(insigleft,insigright);
if size(insigright)~=size(insigright)
    error('%s: insigleft and insigright have to be the same size!', ...
        upper(mfilename));
end


%% ------ Computation ---------------------------------------------------
% see if we have more than one frequency channel in the insig
ild = zeros(1,size(insigleft,2));
for ii = 1:size(insigleft,2)
    ild(ii) = db(rms(insigright(:,ii)))-db(rms(insigleft(:,ii)));
end
