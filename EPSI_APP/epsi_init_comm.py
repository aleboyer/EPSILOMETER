#!/usr/bin/env python

import serial
import time
#ser = serial.Serial('/dev/tty.usbserial-FTYVXOI5',460800)  # open serial port
#ser = serial.Serial('/dev/tty.usbserial-FTXOY2MY',460800)  # open serial port
ser = serial.Serial('/dev/tty.usbserial-FTYVXOH6',460800)  # open serial port
print(ser.name)         # check which port was really used
time.sleep(.1)

compt1=0
while ser.inWaiting()>0:
      ser.read_all()
      compt1+=1
      time.sleep(.1)

time.sleep(.1)

test=int(time.time())+1
btest=test.to_bytes(4,byteorder='big')
s=ser.write(btest[1::-1])
s=ser.write(btest[3:1:-1])
time.sleep(.001)

print('done')
ser.close()             # close port
