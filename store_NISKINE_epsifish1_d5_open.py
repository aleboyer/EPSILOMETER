#!/usr/bin/env python


## DO NOT TOUCH THAT FILE
## DO NOT TOUCH THAT FILE
## DO NOT TOUCH THAT FILE
## DO NOT TOUCH THAT FILE
## DO NOT TOUCH THAT FILE

# the bash script bash_mission.sh will transform this script to create a 
#new script that will match the environment define in bash_mission  


import serial
import time
import sys
import glob

serport=glob.glob('/dev/tty.usbserial-*')

ser = serial.Serial('/dev/tty.usbserial-A503PZXL',115200)  # open serial port
print(ser.name)         # check which port was really used

## DO NOT TOUCH 
def open_datafile_write(filename='/Users/Shared/EPSILOMETER//NISKINE/epsifish1/d5/raw/epsifish1_d5.dat'):
    fid=open(filename,'wb+')
    return fid 



start_time = time.time()

State=0
compt=0
rollover=0
ser.flushInput()

if len(sys.argv)==2:
   filename=sys.argv[1]
   fid=open_datafile_write('/Users/Shared/EPSILOMETER//NISKINE/epsifish1/d5/raw/' +filename)
else:
    fid=open_datafile_write()

while True:
          time.sleep(.001)
          line=ser.readline()
          fid.write(line)
          fid.flush()
          if(line[:6]==b'$MADRE'):
          	print(line) 
          if(line[:5]==b'$AUX1'):
          	print(line) 

    
