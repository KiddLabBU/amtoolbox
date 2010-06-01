function amtstart()
%AMTSTART   Start the Auditory Modelling Toolbox.
%   Usage:  amtstart;
%
%   AMTSTART starts the Auditory Modellingd toolbox. This command must be
%   run before using any of the function in the toolbox. If you issue a
%   CLEAR ALL command then you must run AMTSTART again.
%
%   The auditory modelling toolbox depends on the Linear Time Frequency
%   Analysis Toolbox (LTFAT) to properly function. Therefore, you must issue
%   the LTFATSTART command before you start AMT.
%
%   To configure default options for functions, you can use the the
%   LTFATSETDEFAULTS functions in your startup script. A typical startup
%   file could look like:
%
%C    addpath('/path/to/my/work/ltfat');
%C    addpath('/path/to/my/work/amtoolbox');
%C    ltfatstart;
%C    amtstart;
%C    ltfatsetdefaults('audspecgram','classic');
%
%   The last command wil configure AUDSPECGRAM to display a classic
%   auditory spectrogram by default.
%
%   See also:  amthelp

%   AUTHOR : Peter L. Soendergaard.  

global TF_CONF;

% Verify that LTFAT has been installed
if isempty(TF_CONF)
    disp('');
    disp('--- AMTOOLBOX - The Auditory Modelling toolbox. ---');
    disp('')
    error(['The toolbox require the LTFAT toolbox to properly function. ' ...
         'Please download and install it from http://ltfat.sourceforge.net,' ...
         'and then call the LTFATSTART command BEFORE you call ' ...
          'AMTSTART.'])
end;
          
          
% --- general settings ---
% Print the banner at startup?
printbanner=1;

% --- Settings for plots ---

% See the help on AUDSPECGRAM for a definition of each of the settings
% below.

% displayratio, frange and ytick must ALWAYS be set.

plotdefaults = {'rectify',...
                'adapt',...
                'xres',800,...
                'displayratio',3/4,...
                'ytick',[100,250,500,1000,2000,4000,8000],...
                'frange',[0,8000],...
                'image',...
                'mlp',50,...
                };


% ----------------------------------------------------
% -------   do not edit below this line   ------------
% ----------------------------------------------------

% Get the basepath as the directory this function resides in.
% The 'which' solution below is more portable than 'mfilename'
% becase old versions of Matlab does not have "mfilename('fullpath')"
basepath=which('amtstart');
% Kill the function name from the path.
basepath=basepath(1:end-11);

% add the base path
if exist('addpath')>0
  addpath(basepath);
else
  path(path,basepath);
end

bp=[basepath,filesep];

% Load the version number
[FID, MSG] = fopen ([bp,'amt_version'],'r');
if FID == -1
    error(MSG);
else
    amt_version = fgetl (FID);
    fclose(FID);
end

% Create and load the information.
global AMT_CONF;
AMT_CONF.basepath=bp;
AMT_CONF.amt_version=amt_version;
AMT_CONF.plotdefaults=plotdefaults;

% -----------  install the modules -----------------

modules={};
nplug=0;

% List all files in base directory
d=dir(basepath);

for ii=1:length(d)
  if d(ii).isdir
    if ~(d(ii).name(1)=='.')

      name=d(ii).name;
      
      % The file is a directory and it does not start with '.' This could
      % be a module      
      if exist([bp,name,filesep,name,'init.m'],'file')
	% Set 'status' to zero if the module forgets to define it.
	status=0;
	module_version=amt_version;
        addpath([bp,name]);

	eval([name,'init']);
        if status>0
          if status==1
            nplug=nplug+1;
            modules{nplug}.name=name;
            modules{nplug}.version=module_version;
          end;
	else
	  rmpath([bp,name]);
	end;
      end;	

    end;
  end;
end;

AMT_CONF.modules=modules;

% Check if Octave was called using 'silent'
%if isoctave
%  args=argv;
%  for ii=1:numel(args)
%    s=lower(args{ii});
%    if strcmp(s,'--silent') || strcmp(s,'-q')
%      printbanner=0;
%    end;
%  end;
%end;

if printbanner
  disp(['AMT version ',amt_version,'. Copyright 2009 Peter L. Soendergaard. For help, please type "amthelp".'])
end;
