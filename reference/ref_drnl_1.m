function outsig = drnl_1(insig,fs,varargin)
%DRNL_1  Dual Resonance Nonlinear Filterbank
%   Usage: outsig = drnl(insig,fc,fs);
%
%   This version contains the old way of computing the filter by doing
%   multiple runs through filter.
%
%   DRNL(insig,fc,fs) computes the Dual Resonance Non-Linear filterbank of
%   the input signal insig sampled at fs Hz with channels specified by the
%   center frequencies in fc. The DRNL is described in the paper
%   Lopez-Poveda and Meddis (2001). The DRNL models the basilar membrane
%   non-linearity.
%
%   The input to DRNL must be measured in stapes movement. The function
%   MIDDLEEARFILTER will do this, so this function must be called before
%   invoking DRNL.
%
%   The DRNL takes a lot of parameters which vary over frequency. Such a
%   parameter is described by a 1x2 vector [b a] and indicates that the
%   value of the parameter at frequency fc can be calculated by
%
%C     10^(b+alog10(fc));
%
%   The parameters are:
%
%-     'flow',flow - Set the lowest frequency in the filterbank to
%                    flow. Default value is 80 Hz.
%
%-     'fhigh',fhigh - Set the highest frequency in the filterbank to
%                    fhigh. Default value is 8000 Hz.
%
%-     'basef',basef - Ensure that the frequency basef is a center frequency
%                    in the filterbank. The default value of [] means
%                    no default.
%
%-     'lin_ngt',n  - Number of cascaded gammatone filter in the linear
%                    part, default value is 2.
%
%-     'lin_nlp',n - Number of cascaded lowpass filters in the linear
%                    part, default value is 4
% 
%-     'lin_gain',g - Gain in the linear part, default value is [4.20405 ...
%                    .47909].
%
%-     'lin_fc',fc - Center frequencies of the gammatone filters in the
%                    linear part. Default value is [-0.06762 1.01679].
%
%-     'lin_bw',bw - Bandwidth of the gammatone filters in the linear
%                    part. Default value is [.03728  .75]
%
%-     'lin_lp_cutoff',c - Cutoff frequency of the lowpass filters in the
%                    linear part. Default value is [-0.06762 1.01 ]
%
%-     'nlin_ngt_before',n - Number of cascaded gammatone filters in the
%                    non-linear part before the broken stick
%                    non-linearity. Default value is 2.
%
%-     'nlin_ngt_after',n -  Number of cascaded gammatone filters in the
%                    non-linear part after the broken stick
%                    non-linearity. Default value is 2.
%
%-     'nlin_nlp',n - Number of cascaded lowpass filters in the
%                    non-linear part. Default value is 1.
%
%-     'nlin_fc_before',fc - Center frequencies of the gammatone filters in the
%                    non-linear part before the broken stick
%                    non-linearity. Default value is [-0.05252 1.01650].
%
%-     'nlin_fc_after',fc - Center frequencies of the gammatone filters in the
%                    non-linear part after the broken stick
%                    non-linearity. Default value is [-0.05252 1.01650].
%
%-     'nlin_bw_before',bw - Bandwidth of the gammatone filters in the
%                    non-linear part before the broken stick
%                    non-linearity. Default value is [-0.03193 .7 ].
%
%-     'nlin_bw_after',w - Bandwidth of the gammatone filters in the
%                    non-linear part before the broken stick
%                    non-linearity. Default value is [-0.03193 .7 ].
%
%-     'nlin_lp_cutoff',c - Cutoff frequency of the lowpass filters in the
%                    non-linear part. Default value is [-0.05252 1.01 ].
%
%-     'nlin_a',a - 'a' coefficient for the broken-stick non-linearity. Default
%                   value is [1.40298 .81916 ].
%
%-     'nlin_b',b = 'b' coefficient for the broken-stick non-linearity. Default
%                   value is [1.61912 -.81867
%
%-     'nlin_c',c = 'c' coefficient for the broken-stick non-linearity. Default
%                   value is [-.60206 0].
%
%-     'nlin_d',d = 'd' coefficient for the broken-stick non-linearity. Default
%                    value is 1.
%
%   See also: middlerearfilter, jepsen2008preproc
% 
%R   lopezpoveda2001hnc jepsen2008cmh

% AUTHOR: Morten L�ve Jepsen
  
% Bugfix by Marton Marschall 9/2008
% Cleanup by Peter L. Soendergaard.
  
%DRNL for normal hearing, Morten 2007

% Import the parameters from the arg_drnl.m function.
definput.import={'drnl'};

[flags,kv]=ltfatarghelper({'flow','fhigh'},definput,varargin);

% find the center frequencies used in the filterbank, 1 ERB spacing
fc = erbspacebw(kv.flow, kv.fhigh, 1, kv.basef);

%% Apply the middle-ear filter
if flags.do_middleear
  
  me_fir = middleearfilter(fs);
  insig = filter(me_fir,1,insig);

end;

% ---------------- main loop over center frequencies

% Code will fail for a row vector, FIXME
siglen = size(insig,1);
nsigs  = size(insig,2);
nfc    = length(fc);

outsig=zeros(siglen,nfc,nsigs,nsigs);

for ii=1:nfc

  % -------- Setup channel dependant definitions -----------------

  lin_fc        = polfun(kv.lin_fc,fc(ii));
  lin_bw        = polfun(kv.lin_bw,fc(ii));
  lin_lp_cutoff = polfun(kv.lin_lp_cutoff,fc(ii));
  lin_gain      = polfun(kv.lin_gain,fc(ii));
  
  nlin_fc_before = polfun(kv.nlin_fc_before,fc(ii));
  nlin_fc_after  = polfun(kv.nlin_fc_after,fc(ii));
  
  nlin_bw_before = polfun(kv.nlin_bw_before,fc(ii));
  nlin_bw_after  = polfun(kv.nlin_bw_after,fc(ii));
  
  nlin_lp_cutoff = polfun(kv.nlin_lp_cutoff,fc(ii));
  
  % a, the 1500 assumption is no good for compressionat low freq filters
  nlin_a = polfun(kv.nlin_a,min(fc(ii),1500));

  % b [(m/s)^(1-c)]
  nlin_b = polfun(kv.nlin_b,min(fc(ii),1500));
      
  nlin_c = polfun(kv.nlin_c,fc(ii));
  [GTlin_b,GTlin_a] = coefGtDRNL(lin_fc,lin_bw,1,fs);
    
  % Compute coefficients for the linear stage lowpass, use 2nd order
  % Butterworth.
  [LPlin_b,LPlin_a] = coefLPDRNL(lin_lp_cutoff,fs);
  
  [GTnlin_b_before,GTnlin_a_before] = coefGtDRNL(nlin_fc_before,nlin_bw_before,...
                                                 1,fs);
  [GTnlin_b_after, GTnlin_a_after]  = coefGtDRNL(nlin_fc_after, nlin_bw_after,...
                                                   1,fs);

  % Compute coefficients for the non-linear stage lowpass, use 2nd order
  % Butterworth.
  [LPnlin_b,LPnlin_a] = coefLPDRNL(nlin_lp_cutoff,fs);
  
  % -------------- linear part --------------------------------

  % Apply linear gain
  y_lin = insig.*lin_gain; 
  
  % Now filtering.
  % Instead of actually perform multiply filtering, just convolve the
  % coefficients.      
  for jj=1:kv.lin_ngt
    y_lin = filter(GTlin_b,GTlin_a,y_lin);
  end;
  
  for jj=1:kv.lin_nlp
    y_lin = filter(LPlin_b,LPlin_a,y_lin);
  end;
  
  % -------------- Non-linear part ------------------------------
      
  % GT filtering before
  y_nlin=insig;
  for jj=1:kv.nlin_ngt_before
    y_nlin = filter(GTnlin_b_before,GTnlin_a_before,y_nlin);
  end;
  
  % Broken stick nonlinearity
  if kv.nlin_d~=1
    % Just to save some flops, make this optional.
    y_nlin = sign(y_nlin).*min(nlin_a*abs(y_nlin).^kv.nlin_d, ...
                               nlin_b*(abs(y_nlin)).^nlin_c);
  else
    y_nlin = sign(y_nlin).*min(nlin_a*abs(y_nlin), ...
                               nlin_b*(abs(y_nlin)).^nlin_c);
  end;
  
  % GT filtering after
  for jj=1:kv.nlin_ngt_after
    y_nlin = filter(GTnlin_b_after,GTnlin_a_after,y_nlin);
  end;
  
  % then LP filtering  
  for jj=1:kv.nlin_nlp
    y_nlin = filter(LPnlin_b,LPnlin_a,y_nlin);
  end;
  
  outsig(:,ii,:) = reshape(y_lin + y_nlin,siglen,1,nsigs);    
  
end;
  
 
function outpar=polfun(par,fc)
  %outpar=10^(par(1)+par(2)*log10(fc));
  outpar=10^(par(1))*fc^par(2);