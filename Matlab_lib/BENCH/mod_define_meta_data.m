%% Create folder and meta data structure of an Epsilometer mission
%  The schematic of this structure can be found on confluence
function Meta_Data=mod_define_meta_data(Meta_Data)

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


if strcmp(Meta_Data.epsi.s1.SN,'0000')
    Meta_Data.epsi.shearcal_path=fullfile(Meta_Data.process,'CALIBRATION','SHEAR_PROBES');
    Meta_Data.epsi=get_shear_calibration(Meta_Data.epsi);    % Calibration number
end

Meta_Data=get_filters_name_MADRE(Meta_Data);

% TODO: we ARE calibration de board. need to save the result  
%Meta_Data.CALIpath=fullfile(Meta_Data.process,'CALIBRATION','ELECTRONICS');

switch Meta_Data.PROCESS.recording_mod
    case 'STREAMING'
        save(fullfile(Meta_Data.RAWpath, ...
            ['Meta_' Meta_Data.mission '_' Meta_Data.deployment '.mat']),'Meta_Data')
    case 'SD'
        save(fullfile(Meta_Data.SDRAWpath, ...
            ['Meta_' Meta_Data.mission '_' Meta_Data.deployment '.mat']),'Meta_Data')
end

end
