% point t o EPSI libraries
process_dir='~/ARNAUD/SCRIPPS/EPSILOMETER/';
Meta_Data.path_mission='/Volumes/KINGSTON/';

Meta_Data.mission='DEV';
Meta_Data.vehicle_name='madre';
Meta_Data.deployment='d1';
Meta_Data.vehicle='WW';   % 'WireWalker' or 'FastCTD'
Meta_Data.process=process_dir;   % 'WireWalker' or 'FastCTD'

Meta_Data.PROCESS.nb_channels=8;
Meta_Data.PROCESS.channels={'t1','t2','s1','s2','c','a1','a2','a3'};
Meta_Data.PROCESS.recording_mod='SD';

%% add auxillary device field
Meta_Data.aux1.name = 'SBE49';
Meta_Data.aux1.SN   = '0058';
Meta_Data.aux1.cal_file=[Meta_Data.process '/SBE49/' Meta_Data.aux1.SN '.cal'];

%% add channels fields
Meta_Data.epsi.s1.SN='120'; % serial number;
Meta_Data.epsi.s2.SN='211'; % serial number;
Meta_Data.epsi.t1.SN='139'; % serial number;
Meta_Data.epsi.t2.SN='145'; % serial number;

Meta_Data.MAP.rev='MAP.0';
Meta_Data.MAP.SN='0001';
Meta_Data.MAP.temperature='Tdiff';
Meta_Data.MAP.shear='CAmp1.0';


addpath(process_dir)
first_time=0;
% point to EPSI libraries
EPSI_matlab_path(process_dir); % EPSI_matlab_path is under ~/ARNAUD/SCRIPPS/EPSILOMETER/
% create Meta_Data
Meta_Data=mod_define_meta_data(Meta_Data);


% get SBE coef to convert the SBE words into physical values
%Meta_Data.SBEcal=get_CalSBE(Meta_Data.aux1.cal_file);
% start time
starttime=datenum('01-Jan-2020 00:00:00');
Meta_Data.starttime=starttime;


if first_time==1
    % read raw data
    mod_epsi_read_rawfiles(Meta_Data);
    crit_speed=.3;
    crit_filt=500;
    % split data into profiles
    EPSI_create_profiles(Meta_Data,crit_speed,crit_filt)
    
    
    if ~exist('CTD_Profiles','var')
        load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfile','EpsiProfile');
        CTD_Profiles=CTDProfile.datadown;
        EPSI_Profiles=EpsiProfile.datadown;
    end
    i=30
    display=0;
    % Vot to Celsius conversion
    % tscan in second. I split the time series in segements.
    % Tscan is the length of the segment
    tscan=50;
    ctd_df=16;
    mod_epsi_temperature_spectra(Meta_Data,EPSI_Profiles{i},CTD_Profiles{i}, ...
        'SODA d2 downcast',i,display,tscan,ctd_df)
    
    
    EPSI_batchprocess(Meta_Data)
    plot_binned_turbulence(Meta_Data)
    EPSI_grid_turbulence(Meta_Data)
end

%%
load(fullfile(Meta_Data.L1path,'Meta_data.mat'),'Meta_Data');
load(fullfile(Meta_Data.L1path,'Turbulence_Profiles.mat'))
mod_epsi_chi_epsi_checkprofile(MS,Meta_Data,5)

