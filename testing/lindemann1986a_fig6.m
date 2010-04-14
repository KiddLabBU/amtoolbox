function cc = lindemann1986a_fig6()
%LINDEMANN1986a_FIG6 Reproduces fig. 6 from lindemann1986a
%   Usage: cc = lindemann1986a_fig6;
%
%   Output parameters:
%       cc  - cross-correlation result of the figure.
%             Dim: number of c_s conditions x nitds x delay line length
%
%   LINDEMANN1986a_FIG6() reproduces fig.6 from lindemann1986a. Therefore the
%   cross-correlation of pure tone sinusoids with different ITDs is calculated. 
%   Because of the stationary character of the input signals T_int = inf is used
%   to produce only one time step in the crosscorr output from lindemann.
%   This is calculated for different ITDs and different inhibition factors c_s
%   (0,0.3,1). Afterwards for every c_s the correlation is plotted for every
%   used ITD dependend on the correlation-time delay.
%
%   See also: lindemann, itdsin
%
%R lindemann1986a
%

%   AUTHOR: Hagen Wierstorf


% ------- Computation ----------------------------------------------------
% Sampling rate
fs = 44100;
% Frequency of the sinusoid
f = 500;
T = 1/f;
fc = round(freqtoerb(f));   % corresponding frequency channel

% Model parameter
T_int = inf;
w_f = 0;
M_f = 6; % not used, if w_f==0
c_s = [0,0.3,1];

% NOTE: the longer the signal, the more time we need for computation. On the
% other side N_1 needs to be long enough to eliminate any onset effects.
% Lindemann uses N_1 = 17640. Here I uses only N_1 = 2205 which gives the same
% results for this demo.
N_1 = ceil(25*T*fs);
siglen = ceil(30*T*fs);

% Calculate crosscorrelations for 21 ITD points between 0~ms and 1~ms
nitds = 21; % number of used ITDs
ndl = 2*round(fs/2000)+1;   % length of the delay line (see bincorr.m)
itd = linspace(0,1,nitds);
cc = zeros(length(c_s),nitds,ndl);
for ii = 1:nitds; 
    % Generate ITD shifted sinusoid
    sig = itdsin(f,itd(ii),fs);
    % Use only the beginning of the signal to generate only one time instance of
    % the cross-correlation and apply onset window
    sig = sig(1:siglen,:);
    sig = lindemannwin(sig,N_1);
    % Calculate cross-correlation for different inhibition factor c_s
    for jj = 1:length(c_s)
        % Calculate cross-correlation (and squeeze due to T_int==inf)
        tmp = squeeze(lindemann(sig,fs,c_s(jj),w_f,M_f,T_int,N_1));
        % Store the needed frequency channel. NOTE: the cross-correlation
        % calculation starts with channel 5, so we have to subtract 4.
        cc(jj,ii,:) =  tmp(:,fc-4);
    end
end


% ------ Plotting --------------------------------------------------------
% Generate time axis
tau = linspace(-1,1,ndl);
% Plot figure for every c_s condition
for jj = 1:length(c_s)
    figure;
    mesh(tau,itd(end:-1:1),squeeze(cc(jj,:,:)));
    view(0,57);
    xlabel('correlation-time tau (ms)');
    ylabel('interaural time difference (ms)');
    tics('y',[0,0.2,0.4,0.6,0.8,1],['1';'0.8';'0.6';'0.4';'0.2';'0']);
    tstr = sprintf('c_s = %.1f\nw_f = 0\nf = %i Hz\n',c_s(jj),f);
    title(tstr);
end

