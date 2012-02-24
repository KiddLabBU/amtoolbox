function op = read_hrir(elev,azim,database);
%READ_HRIR  Read HRIR from selected databases
%   Usage:  hrir = read_hrir(elev,azim,database);
%  
%   Input parameters:
%     elev : $(-90 -> +90)$ elevation of source with respect to head in degrees
%            Both databases have a range of elevations, but more limited in 
%            the Oldenburg case.
%     azim : $(-360 -> +360)$ azimuth of source with respect to head in degrees
%
%     database : Type of database (see below)
%
%   Output parameters:
%     hrir : the requested HRIR 
%
%   `read_hrir(elev,azim,database)` retrieves the HRIR closest to the
%   specified azimuth and elevation from the MIT Kemar (Gardner and Martin,
%   1995) or Oldenburg Siemens Acuris Kayser et al. (2009) databases.
%
%   The value of the `database` parameter determines which dataset to
%   access:
%
%     'kemar'     MIT KEMAR database. 
%
%     'siemens0'  Oldenburg HATS database. 
%
%     'siemens1'  Front microphone from the Siemens Acuris microphones.
%
%     'siemens2'  As above, but the middle microphone.
%
%     'siemens3'  As above, but the read microphone.
%             
%     'cardioid'  For a simple cardioid directional microphone
%                 constructred from the Siemens Acruris mikes.
%
%   References: gardner1995hrtf kayser2009database

  % Base path of where to store the data
  s=[amtbasepath,'hrtf/hrir/'];
  
  % fix out of range cases
  if azim < 0
    azim = 360 + azim;
  elseif azim >= 360 
    azim = azim-360;
  end

  % prefix zeros for KEMAR databases
  if azim < 10           
    azim_str = sprintf('00%d',azim);
  elseif azim < 100
    azim_str = sprintf('0%d',azim);  
  else
    azim_str = sprintf('%d',azim);
  end  

  switch (database)
   case 'hats'        % HATS
    mik_nums = [1 2];
   case 'siemens1'        % front mike
    mik_nums = [3 4];
   case 'siemens2'        % middle mike
    mik_nums = [5 6];
   case 'siemens3'        % rear mike
    mik_nums = [7 8];
   case 'kemar'
    ipfile = fopen(sprintf('%skemar/elev%d/L%de%sa.dat',s,elev,elev,azim_str));
    op(:,1) = fread(ipfile, 512, 'int16',0,'b');
    fclose(ipfile);
    ipfile = fopen(sprintf('%skemar/elev%d/R%de%sa.dat',s,elev,elev,azim_str));
    op(:,2) = fread(ipfile, 512, 'int16',0,'b');
    fclose(ipfile);
  end

if strncmp(database,'siemens',7) || strcmp(database,'cardioid') || strcmp(database,'hats')
  if azim > 180            % fix out of range cases
    azim = azim - 360;
  end    
  filename = sprintf('%ssiemens/anechoic_distcm_300_el_%d_az_%d',s,elev,azim);
  set = wavread(filename);
  if strcmp(database,'cardioid')
    op = set(2:length(set),3:4);
    op = op - set(1:length(set)-1,5:6);
  else
    % select channels of wav file to get different mike 
    op = set(:,mik_nums(1):mik_nums(2));
  end
end