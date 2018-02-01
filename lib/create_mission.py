#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 29 11:22:29 2018
create Epsilometer environement 

@author: aleboyer
"""

import os

import sys
sys.path.insert(0,'lib')

from EPSIlib import get_shear_calibration
from EPSIlib import get_filters_name_MADRE


class Meta_Data_class:
    pass

Meta_Data=Meta_Data_class
## Define main names 
Meta_Data.mission='DEV';
Meta_Data.vehicle_name='benchSPROUL';
Meta_Data.deployement='d1';
Meta_Data.path_mission='/Volumes/KINGSTON/';
Meta_Data.vehicle='bench';   # 'WireWalker' or 'FastCTD'

## create mission folders
mission_folder_L0 = '%s/%s' %(Meta_Data.path_mission,Meta_Data.mission);
mission_folder_L1 = '%s/%s' %(mission_folder_L0,Meta_Data.vehicle_name);
mission_folder_L2 = '%s/%s' %(mission_folder_L1,Meta_Data.deployement);
                    
L1path   = '%s/L1/'   % mission_folder_L2;
Epsipath = '%s/epsi/' % mission_folder_L2;
CTDpath  = '%s/ctd/'  % mission_folder_L2;
RAWpath  = '%s/raw/'  % mission_folder_L2;

                                            
## create paths
if os.path.isdir(mission_folder_L0)==False:
    os.mkdir(mission_folder_L0);
if os.path.isdir(mission_folder_L1)==False:
    os.mkdir(mission_folder_L1);
if os.path.isdir(mission_folder_L2)==False:
    os.mkdir(mission_folder_L2);
if os.path.isdir(L1path)==False:
    os.mkdir(L1path);
if os.path.isdir(Epsipath)==False:
    os.mkdir(Epsipath);
if os.path.isdir(CTDpath)==False:
    os.mkdir(CTDpath);
if os.path.isdir(RAWpath)==False:
    os.mkdir(RAWpath);




## add path fields
Meta_Data.root     = mission_folder_L2;
Meta_Data.L1path   = L1path;
Meta_Data.Epsipath = Epsipath;
Meta_Data.CTDpath  = CTDpath;
Meta_Data.RAWpath  = RAWpath;


## add Hardware fields
class MADRE_class:
    pass
Meta_Data.MADRE=MADRE_class
Meta_Data.MADRE.rev='MADREB.0';
Meta_Data.MADRE.SN='0002';

class MAP_class:
    pass
Meta_Data.MAP=MAP_class
Meta_Data.MAP.rev='MAPB.0';
Meta_Data.MAP.SN='0001';



## add Firmware fields
class Firmware_class:
    pass
Meta_Data.Firmware=Firmware_class
Meta_Data.Firmware.version='MADRE2.1';
Meta_Data.Firmware.sampling_frequency='320Hz';
Meta_Data.Firmware.ADCshear='Unipolar';
Meta_Data.Firmware.ADC_FPO7='Unipolar';
Meta_Data.Firmware.ADC_accellerometer='Unipolar';

## add auxillary device field
class Aux1_class:
    pass
Meta_Data.aux1=Aux1_class
Meta_Data.aux1.name = 'SBE49';
Meta_Data.aux1.SN   = '00000';
Meta_Data.aux1.cal_file='path/to/file';

## add channels fields
class epsi_class:
    pass

class shear_sensor_class:
     def __init__(self,SN):
        self.SN = SN
        self.Sv = '0'
        self.ADCfilter = 'None'

class temp_sensor_class:
     def __init__(self,SN):
        self.SN = SN
        self.ADCfilter = 'None'


Meta_Data.epsi=epsi_class
Meta_Data.epsi.s1=shear_sensor_class('102')
Meta_Data.epsi.s2=shear_sensor_class('102')
Meta_Data.epsi.t1=temp_sensor_class('000')
Meta_Data.epsi.t2=temp_sensor_class('000')


Meta_Data.epsi.shearcal_path='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/SHEAR_PROBES';
Meta_Data.epsi=get_shear_calibration(Meta_Data.epsi)

Meta_Data=get_filters_name_MADRE(Meta_Data);


fid=open('%sMeta_%s_%s.dat' % (Meta_Data.RAWpath, Meta_Data.mission,Meta_Data.deployement) \
         ,'w');

fid.write('mission: %s\r\n' % Meta_Data.mission)
fid.write('vehicle_name: %s\r\n' %Meta_Data.vehicle_name)
fid.write('deployement: %s\r\n' %Meta_Data.deployement)
fid.write('path_mission: %s\r\n' %Meta_Data.path_mission)
fid.write('vehicle: %s\r\n' %Meta_Data.vehicle)
fid.write('root: %s\r\n' %Meta_Data.root)
fid.write('L1path:%s\r\n' %Meta_Data.L1path)
fid.write('Epsipath: %s\r\n'%Meta_Data.Epsipath)
fid.write('CTDpath: %s\r\n' %Meta_Data.CTDpath)
fid.write('RAWpath: %s\r\n' %Meta_Data.RAWpath)
fid.write('\r\n')

fid.write('MADRE:\r\n')
fid.write('    rev: %s\r\n' %Meta_Data.MADRE.rev)
fid.write('    SN: %s\r\n' %Meta_Data.MADRE.SN)
fid.write('\r\n')

fid.write('MAP:\r\n')
fid.write('    rev: %s\r\n' %Meta_Data.MAP.rev)
fid.write('    SN: %s\r\n' %Meta_Data.MAP.SN)
fid.write('\r\n')

fid.write('Firmware:\r\n')
fid.write('    version: %s\r\n' %Meta_Data.Firmware.version)
fid.write('    sampling_frequency: %s\r\n' %Meta_Data.Firmware.sampling_frequency)
fid.write('    ADCshear: %s\r\n' %Meta_Data.Firmware.ADCshear)
fid.write('    ADC_FPO7: %s\r\n' %Meta_Data.Firmware.ADC_FPO7)
fid.write('    ADC_accellerometer: %s\r\n' %Meta_Data.Firmware.ADC_accellerometer)
fid.write('\r\n')

fid.write('aux1:\r\n')
fid.write('    name: %s\r\n' %Meta_Data.aux1.name)
fid.write('    SN: %s\r\n' %Meta_Data.aux1.SN)
fid.write('    cal_file: %s\r\n' %Meta_Data.aux1.cal_file)
fid.write('\r\n')

fid.write('epsi:\r\n')
fid.write('    s1:\r\n')
fid.write('        SN: %s\r\n' %Meta_Data.epsi.s1.SN)
fid.write('        Sv: %s\r\n' %Meta_Data.epsi.s1.Sv)
fid.write('        ADCfilter: %s\r\n' %Meta_Data.epsi.s1.ADCfilter)
fid.write('    s2:\r\n')
fid.write('        SN: %s\r\n' %Meta_Data.epsi.s2.SN)
fid.write('        Sv: %s\r\n' %Meta_Data.epsi.s2.Sv)
fid.write('        ADCfilter: %s\r\n' %Meta_Data.epsi.s2.ADCfilter)
fid.write('    t1:\r\n')
fid.write('      SN: %s\r\n'  %Meta_Data.epsi.t1.SN)
fid.write('      ADCfilter: %s\r\n' %Meta_Data.epsi.t1.ADCfilter)
fid.write('    t2:\r\n')
fid.write('        SN: %s\r\n' %Meta_Data.epsi.t2.SN)
fid.write('        ADCfilter: %s\r\n' %Meta_Data.epsi.t2.ADCfilter)
fid.write('    shearcal_path: %s\r\n' %Meta_Data.epsi.shearcal_path)
fid.flush()
fid.close()

print(Meta_Data.RAWpath)




