%EXAMP_AUDSCALES  Plot of the different auditory scales.
%
%  This demos generates a simple figure that shows the behaviour of
%  the different audiory scales in the frequency range from 0 to 8000 Hz.
%
%  FIGURE 1
%
%    Show the behaviour of the audiory scales on a normalized frequency
%    plot.
%
%  See also:  freqtoaud, audtofreq, audspace, audspacebw

disp(['Type "help demo_audscales" to see a description of how this ', ...
      'demo works.']);

% Set the limits
flow=0;
fhigh=8000;
plotpoints=50;

xrange=linspace(flow,fhigh,plotpoints);


figure(1)

types   = {'erb','bark','mel','erb83'};
symbols = {'r.' ,'go'  ,'bx' ,'y+'};

hold on;
for ii=1:numel(types)
  curve = freqtoaud(types{ii},xrange);
  % Normalize the frequency to a maximum of 1.
  curve=curve/curve(end);
  plot(xrange,curve,symbols{ii});
end;
hold off;
legend(types{:},'Location','SouthEast');

