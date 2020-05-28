% process FOOBAR mission
%
% Make a copy of this file for each deployment you want to process and
% rename it accordingly (e.g
% process_[mission]_[vehicle_name]_[deployment].m)
%
% I want to stress the importance of creating this Meta_Data structure
% BEFORE deployment. It will help the user to remember details if
% engineering notes are not sufficient. I am talking from experience here.
% -------------------------------------------------------------------------

% point to EPSI libraries
process_dir='/Volumes/GoogleDrive/My Drive/WORK/EPSILOMETER/';
Meta_Data.path_mission='/Volumes/GoogleDrive/My Drive/DATA/';
Meta_Data.mission='FOOBAR';
Meta_Data.vehicle_name='FOOBAR';
Meta_Data.deployment='FOOBAR';
Meta_Data.vehicle='WW';   % 'WireWalker' or 'FISH'
Meta_Data.process_dir=process_dir;

Meta_Data.PROCESS.nb_channels=8;
Meta_Data.PROCESS.channels={'t1','t2','s1','s2','c','a1','a2','a3'};
Meta_Data.PROCESS.recording_mode='SD';
Meta_Data.PROCESS.tscan=6;
Meta_Data.PROCESS.Fs_epsi=325;
Meta_Data.PROCESS.Fs_ctd=8;
Meta_Data.PROCESS.nfft=Meta_Data.PROCESS.tscan*Meta_Data.PROCESS.Fs_epsi;
Meta_Data.PROCESS.nfftc=floor(Meta_Data.PROCESS.nfft/3);
Meta_Data.PROCESS.ctd_fc=45;  %45 Hz
Meta_Data.PROCESS.dz=.25;  %45 Hz
Meta_Data.PROCESS.fc1=5;
Meta_Data.PROCESS.fc2=35;
% this  depth range to compute the coherence.
% this WILL choke when depth is varying.
% TODO change the coherence estimation to use a range in percentage of the
% profile
Meta_Data.PROCESS.Prmin=20; % 20 m for a 100m profile
Meta_Data.PROCESS.Prmax=80; % 80 m for a 100 profile

[~,Meta_Data.PROCESS.fe] = pwelch(0*(1:Meta_Data.PROCESS.nfft),...
                Meta_Data.PROCESS.nfft,[], ...
                Meta_Data.PROCESS.nfft, ...
                Meta_Data.PROCESS.Fs_epsi,'psd');

%% add auxillary device field
Meta_Data.CTD.name = 'SBE49';
Meta_Data.CTD.SN   = '0000';
Meta_Data.CTD.cal_file=[Meta_Data.process_dir '/SBE49/' Meta_Data.CTD.SN '.cal'];

%% add channels fields
% Meta_Data.epsi.s1.SN='216'; % serial number;
Meta_Data.epsi.s1.SN='000'; % serial number;
Meta_Data.epsi.s2.SN='000'; % serial number;
Meta_Data.epsi.t1.SN='000'; % serial number;
Meta_Data.epsi.t2.SN='000'; % serial number;

Meta_Data.MAP.rev='MAP.0';
Meta_Data.MAP.SN='0003';
Meta_Data.MAP.temperature='';
Meta_Data.MAP.shear='CAmp1.0';

%%

addpath(process_dir)
first_time=0;
% point to EPSI libraries
EPSI_matlab_path(process_dir); % EPSI_matlab_path is under ~/ARNAUD/SCRIPPS/EPSILOMETER/
% create Meta_Data
Meta_Data=mod_define_meta_data(Meta_Data);
Meta_Data.PROCESS.h_freq=mod_epsilometer_get_EFE_filters(Meta_Data,fe);
%%
load(fullfile(Meta_Data.path_mission,'EPSIWW/WW/EPSI_new/d1/epsi/EpsiProfile.mat'))

% id profile
id_profile=10;

% Tscan 50 scan
display=0;tscan=50;
titleStr = strrep([Meta_Data.mission ' ' Meta_Data.vehicle_name ' ' Meta_Data.deployment],'_','\_');
switch Meta_Data.vehicle
    case 'FISH'
        datachoice = 'datadown';
    case 'WW'
        datachoice = 'dataup';
end
Meta_Data=mod_epsi_temperature_spectra(Meta_Data, ...
                                       EpsiProfiles.(datachoice){id_profile}, ...
                                       CTDProfiles.(datachoice){id_profile},...
                                       titleStr,id_profile,display,tscan);

mod_epsilometer_batch_process(Meta_Data);

%% define TF to get a qc flag
% TODO do not forget to change the listfile for loop back to length(listfile)
[MS,minepsi,~]=mod_epsilometer_concat_MS(Meta_Data);
%% compute TF between a1 and
[H1,H2,fH]=create_velocity_tranfer_function(MS,minepsi,Meta_Data);
%% compute qc flags
%  fc1 and fc2 define the frequency range integration for qc.
mod_epsilometer_add_sh_quality_flag(Meta_Data,H1,H2,fH)

%%
[MS,~,~]=mod_epsilometer_concat_MS(Meta_Data);
Map   =mod_epsilometer_grid_turbulence(Meta_Data,MS);
mod_epsilometer_grid_plot(Map,Meta_Data)

%%

mod_epsilometer_binned_epsilon(Meta_Data,MS)
% mod_epsilometer_binned_chi(Meta_Data,MS)
