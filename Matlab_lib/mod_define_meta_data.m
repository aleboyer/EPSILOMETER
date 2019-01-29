%% Create folder and meta data structure of an Epsilometer mission
%  The schematic of this structure can be found on confluence
function Meta_Data=mod_define_meta_data(Meta_Data)

%% Define main names 

%% create mission folders
mission_folder_L0=fullfile(Meta_Data.path_mission,...
                           Meta_Data.mission);
mission_folder_L1=fullfile(mission_folder_L0,...
                        Meta_Data.vehicle_name);
mission_folder_L2=fullfile(mission_folder_L1,...
                        Meta_Data.deployment);
                    
L1path   = fullfile(mission_folder_L2,'L1');
Epsipath = fullfile(mission_folder_L2,'epsi');
CTDpath  = fullfile(mission_folder_L2,'ctd');
RAWpath  = fullfile(mission_folder_L2,'raw');
SDRAWpath  = fullfile(mission_folder_L2,'sd_raw');

                                            
if ~exist(mission_folder_L0,'dir')
    %% create paths
    eval([ '!mkdir ' mission_folder_L0]);
    eval([ '!mkdir ' mission_folder_L1]);
    eval([ '!mkdir ' mission_folder_L2]);
    eval([ '!mkdir ' L1path]);
    eval([ '!mkdir ' Epsipath]);
    eval([ '!mkdir ' CTDpath]);
    eval([ '!mkdir ' RAWpath]);
end

%% add path fields
Meta_Data.root     = mission_folder_L2;
Meta_Data.L1path   = L1path;
Meta_Data.Epsipath = Epsipath;
Meta_Data.CTDpath  = CTDpath;
Meta_Data.RAWpath  = RAWpath;
Meta_Data.SDRAWpath  = SDRAWpath;

%add PROCESS fields
if ~isfield(Meta_Data,'PROCESS')
    Meta_Data.PROCESS.nb_channels=8;
    Meta_Data.PROCESS.channels={'t1','t2','s1','s2','c','a1','a2','a3'};
    Meta_Data.PROCESS.recording_mod='SD';
end

% add MADRE fields
if ~isfield(Meta_Data,'MADRE')
    Meta_Data.MADRE.rev='MADREB.0';
    Meta_Data.MADRE.SN='0002';
end
% add MAP fields
if ~isfield(Meta_Data,'MAP')
    Meta_Data.MAP.rev='MAP.0';
    Meta_Data.MAP.SN='0001';
    Meta_Data.MAP.temperature='';
    Meta_Data.MAP.shear='CAmp1.0';
end

%% add Firmware fields
if ~isfield(Meta_Data,'Firmware')
    Meta_Data.Firmware.version='MADRE2.1';
    Meta_Data.Firmware.sampling_frequency='320Hz';
    Meta_Data.Firmware.ADCshear='Unipolar';
    Meta_Data.Firmware.ADC_FPO7='Unipolar';
    Meta_Data.Firmware.ADC_accellerometer='Unipolar';
    Meta_Data.Firmware.ADC_cond='count';
    Meta_Data.Firmware.ADCfilter='sinc4';
end


Meta_Data.epsi.s1.ADCconf=Meta_Data.Firmware.ADCshear; % serial number;
Meta_Data.epsi.s2.ADCconf=Meta_Data.Firmware.ADCshear; % serial number;
Meta_Data.epsi.t1.ADCconf=Meta_Data.Firmware.ADC_FPO7; % serial number;
Meta_Data.epsi.t2.ADCconf=Meta_Data.Firmware.ADC_FPO7; % serial number;
Meta_Data.epsi.c.ADCconf=Meta_Data.Firmware.ADC_cond; % serial number;
Meta_Data.epsi.a1.ADCconf=Meta_Data.Firmware.ADC_accellerometer; % serial number;
Meta_Data.epsi.a2.ADCconf=Meta_Data.Firmware.ADC_accellerometer; % serial number;
Meta_Data.epsi.a3.ADCconf=Meta_Data.Firmware.ADC_accellerometer; % serial number;

Meta_Data.epsi.s1.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.s2.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.t1.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.t2.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.c.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.a1.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.a2.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;
Meta_Data.epsi.a3.ADCfilter=Meta_Data.Firmware.ADCfilter; % serial number;


Meta_Data.epsi.shearcal_path=fullfile(Meta_Data.process,'CALIBRATION','SHEAR_PROBES');
Meta_Data.epsi=get_shear_calibration(Meta_Data.epsi);    % Calibration number

Meta_Data=get_filters_name_MADRE(Meta_Data);

Meta_Data.CALIpath=fullfile(Meta_Data.process,'CALIBRATION','ELECTRONICS');

save(fullfile(Meta_Data.RAWpath, ...
    ['Meta_' Meta_Data.mission '_' Meta_Data.deployment '.mat']),'Meta_Data')
end
