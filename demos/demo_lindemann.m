%DEMO_LINDEMANN
%
%   This script generate a figure showing the result of the lindemann
%   binaural model for a 2 Hz binaural modulated sinusoid.

% Sampling rate
fs = 44100;
% Frequency of the sinusoid
f = 500;
% Binaural modulation frequency
mf = 2;

% Generate 1~s binaural modulated sinusoid
sig = bmsin(f,mf,fs);
t = 1;

% Model paramter
c_s=1; w_f=0.035; M_f=6; T_int=5;

crosscorr = lindemann(sig,fs,c_s,w_f,M_f,T_int);
% Plot mean about all frequency channels
plotlindemann(crosscorr,t);
