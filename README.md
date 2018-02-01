# EPSILOMETER

Pre-requisit:
download anaconda3 for python
in a terminal "conda install pyserial"

0/ create a MISSION environment: in bash_mission, the user should define the environment variable names like: 
-MISSION name
-Vehicle name
-deployment name (a deployment is thought to be the time between start and stop recording). 
- RAWPATH: a path where the data are stored

1/ Connect MADRE and your laptop with an FTDI serial device. 
The python reader will an issue if you have more than one FTDI device.
It is possible to set the name of the device in read_MADRE2.1.py. 
TODO: give the user a choice if more than 1 device is available

2/ in a terminal, go where the library is

3/ if MADRE is running do python store_DEV_benchSPROUL_d3.py

4/ you can convert the data in RAW path directly by typing python read_DEV_benchSPROUL_d3.py
epsi data and CTD data will store in both matlab and python format in the epsi and ctd folders (above RAWPATH) 

5/ if you are acquiring the data you can visulaize them in real time with python plot_DEV_benchSPROUL_d3_realtime.py

