% point t o EPSI libraries
process_dir='path to the library';
% path to the data
Meta_Data.path_mission='parth to the data';
% mission name
Meta_Data.mission='FOO';
% name of the vehicle
Meta_Data.vehicle_name='FOO';
% name of deployment
Meta_Data.deployment='FOO';
% Kind of Vehicle Wirewalker (WW) or epsifish (FISH)
Meta_Data.vehicle='FOO';   % 'WireWalker' or 'FastCTD'
% path to EPSI libraries
Meta_Data.process=process_dir;   % 'WireWalker' or 'FastCTD'

% number of channels
Meta_Data.PROCESS.nb_channels=8;
% channels names. default: {'t1','t2','s1','s2','c','a1','a2','a3'}
Meta_Data.PROCESS.channels={'t1','t2','s1','s2','c','a1','a2','a3'};
% recording mode (STREAMING or SD)
Meta_Data.PROCESS.recording_mod='STREAMING';  % STREAMING for FastCTD or SD for Fishing reel or WW

%% add auxillary device field
Meta_Data.aux1.name = 'SBE49';
Meta_Data.aux1.SN   = 'FOO'; % serial number of the SDE49. It requires to get the data from the SBE before hand
% TODO: epsi should be able to get the cal numbers from SBE directly and
% store them at he beigging of each data file.
Meta_Data.aux1.cal_file=[Meta_Data.process '/SBE49/' Meta_Data.aux1.SN '.cal'];

%% add channels fields
Meta_Data.epsi.s1.SN='123'; % shear 1 probe serial number;
Meta_Data.epsi.s2.SN='136'; % shear 2 probe serial number;
Meta_Data.epsi.t1.SN='119'; % FPO7 1 probe serial number;
Meta_Data.epsi.t2.SN='119'; % FPO7 2 probe serial number;

Meta_Data.MAP.rev='MAP.0';
Meta_Data.MAP.SN='0003';
Meta_Data.MAP.temperature='Tdiff';
Meta_Data.MAP.shear='CAmp1.0';

Meta_Data.name_ctd=['ctd_' Meta_Data.deployment];

% addpath to matlab
addpath(process_dir)
% Flag to re-read the binary files and compute the profile
first_time=1;
% point to EPSI libraries
EPSI_matlab_path(process_dir); % EPSI_matlab_path is under ~/ARNAUD/SCRIPPS/EPSILOMETER/
% Fill the remaining field for meta data
Meta_Data=mod_define_meta_data(Meta_Data);

% get SBE calibration coef. 
Meta_Data.SBEcal=get_CalSBE(Meta_Data.aux1.cal_file);


%%
mod_epsi_read_rawfiles(Meta_Data);
min_depth=2;
crit_depth=10;
mod_create_profiles(Meta_Data,min_depth,crit_depth)
    
    
if ~exist('CTD_Profiles','var')
    load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfiles','EpsiProfiles');
    CTD_Profiles=CTDProfiles.datadown;
    EPSI_Profiles=EpsiProfiles.datadown;
end
i=30; % Profiles you want to use to define dT/dV (conversion volt to degree celcius)
display=0; %TODO remove display
tscan=30; % length is second of the segment you want to use to perform the fft.
Meta_Data=mod_epsi_temperature_spectra(Meta_Data,EPSI_Profiles{i},CTD_Profiles{i}, ...
    'FOO FOO downcast',i,display,tscan);

% compute the MS structure with epsilon and chi
MS=EPSI_batchprocess(Meta_Data);

%% correct coherence
listfile=dir(fullfile(Meta_Data.L1path,'Turbulence_Profiles*.mat'));
listfilename=natsort({listfile.name});
count=0;
for f=1:length(listfile)
    clear MS
    load(fullfile(listfile(f).folder,listfilename{f}),'MS')
    fprintf(fullfile(listfile(1).folder,listfilename{f}))
    for i=1:length(MS)
        count=count+1;
        fprintf('Profile %u over %u\n',i,length(MS))
        MS1{count}=MS{i};
    end
end

plot_binned_turbulence(Meta_Data,MS1)
EPSI_grid_turbulence(Meta_Data,MS1)
