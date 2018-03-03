#!/usr/bin/env python

import serial
import time
import glob

serport=glob.glob('/dev/tty.usbserial-*')

ser = serial.Serial(serport[0],460800)  # open serial port
print(ser.name)         # check which port was really used
time.sleep(.1)

############################


# send the first 2 bytes to stop sampling and enter in the menu mode 
s=ser.write(b'\x1e\x1e')
time.sleep(.1)
# clean the input buffer. Somehow ser.flushinput() does not work. 
# I have to loop and read the buffer for about 18 times with a little pause between
# each read to really clean up the buffer. It seems like there 18 buffer and when these buffers are full
# you do not store any new bytes.

# To be able to do that safely I had to stop the process on the board with a USART_RxDouble() just before
# sending the actual text to the user.   
compt1=0
while ser.inWaiting()>0:
      ser.read_all()
      compt1+=1
      time.sleep(.1)

s=ser.write(b'\x1e\x1e')
time.sleep(.1)
# one more read all to be sure we emptied everything
readByte=ser.read_all()
print(readByte.decode('ascii'))
answer1 = input('Enter answer1: ')
s=ser.write(answer1.encode())

# we should be in MADRE_Change_Config by now.
# we should be asked to chose between the different parameter we want to change
time.sleep(.1)
readByte=ser.read_all()
print(readByte.decode('ascii'))


#enter in the 2 level of the menu Sensor SBE Whatever
answer2 = input('Enter answer2: ')
s=ser.write(answer2.encode())
time.sleep(.1)
readByte=ser.read_all()
print(readByte.decode('ascii'))



#enter in the 3 level of the menu the real change in parameters
answer3 = input('Enter answer3: ')
if len(answer3)==1:
    s=ser.write(bytes([int(answer3)]))
    s=ser.write(b'\x00')
    
    
time.sleep(.1)
readByte=ser.readline()
print(readByte.decode('ascii'))




test=int(time.time())+1
btest=test.to_bytes(4,byteorder='big')
s=ser.write(btest[1::-1])
s=ser.write(btest[3:1:-1])

time.sleep(.001)
readByte=ser.readline()
print(readByte.decode('ascii'))


##################
#need to check whether it succeed?, close return 0 is succeed
ser.close()             # close port
