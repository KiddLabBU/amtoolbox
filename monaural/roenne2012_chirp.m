function [waveVamp, waveVlat]  = roenne2012_chirp(levels,chirps,varargin)
%ROENNE2012_CHIRP Simulate chirp evoked ABRs
%   Usage: [waveVamp, waveVlat]  = ronne2012_chirp(flag)
%
%   Output parameters:
%     waveVamp   : Amplitude of simulated ABR wave V.
%     waveVlat   : Latency of simulated ABR wave V peak.
%
%   `ronne2012_chirp(levels,chirps)` returns simulations from R�nne et
%   al. (2012) for a range of input levels *levels. The values of
%   *chirps* selects which stimuli from Elberling et al. (2010) stimuli to
%   simulate, *1* = click, *2* to *6* = chirp 1 to 5.
%
%   Simulates ABR responses to five chirps and one click using the ABR model
%   of R�nne et al. (2012). Fig. 6 or 7 of R�nne et al. (2012) can be
%   reproduced based on these data - use `plot_roenne2012_chirp`.  Simulations
%   can be compared to data from Elberling et al. (2010). Stimuli are
%   defined similar to Elberling et al. (2010).
%
%   This function takes the following optional parameters:
%
%     'plot2'   Plot extra figures for all individual simulations (3
%               figures x stimulus levels x number of chirps).
%
%     'noplot'  Do not plot main figure (fig 6 or 7).
% 
%     'plot'    Plot main figure (fig 6 or 7). See |plotroenne2012_chirp|_.
%
%   ---------
%
%   Please cite R�nne et al. (2012) and Zilany and Bruce (2007) if you use
%   this model.
%
%   See also: roenne2012, plotroenne2012_chirp, exp_roenne2012
%  
%   References: roenne2012modeling elberling2010evaluating zilany2007representation

% Define input flags
%definput.flags.type                 = {'fig6','fig7'};
definput.flags.plot                 = {'noplot','plot','plot2'};
%definput.keyvals.stim_level         = (20:20:60)+35.2;
%definput.keyvals.chirp_number       = 1:6;
[flags,kv]  = ltfatarghelper({},definput,varargin);

%% Init
fsstim              = 30000;        % stimulus fs
fsmod               = 200000;       % AN model fs

% load Unitary Response and its samlping frequency
[ur,fs]=data_roenne2012;

% load Elberling et al (2010) click and chirp stimuli
Elberlingstim=data_elberling2010('stim');

% length of modelling [ms]
modellength         = 40;           

% Output filter corresponding to recording settings (see Elberling et al
% 2010 section 3)
b=fir1(200,[100/(fs/2),3000/(fs/2)]);
a=1;

%% ABR model

% Loop over stimulus levels
for L = 1:length(levels)                                                    
  lvl  = levels(L);
  
  % Loop over chosen Elberling et al. (2010) stimuli
  for CE = chirps
    
    % Define length of stimulus, uses variable modellength
    stim  = zeros(modellength/1000*fsstim,1);
    
    % Use one of Elberling et al. (2010) stimuli
    stimCE = Elberlingstim.(['c' num2str(CE-1)]);
    
    % Create stimulus with chirp stimulus and concatenated zeros => combined 
    % length = "modellength"          
    stim(1:length(stimCE)) = stimCE;            
    
    % call AN model, note that lots of extra outputs are possible - see
    % "roenne2012_get_an.m"
    [ANout,vFreq] = zilany2007humanized(lvl, stim', fsstim, fsmod);
    
    % Subtract 50 due to spontaneous rate
    ANout = ANout'-50;                                    
    
    % Sum in time across fibers = summed activity pattern        
    ANsum = sum(ANout,2);
    
    % Downsample ANsum to get fs = fs_UR = 30kHz
    ANsum = resample(ANsum ,fs,fsmod);                   
    
    % Simulated potential = UR * ANsum (* = convolved)
    simpot = filter(ur,1,ANsum);                           
    
    % apply output filter similar to the recording conditions in
    % Elberling et al. (2010)
    simpot = filtfilt(b,a,simpot);                         
    
    % Find max peak value (wave V)
    maxpeak(CE,L) = max(simpot);                             
    
    % Find corresponding time of max peak value (latency of wave V)
    waveVlat(CE,L) = find(simpot == maxpeak(CE,L));                      
    
    % find minimum in the interval from "max peak" to 6.7 ms later
    minpeak(CE,L) = min(simpot(find(simpot == maxpeak(CE,L)):find(simpot == maxpeak(CE,L))+200)); 
    
    %% PLOTS, extra plots created for all conditions used, i.e. three
    % plots for each stimulus level x each chirp sweeping rate. If this
    % is switched on and all other variables are set to default,
    % 3 (levels) x 6 (chirps / clicks) x 3 (different figures) = 48
    % figures will be created.
    if flags.do_plot2
      % Plot simulated ABR
      figure, t = 1e3.*[0:length(simpot)-1]./fs-15;
      plot(t,simpot,'k','linewidth',2),xlabel('time [ms]'), 
      title(['Simulated ABR (Elberling et al stimulus c' ...
             num2str(CE-1) ' at ' num2str(lvl) 'dB)']),
      set(gca, 'fontsize',12), axis([0 10 -.2 .3])
      
      % Plot "AN-gram" - spectrogram-like representation of the
      % discharge rate after the IHC-AN synapse 
      figure,  set(gca, 'fontsize',12),imagesc(ANout'), 
      title(['ANgram - (Elberling et al stimulus c' num2str(CE-1) ...
             ' at ' num2str(lvl) 'dB)'])
      set(gca,'YTick',[1 100 200 300 400 500]),
      set(gca,'YTicklabel',round(vFreq([1 100 200 300 400 500]))), 
      ylabel('model CF'), xlabel('time [ms]'),set(gca,'XTick',(0:500:8000)),
      set(gca,'XTicklabel',(0:500:8000)/fsmod*1000-15), xlabel('time [ms]'),
      xlim([12/1000*fsmod 26/1000*fsmod]),colorbar
      
      % Plot "AN-UR-gram" - spectrogram-like representation of the
      % discharge rate convolved line by line with the UR. 
      figure, ANUR = resample(ANout,fs,fsmod);
      ANUR = filter(ur,1,ANUR); imagesc(ANUR'),
      set(gca,'YTick',[1 100 200 300 400 500]),
      set(gca,'YTicklabel',round(vFreq([1 100 200 300 400 500]))), 
      ylabel('model CF'), xlabel('time [ms]'),
      set(gca,'XTick',(0:150:1500)), xlabel('time [ms]'),
      set(gca,'XTicklabel',(0:150:1500)/fs*1000-15)
      colorbar, xlim([450 1000]), 
      title(['AN-URgram (Elberling et al stimulus c' num2str(CE-1) ' stimulus at ' num2str(lvl) 'dB)'])
    end
  end
  
end

% Calculate wave V amplitude, as the difference between the peak and
% the dip.
waveVamp = (maxpeak-minpeak);

% Subtract 15 ms as click stimulus peaks 15 ms into the time series
waveVlat = waveVlat*1000/fs-15;

%{
if flags.do_plot
  %% Plot figure 7 from R�nne et al. (2012)
  if flags.do_fig7
    [ElberlingDelay,CElatmean,CElatstd]  = data_elberling2010('fig5');
    ElberlingDelay2 = [ElberlingDelay;ElberlingDelay;ElberlingDelay];
    figure
    set(gca,'fontsize',12);, axis([-1.2 6.5 0 10]),xlabel('Change of delay [ms]'), ylabel('ABR latency [ms]')
    text(-.7,5.88, '60','fontsize',12,'color',[0.7,0.7,0.7])
    text(-.7,6.59, '40','fontsize',12,'color',[0.7,0.7,0.7])
    text(-.7,7.6, '20','fontsize',12,'color', [0.7,0.7,0.7])
    text(-.9,8.7, 'dB nHL','fontsize',12,'color',[0.7,0.7,0.7])
    text(5.5,waveVlat(6,1)/fs*1000-15, '20','fontsize',12)
    text(5.5,waveVlat(6,2)/fs*1000-15, '40','fontsize',12)
    text(5.5,waveVlat(6,3)/fs*1000-15, '60','fontsize',12)
    text(5.3,waveVlat(6,1)/fs*1000-15+.6, 'dB nHL','fontsize',12)
    text(-.2,.5, 'Click','fontsize',12)
    text(ElberlingDelay(2),1, '1','fontsize',12)
    text(ElberlingDelay(3),1, '2','fontsize',12)
    text(ElberlingDelay(4),1, '3','fontsize',12)
    text(ElberlingDelay(5),1, '4','fontsize',12)
    text(ElberlingDelay(6),1, '5','fontsize',12)
    text(3,.5, 'Chirps','fontsize',12)
    box on;
    hold on;
    set(gca,'fontsize',12);
    errorbar(ElberlingDelay2',CElatmean,CElatstd,'-','linewidth',1.5, ...
             'color',[0.7,0.7,0.7])
    %,ylim([0 800])
    plot(ElberlingDelay,(waveVlat/fs*1000)-15,'-*k','linewidth',1.5),
  end
  
  %% Plot figure 6 from R�nne et al. (2012)
  if flags.do_fig6
    [ElberlingDelay,CElatmean,CElatstd]  = data_elberling2010('fig4');
    set(gca,'fontsize',12);

    figure;
    hold on;
    errorbar(ElberlingDelay2',CEmean,CEstd/sqrt(20),'-','linewidth',1.5, ...
             'color',[0.7,0.7,0.7])
    %,ylim([0 800])
    plot(ElberlingDelay,waveVamp*1000,'-*k','linewidth',1.5),
    axis([-1.2 5.5 0 800]),xlabel('Change of delay [ms]'), ylabel('ABR amplitude [nv]')
    text(-.7,waveVamp(1,1)*1000, '20','fontsize',12)
    text(-.7,waveVamp(1,2)*1000, '40','fontsize',12)
    text(-.7,waveVamp(1,3)*1000, '60','fontsize',12)
    text(-.9,waveVamp(1,3)*1000+70, 'dB nHL','fontsize',12)
    text(-.2,50, 'Click','fontsize',12)
    text(ElberlingDelay(2),75, '1','fontsize',12)
    text(ElberlingDelay(3),75, '2','fontsize',12)
    text(ElberlingDelay(4),75, '3','fontsize',12)
    text(ElberlingDelay(5),75, '4','fontsize',12)
    text(ElberlingDelay(6),75, '5','fontsize',12)
    text(3,40, 'Chirps','fontsize',12)
    box on
  end
end

%}