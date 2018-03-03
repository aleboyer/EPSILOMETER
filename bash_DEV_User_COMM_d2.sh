#!/bin/bash
# declare STRING variable

MISSION_NAME="GRANITE"
VEHICLE_NAME="GRANITE"
DEPLOYMENT_NAME="d1"
PATH_MISSION="/Users/aleboyer/ARNAUD/SCRIPPS/SHEAR_PROBE/"
VEHICLE="MADREGRANITE"

MADRE_REV="MADREB.0"
MADRE_SN="0002"

MAP_REV="MAPB.0"
MAP_SN="0001"

FIRMWARE_VERSION="MADRE2.1"
FIRMWARE_SAMPLING="320Hz"
FIRMWARE_ADCshear="Unipolar"
FIRMWARE_ADCFPO7="Unipolar"
FIRMWARE_ADCaccellerometer="Unipolar"

AUX1_NAME="SBE49"
AUX1_SN="0058"
AUX1_CALFILE="SBE49/0058.dat"

## 105 is 8k ohms
## 102 is 200kohms
PROBE_S1_SN="103"
PROBE_S2_SN="104"
PROBE_T1_SN="102"
PROBE_T2_SN="105"

PROBE_SHEAR_CALFILE="/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/SHEAR_PROBES"

RAW_DATA_FILENAME="MADREshipping_GRANITE.dat"
RECORDING_MODE="STREAMING"  # other choise is SD

declare PATHS=(`python lib/create_mission_from_bash_mission.py $MISSION_NAME $VEHICLE_NAME $DEPLOYMENT_NAME $PATH_MISSION $VEHICLE $MADRE_REV $MADRE_SN $MAP_REV $MAP_SN $FIRMWARE_VERSION $FIRMWARE_SAMPLING $FIRMWARE_ADCshear $FIRMWARE_ADCFPO7 $FIRMWARE_ADCaccellerometer $AUX1_NAME $AUX1_SN $AUX1_CALFILE $PROBE_S1_SN $PROBE_S2_SN $PROBE_T1_SN $PROBE_T2_SN $PROBE_SHEAR_CALFILE`) 
  
#print variable on a screen
sed -e "s+FILENAME+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/store_MADRE2.1.py>tempo_storeMADRE.py
sed -e "s+PATH+${PATHS[0]}+g" <tempo_storeMADRE.py>store_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py
rm tempo_storeMADRE.py
echo ${PATHS[0]}
echo ${PATHS[1]}
echo ${PATHS[2]}
sed -e "s+RAWFILE+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/read_MADRE2.1.py>tempo_readMADRE.py
sed -e "s+RAWPATH+${PATHS[0]}+g" <tempo_readMADRE.py>tempo1_readMADRE.py
sed -e "s+EPSIFILE+${PATHS[1]}${RAW_DATA_FILENAME}+g" <tempo1_readMADRE.py>tempo2_readMADRE.py
sed -e "s+EPSIPATH+${PATHS[1]}+g" <tempo2_readMADRE.py>tempo3_readMADRE.py
sed -e "s+CTDFILE+${PATHS[2]}${RAW_DATA_FILENAME}+g" <tempo3_readMADRE.py>tempo4_readMADRE.py
sed -e "s+CTDPATH+${PATHS[2]}+g" <tempo4_readMADRE.py>read_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py
rm tempo_readMADRE.py
rm tempo1_readMADRE.py
rm tempo2_readMADRE.py
rm tempo3_readMADRE.py
rm tempo4_readMADRE.py


sed -e "s+RAWFILE+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/plot_MADRE2.1_realtime.py>tempo_plotMADRE.py
sed -e "s+RAWPATH+${PATHS[0]}+g" <tempo_plotMADRE.py>plot_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}_realtime.py
rm tempo_plotMADRE.py

cp bash_mission.sh bash_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.sh

cp *_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}* ${PATHS[0]}/../ 
