Meta_Data.RAWpath='../STREAMING/';
Meta_Data.SDRAWpath='../SD/';
Meta_Data.CTDpath='../CTD';
Meta_Data.Epsipath='../EPSI/';
Meta_Data.L1path='../L1/';

Meta_Data.PROCESS.nb_channels=8;
Meta_Data.PROCESS.channels={'t1','t2','s1','s2','c','a1','a2','a3'};
Meta_Data.PROCESS.recording_mod='SD';

Meta_Data.MADRE.rev='MADREB.0';
Meta_Data.MADRE.SN='0002';

Meta_Data.MAP.rev='MAP.0';
Meta_Data.MAP.SN='0001';
Meta_Data.MAP.temperature='';
Meta_Data.MAP.shear='CAmp1.0';
Meta_Data.MAP.temperature='Tdiff';
Meta_Data.MAP.shear='CAmp1.0';

Meta_Data.Firmware.version='SAN';
Meta_Data.Firmware.sampling_frequency='320Hz';
Meta_Data.Firmware.ADCshear='Unipolar';
Meta_Data.Firmware.ADC_FPO7='Unipolar';
Meta_Data.Firmware.ADC_accellerometer='Unipolar';
Meta_Data.Firmware.ADC_cond='count';
Meta_Data.Firmware.ADCfilter='sinc4';

%% add auxillary device field
Meta_Data.aux1.name = 'SBE49';
Meta_Data.aux1.SN   = '0000';

%% add channels fields
Meta_Data.epsi.s1.SN='000'; % serial number;
Meta_Data.epsi.s2.SN='000'; % serial number;
Meta_Data.epsi.t1.SN='000'; % serial number;
Meta_Data.epsi.t2.SN='000'; % serial number;

Meta_Data=mod_define_meta_data(Meta_Data);

