function [ei_map, fc] = breebaart2001preproc(insig, fs, tau, ild, varargin);
%BREEBAART2001PREPROC   Auditory model from Breebaart et. al. 2001
%   Usage: [outsig, fc] = breebaart2001preproc(insig,fs);
%          [outsig, fc] = breebaart2001preproc(insig,fs,...);
%
%   Input parameters:
%        insig  : input acoustic signal.
%        fs     : sampling rate.
%        tau    : characteristic delay in seconds (positive: left is leading)
%        ild    : characteristic ILD in dB (positive: left is louder)
%  
%   `breebaart2001preproc(insig,fs,tau,ild)` computes the EI-cell representation of
%   the signal *insig* sampled with a frequency of *fs* Hz as described in
%   Breebaart (2001). The parameters *tau* and *ild* define the sensitivity of the EI-cell.
%
%   The input must have dimensions time x left/right channel x signal no.
%
%   The output has dimensions time x frequency x signal no. 
%  
%   `[outsig,fc]=breebaart2001preproc(...)` additionally returns the center
%   frequencies of the filter bank.
%  
%   The Breebaart 2001 model consists of the following stages:
%   
%     1) a gammatone filter bank with 1-erb spaced filters.
%
%     2) an envelope extraction stage done by half-wave rectification
%        followed by low-pass filtering to 770 Hz.
%
%     3) an adaptation stage modelling nerve adaptation by a cascade of 5
%        loops.
%
%     4) an excitation-inhibition (EI) cell model.
%
%   Parameters for |auditoryfilterbank|_, |ihcenvelope|_, |adaptloop|_ and
%   |eicell|_ can be passed at the end of the line of input arguments.
%
%   See also: eicell, auditoryfilterbank, ihcenvelope, adaptloop

%   References:breebaart2001binaural

%   AUTHOR : Peter L. Soendergaard
  
% ------ Checking of input parameters ------------

if nargin<4
  error('%s: Too few input arguments.',upper(mfilename));
end;

if ~isnumeric(insig) 
  error('%s: insig must be numeric.',upper(mfilename));
end;

if ~isnumeric(fs) || ~isscalar(fs) || fs<=0
  error('%s: fs must be a positive scalar.',upper(mfilename));
end;

definput.import = {'auditoryfilterbank','ihcenvelope','adaptloop','eicell'};
definput.importdefaults={'fhigh',8000,'ihc_breebart','adt_breebaart'};

[flags,keyvals,flow,fhigh,basef]  = ltfatarghelper({'flow', 'fhigh', ...
                    'basef'},definput,varargin);

% ------ do the computation -------------------------

%% Apply the auditory filterbank
[outsig, fc] = auditoryfilterbank(insig,fs,'argimport',flags,keyvals);

%% 'haircell' envelope extraction
outsig = ihcenvelope(outsig,fs,'argimport',flags,keyvals);

%% non-linear adaptation loops
outsig = adaptloop(outsig,fs,'argimport',flags,keyvals);

[siglen,nfreqchannels,naudiochannels,nsignals] = size(outsig);

ei_map = zeros(siglen, nfreqchannels, nsignals);
for k=1:nsignals
  for g=1:nfreqchannels
    ei_map(:,g,k) = eicell(squeeze(outsig(:,g,:,k)),fs,tau,ild);
  end
end
