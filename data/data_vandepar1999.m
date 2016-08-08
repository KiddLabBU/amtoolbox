function data = data_vandepar1999(varargin)
%DATA_VANDEPAR1999 Returns data points from the van de Paar and Kohlrausch (1999) paper
%   Usage: data = data_vandepar1999(figure,nfc)
%
%
%   The figure may be one of:
%   'fig1_N0S0'     (default) Returns the N0S0 values for figure 1
%                   (Currently the only option).
%
%   The nfc (center frequency of noise) may be one of: 
%   'nfc125','nfc250','nfc500','nfc1000','nfc2000','nfc4000'
%
%   Examples:
%   ---------
% 
%   To get data for the fig. 1 van de Paar and Kohlrausch (1999) for the 
%   N0S0 condition with 125 Hz center frequency use :::
%
%     data_vandepar1999('fig1_N0S0','nfc125');
%
%   References: 


%   AUTHOR: Martina Kreuzbichler


%% ------ Check input options --------------------------------------------

% Define input flags
definput.flags.type={'fig1_N0S0','fig1_N0Spi','fig1_NpiS0'};
definput.flags.nfc = {'nfc125','nfc250','nfc500','nfc1000','nfc2000','nfc4000'};

% Parse input options
[flags,keyvals]  = ltfatarghelper({},definput,varargin);


%% ------ Data points from the paper ------------------------------------
%
% Data for the given figure
if flags.do_fig1_N0S0
    if flags.do_nfc125
        data= [3 2 1 0.8 -0.5 -6.5];
    elseif flags.do_nfc250
        data = [2.5 2.5 -1 0 -3.5 -8.5 -12.5];
    elseif flags.do_nfc500
        data = [2.5 1.5 -0.5 -2 -3 -7 -11 -11];
    elseif flags.do_nfc1000
        data = [2.5 1.5 -1 -2 -3.5 -6 -8.5 -11.5 -15.5];
    elseif flags.do_nfc2000
        data = [3 2 0 -2 -3.5 -4 -4.5 -9 -12.5 -17];
    elseif flags.do_nfc400
        data = [2 3 0 -1.5 -2.5 -5.5 -4.5 -5.5 -8.5 -13];
    end
    
elseif flags.do_fig1_N0Spi
    if flags.do_nfc125
        data= [-20 -19.5 -18.5 -17 -16.7 -19.7];
    elseif flags.do_nfc250
        data = [-22.5 -23 -22.5 -23.5 -23 -25 -27.5];
    elseif flags.do_nfc500
        data = [-21 -22 -23.5 -23.3 -23 -24 -25.5 -29.5];
    elseif flags.do_nfc1000
        data = [-18.5 -19.5 -19.5 -20 -21 -19 -18 -22 -22.5];
    elseif flags.do_nfc2000
        data = [-13.5  -14.5 -13.7 -16 -16.5 -13.3 -13.7 -13.5 -17 -21];
    elseif flags.do_nfc400
        data = [-9.5 -8.5 -9.5 -8.5 -11.7 -12.5 -11.5 -10.5 -10 -15];
    end
    
elseif flags.do_fig1_NpiS0
    if flags.do_nfc125
        data=  [-14 -14.5 -12.5 -8.5 -7 -12];
    elseif flags.do_nfc250
        data = [-17 -18.5 -18 -16 -14.5 -19 -21];
    elseif flags.do_nfc500
        data = [-17.5 -20.5 -18.5 -18.5 -18 -19 -22.5 -26];
    elseif flags.do_nfc1000
        data = [-16 -17.5 -16.5 -18 -18 -17 -16 -19.5 -22.5];
    elseif flags.do_nfc2000
        amtdisp('Not available');
        data = [];
    elseif flags.do_nfc4000
        amtdisp('Not available');
        data = [];
    end
        
end