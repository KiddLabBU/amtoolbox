function cc = lindemann1986a_fig8()
%LINDEMANN1986a_FIG( Reproduces fig. 8 from lindemann1986a
%   Usage: cc = lindemann1986a_fig8;
%
%   Output parameters:
%       cc  - cross-correlation result of the to figure.
%             Dim: number of c_s conditions x nilds x delay line length
%
%   LINDEMANN1986a_FIG8() reproduces fig.8 from lindemann1986a. Therefore the
%   cross-correlation of pure tone sinusoids with different ILDs is calculated. 
%   Because of the stationary character of the input signals T_int = inf is used
%   to produce only one time step in the crosscorr output from lindemann.
%   This is calculated for different ILDs and different inhibition factors
%   c_s = 0.3, 1. Afterwards for every c_s the ILD is plotted dependend on the
%   correaltion time.
%
%   See also: lindemann, ildsin
%
%R lindemann1986a
%

%   AUTHOR: Hagen Wierstorf


% ------- Computation ----------------------------------------------------
% Sampling rate
fs = 44100;
% Frequency of the sinusoid
f = 500;
fc = round(freqtoerb(f));   % corresponding frequency channel

% Model parameter
T_int = inf;
w_f = 0;
M_f = 6; % not used, if w_f==0
c_s = [0.3,1];

% Calculate crosscorrelations for 26 ILD points between 0~dB and 25~dB
nilds = 26; % number of used ILDs
ndl = 45;   % length of the delay line
ild = linspace(0,25,nilds);
cc = zeros(2,nilds,ndl);
for ii = 1:nilds 
    % Generate sinusoid with given ILD
    sig = ildsin(f,ild(ii),fs);
    % Use only the beginning of the signal to generate only one time instance of
    % the cross-correlation
    % FIXME: also we use only stationary inhibition here by varying c_s the
    % results depends much on the length of the used signal. I think Lindemann 
    % has not stated this fact nor calculated the fading time, so we have to do
    % this.
    sig = sig(1:ceil(0.01*fs),:);
    % Calculate cross-correlation for different inhibition factor c_s 
    for jj = 1:length(c_s)
        % Calculate cross-correlation (and squeeze due to T_int==inf)
        tmp = squeeze(lindemann(sig,fs,c_s(jj),w_f,M_f,T_int));
        % Store the needed frequency channel. NOTE: the cross-correlation
        % calculation starts with channel 5, so we have to subtract 5.
        cc(jj,ii,:) = tmp(:,fc-5);
    end
end


% ------ Plotting --------------------------------------------------------
% Generate time axis
tau = linspace(-1,1,ndl);
% Plot figure for every c_s condition
for jj = 1:length(c_s) 
    figure;
    mesh(tau,ild(end:-1:1),squeeze(cc(jj,:,:)));
    view(0,57);
    xlabel('correlation-time delay (ms)');
    ylabel('interaural level difference (dB)');
    tics('y',[0,5,10,15,20,25],['25';'20';'15';'10';'5';'0']);
    tstr = sprintf('c_{inh} = %.1f\nw_f = 0\nf = 500 Hz\n',c_s(jj));
    title(tstr);
end

