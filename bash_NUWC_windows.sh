#!/bin/bash
# declare STRING variable

ROOT=`pwd`
MISSION_NAME="NISKINE"
VEHICLE_NAME="epsifish1"
DEPLOYMENT_NAME="d5"
PATH_MISSION="/Users/Shared/EPSILOMETER/"

MADRE_REV="MADREB.1"
MADRE_SN="001"

MAP_REV="MAPB.0"
MAP_SN="0001a"

FIRMWARE_VERSION="MADRE2.1"
FIRMWARE_SAMPLING="320Hz"
FIRMWARE_ADCshear="Unipolar"
FIRMWARE_ADCFPO7="Unipolar"
FIRMWARE_ADCaccellerometer="Unipolar"

AUX1_NAME="SBE49"
AUX1_SN="0133"
AUX1_CALFILE="$ROOT/SBE49/0133.cal"

## 105 is 8k ohms
## 102 is 200kohms
PROBE_S1_SN="102"
PROBE_S2_SN="112"
PROBE_T1_SN="124"
PROBE_T2_SN="114"

PROBE_SHEAR_CALFILE="CALIBRATION/SHEAR_PROBES"

RAW_DATA_FILENAME="${VEHICLE_NAME}_${DEPLOYMENT_NAME}.dat"
RECORDING_MODE="telemetry"  # other choise is SD

declare PATHS=(`python lib/create_mission_from_bash_mission.py $MISSION_NAME $VEHICLE_NAME $DEPLOYMENT_NAME $PATH_MISSION $VEHICLE_NAME $MADRE_REV $MADRE_SN $MAP_REV $MAP_SN $FIRMWARE_VERSION $FIRMWARE_SAMPLING $FIRMWARE_ADCshear $FIRMWARE_ADCFPO7 $FIRMWARE_ADCaccellerometer $AUX1_NAME $AUX1_SN $AUX1_CALFILE $PROBE_S1_SN $PROBE_S2_SN $PROBE_T1_SN $PROBE_T2_SN $PROBE_SHEAR_CALFILE`) 
  
#print variable on a screen
sed -e "s+FILENAME+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/store_MADRE2.1.py>tempo
sed -e "s+SCRIPTPATH+${ROOT}+g" <tempo>tempo1
sed -e "s+PATH+${PATHS[0]}+g" <tempo1>store_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py
rm tempo
rm tempo1
echo ${PATHS[0]}
echo ${PATHS[1]}
echo ${PATHS[2]}
sed -e "s+RAWFILE+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/read_MADRE2.1.py>tempo_readMADRE.py
sed -e "s+RAWPATH+${PATHS[0]}+g" <tempo_readMADRE.py>tempo1_readMADRE.py
sed -e "s+EPSIFILE+${PATHS[1]}${RAW_DATA_FILENAME}+g" <tempo1_readMADRE.py>tempo2_readMADRE.py
sed -e "s+EPSIPATH+${PATHS[1]}+g" <tempo2_readMADRE.py>tempo3_readMADRE.py
sed -e "s+SBECAL+${AUX1_CALFILE}+g" <tempo3_readMADRE.py> tempo3
sed -e "s+CTDFILE+${PATHS[2]}${RAW_DATA_FILENAME}+g" <tempo3>tempo4_readMADRE.py
sed -e "s+SCRIPTPATH+${ROOT}+g" <tempo4_readMADRE.py>tempo5_readMADRE.py
sed -e "s+CTDPATH+${PATHS[2]}+g" <tempo5_readMADRE.py>read_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py
rm tempo_readMADRE.py
rm tempo1_readMADRE.py
rm tempo2_readMADRE.py
rm tempo3_readMADRE.py
rm tempo3
rm tempo4_readMADRE.py
rm tempo5_readMADRE.py


sed -e "s+RAWFILE+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/MADRE2.1_SD2MAT.py>tempo_SDMADRE.py
sed -e "s+RAWPATH+${PATHS[0]}+g" <tempo_SDMADRE.py>tempo1_SDMADRE.py
sed -e "s+EPSIFILE+${PATHS[1]}${RAW_DATA_FILENAME}+g" <tempo1_SDMADRE.py>tempo2_SDMADRE.py
sed -e "s+EPSIPATH+${PATHS[1]}+g" <tempo2_SDMADRE.py>tempo3_SDMADRE.py
sed -e "s+CTDFILE+${PATHS[2]}${RAW_DATA_FILENAME}+g" <tempo3_SDMADRE.py>tempo4_SDMADRE.py
sed -e "s+SCRIPTPATH+${ROOT}+g" <tempo4_SDMADRE.py>tempo5_SDMADRE.py
sed -e "s+SBECAL+${AUX1_CALFILE}+g" <tempo5_SDMADRE.py>tempo6_SDMADRE.py
sed -e "s+CTDPATH+${PATHS[2]}+g" <tempo6_SDMADRE.py>sd_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py
rm tempo_SDMADRE.py
rm tempo1_SDMADRE.py
rm tempo2_SDMADRE.py
rm tempo3_SDMADRE.py
rm tempo4_SDMADRE.py
rm tempo5_SDMADRE.py
rm tempo6_SDMADRE.py

sed -e "s+RAWFILE+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/plot_MADRE2.1_realtime.py>tempo_plotMADRE.py
sed -e "s+SCRIPTPATH+$ROOT+g" <tempo_plotMADRE.py>tempo1
sed -e "s+SBECAL+${AUX1_CALFILE}+g" <tempo1> tempo2
sed -e "s+RAWPATH+${PATHS[0]}+g" <tempo2>plot_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}_realtime.py
rm tempo_plotMADRE.py
rm tempo1
rm tempo2

sed -e "s+RAWFILE+${PATHS[0]}${RAW_DATA_FILENAME}+g" <lib/real_time_spectra_MADRE.py>tempo_plotMADRE.py
sed -e "s+SCRIPTPATH+${ROOT}+g" <tempo_plotMADRE.py>tempo1
sed -e "s+SBECAL+${AUX1_CALFILE}+g" <tempo1> tempo2
sed -e "s+RAWPATH+${PATHS[0]}+g" <tempo2>spectrum_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}_realtime.py
rm tempo_plotMADRE.py
rm tempo1
rm tempo2

sed -e "s+PATHLOG+${PATHS[5]}+g" <lib/log_deployment.py>log_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py

cp bash_mission.sh ${PATHS[4]}/bash_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.sh

mv log_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}.py ${PATHS[5]} 
mv *_${MISSION_NAME}_${VEHICLE_NAME}_${DEPLOYMENT_NAME}* ${PATHS[4]}

cd "${PATHS[0] }../"
