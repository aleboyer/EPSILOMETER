
MISSION_NAME='DEV';
VEHICLE_NAME='bench132';
DEPLOYMENT_NAME='SD_FIX';
PATH_MISSION='/Users/aleboyer/ARNAUD/SCRIPPS/';
SCRIPT_MISSION='/Users/aleboyer/ARNAUD/SCRIPPS/';
 
if exist(fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME)) ~= 7
    mkdir(fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME),'ctd')
    mkdir(fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME),'epsi')
    mkdir(fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME),'L1')
    mkdir(fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME),'raw')
    mkdir(fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME),'sd_raw')
end

RAW_DATA_FILENAME='MADREtest.dat';
RECORDING_MODE='SD';  % other choice is SD or STREAMING
NB_CHANNEL='8';
CHANNELS='t1,t2,s1,s2,c,a1,a2,a3';
 
PROBE_S1_SN='109';
PROBE_S2_SN='123';
PROBE_T1_SN='123';
PROBE_T2_SN='120';
PROBE_C_SN='000';
PROBE_SHEAR_CALFILE='/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/CALIBRATION/SHEAR_PROBES';
 
AUX1_NAME = 'SBE49';
AUX1_SN = '0058';
AUX1_CALFILE= [SCRIPT_MISSION,'EPSILOMETER/' AUX1_NAME '/' AUX1_SN '.cal'];



MADRE_REV='MADREB.0';
MADRE_SN='0002';
 
MAP_REV='MAPB.0';
MAP_SN='0001';
 
FIRMWARE_VERSION='MADRE2.1';
FIRMWARE_SAMPLING='325Hz';
FIRMWARE_ADCshear='unipolar';
FIRMWARE_ADCFPO7='unipolar';
FIRMWARE_ADCcond='count';
FIRMWARE_ADCaccellerometer='unipolar';
FIRMWARE_ADCshearfilt='sinc4';
FIRMWARE_ADCfpo7filt='sinc4';
FIRMWARE_ADCcondfilt='none';
FIRMWARE_ADCaccelfilt='sinc4';


%%

 
Meta_Data.mission = MISSION_NAME;
Meta_Data.vehicle_name = VEHICLE_NAME;
Meta_Data.deployement = DEPLOYMENT_NAME;
Meta_Data.path_mission = PATH_MISSION;
 
Meta_Data.root = fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME); 
Meta_Data.L1path = fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME,'L1/');
Meta_Data.Epsipath = fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME,'epsi/');
Meta_Data.CTDpath = fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME,'ctd/');
Meta_Data.RAWpath = fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME,'raw/');
Meta_Data.SDRAWpath = fullfile(PATH_MISSION,MISSION_NAME,VEHICLE_NAME,DEPLOYMENT_NAME,'sd_raw/');
 

Meta_Data.PROCESS.nb_channels = NB_CHANNEL;
Meta_Data.PROCESS.channels = CHANNELS; 
Meta_Data.PROCESS.recording_mode = RECORDING_MODE; 

Meta_Data.MADRE.rev = MADRE_REV;
Meta_Data.MADRE.SN = MADRE_SN;
 
Meta_Data.MAP.rev = MAP_REV;
Meta_Data.MAP.SN = MAP_SN;
 
Meta_Data.Firmware.version = FIRMWARE_VERSION;
Meta_Data.Firmware.sampling_frequency = FIRMWARE_SAMPLING;
Meta_Data.Firmware.ADCshear = FIRMWARE_ADCshear;
Meta_Data.Firmware.ADC_FPO7 = FIRMWARE_ADCFPO7;
Meta_Data.Firmware.ADC_cond = FIRMWARE_ADCcond;
Meta_Data.Firmware.ADC_accellerometer = FIRMWARE_ADCaccellerometer;
 
Meta_Data.aux1.name = AUX1_NAME;
Meta_Data.aux1.SN = AUX1_SN;
Meta_Data.aux1.cal_file = AUX1_CALFILE;
 

Meta_Epsi.shearcal_path = PROBE_SHEAR_CALFILE;

path2file1=  sprintf('%s/%s/Calibration_%s.txt', Meta_Epsi.shearcal_path,PROBE_S1_SN,PROBE_S1_SN);
path2file2=  sprintf('%s/%s/Calibration_%s.txt', Meta_Epsi.shearcal_path,PROBE_S2_SN,PROBE_S2_SN);
strs1 = strsplit(fscanf(fopen(path2file1),'%s'),','); 
strs2 = strsplit(fscanf(fopen(path2file2),'%s'),',');

Meta_Data.epsi.s1.SN = str2double(PROBE_S1_SN);
Meta_Data.epsi.s1.Sv = str2double(strs1{end-1});
Meta_Data.epsi.s1.ADCfilter = FIRMWARE_ADCshearfilt;
Meta_Data.epsi.s1.ADCconf = FIRMWARE_ADCshear;
 
Meta_Data.epsi.s2.SN = str2double(PROBE_S2_SN);
Meta_Data.epsi.s2.Sv = str2double(strs2{end-1});
Meta_Data.epsi.s2.ADCfilter = FIRMWARE_ADCshearfilt;
Meta_Data.epsi.s2.ADCconf = FIRMWARE_ADCshear; 

Meta_Data.epsi.t1.SN = str2double(PROBE_T1_SN);
Meta_Data.epsi.t1.ADCfilter = FIRMWARE_ADCfpo7filt;
Meta_Data.epsi.t1.ADCconf = FIRMWARE_ADCFPO7;

Meta_Data.epsi.t2.SN = str2double(PROBE_T2_SN);
Meta_Data.epsi.t2.ADCfilter = FIRMWARE_ADCfpo7filt;
Meta_Data.epsi.t2.ADCconf = FIRMWARE_ADCFPO7;


Meta_Data.epsi.a1.ADCfilter = FIRMWARE_ADCaccelfilt;
Meta_Data.epsi.a1.ADCconf = FIRMWARE_ADCaccellerometer;
 
Meta_Data.epsi.a2.ADCfilter = FIRMWARE_ADCaccelfilt;
Meta_Data.epsi.a2.ADCconf = FIRMWARE_ADCaccellerometer;

Meta_Data.epsi.a3.ADCfilter = FIRMWARE_ADCaccelfilt;
Meta_Data.epsi.a3.ADCconf = FIRMWARE_ADCaccellerometer;

Meta_Data.epsi.c.SN = str2double(PROBE_C_SN);
Meta_Data.epsi.c.ADCfilter = FIRMWARE_ADCcondfilt;
Meta_Data.epsi.c.ADCconf = FIRMWARE_ADCcond;

if strcmp(RECORDING_MODE,'SD')
   save([Meta_Data.SDRAWpath ...
    'Meta_' Meta_Data.mission ...
    '_' Meta_Data.deployement '.mat'],'Meta_Data')
end
if strcmp(RECORDING_MODE,'STREAMING')
   save([Meta_Data.RAWpath ...
    'Meta_' Meta_Data.mission ...
    '_' Meta_Data.deployement '.mat'],'Meta_Data')
end

