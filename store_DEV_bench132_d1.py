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

ser = serial.Serial(serport[0],460800)  # open serial port
print(ser.name)         # check which port was really used

## DO NOT TOUCH 
def open_datafile_write(filename='/Volumes/KINGSTON//DEV/bench132/d1/raw/bench132_d1.dat'):
    fid=open(filename,'wb+')
    return fid 



start_time = time.time()

State=0
compt=0
rollover=0
ser.flushInput()

if len(sys.argv)==2:
   filename=sys.argv[1]
   fid=open_datafile_write('/Volumes/KINGSTON//DEV/bench132/d1/raw/' +filename)
else:
    fid=open_datafile_write()

Aux1WordLength = 0
#ADCWordlength  = 6
ADCWordlength  = 3
number_of_sensor  = 7
EpsisampleWordLength= ADCWordlength*number_of_sensor
epsisample_per_block  = 160 

EPSIWordlength = ADCWordlength *  number_of_sensor * epsisample_per_block

State=0
count=0

while True:
    if (State==0):
#      while(ser.in_waiting>0):
#          ser.readline()
#          print('wait')
          
          time.sleep(.00001)
          line=ser.readline()
          print(line)
          if line[:6]==b'$MADRE':
             #State=1
             len_header    = len(line)
             EpsiStamp     = int(line[6:6+8],16)
             TimeStamp     = int(line[15:15+8],16)
             Voltage       = int(line[24:24+8],16)
             Checksum_aux1 = int(line[33:33+8],16)
             Checksum_aux2 = int(line[42:42+8],16)
             Checksum_map  = int(line[51:51+8],16)
                      
             newHeader=ser.read(5)
             if newHeader==b'$AUX1':
                 print(b'AUXheader='+newHeader)
                 #auxblock=ser.read(363)
                 auxblock=ser.read(330-33)
                 print(auxblock.decode("utf-8"))
                 newHeader=ser.read(5)
                 print(newHeader)
                 
             if newHeader==b'$EPSI':
                 block=ser.read(EPSIWordlength)
                 endblock=ser.read(2)
                 if endblock==b'\r\n':
                     count+=1
                     if count==5:
                         State=1
                         print('Lock up')
                         print('Start recording')
                     else:
                         print(5-count)    
    
    if (State==1):

            line=ser.readline()
            print(line) 
            if (line[:6]==b'$MADRE')==False:
               State=0
               count=0
            else:
               fid.write(line)
               fid.flush() 
               newHeader=ser.read(5)
               print(newHeader)        
               if newHeader==b'$AUX1':
                   fid.write(newHeader +b'\r\n')
                   #aux1block=ser.read(363)
                   aux1block=ser.read(330-33)
                   fid.write(aux1block)
                   newHeader=ser.read(5)
                   print(aux1block.decode("utf-8"))
               if Checksum_aux2>0:
                   print(b'AUXheader='+newHeader)
                   newHeader=ser.read(5)
               print(newHeader)        
               block=ser.read(EPSIWordlength) # 
               epsisamples=[ block[i*EpsisampleWordLength:(i+1)*EpsisampleWordLength] \
                             for i in range(epsisample_per_block) ]
               endblock=ser.read(2) # 2 is for /r/n
        #       fid.write(line)
               fid.write(newHeader +b'\r\n')
               if(ADCWordlength==3):
               #   print(str.encode(epsisamples[0].hex() + '\r\n')) 
                  [fid.write(str.encode(samples.hex() + '\r\n')) for samples in epsisamples]
               else:
                  [fid.write(samples + b'\r\n') for samples in epsisamples]
               print(ser.in_waiting)   
               fid.flush() 

    
