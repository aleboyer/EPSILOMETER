#!/usr/bin/env python
#TODO add timestamp flag and numchannel in the header from the board
#     so we can use it to set the reader up


import sys
sys.path.insert(0,'lib')

from IOlib import open_datafile 

from EPSIlib import EPSI_temp_univolt
from EPSIlib import EPSI_shear_univolt
from EPSIlib import EPSI_accel_unig

from SBElib import SBE_temp
from SBElib import SBE_cond
from SBElib import SBE_Pres
from SBElib import get_CalSBE

import numpy as np
import scipy.io as sio


class SBEsample_class:
    pass
class EPSIsample_class:
    pass

EPSIsample  = EPSIsample_class
SBEsample   = SBEsample_class

SBEcal=get_CalSBE('0058.cal')


def open_asciifile(filename='../data/MADRE2.1_SD.dat'):
    fid=open(filename,'wb+')
    return fid


fid,eof   = open_datafile('20170101_000000.dat')
#fid,eof   = open_datafile('3DAY_BENCH_SD/20170101_000000.dat')
#fid_ascii = open_asciifile()

Aux1WordLength = 0
ADCWordlength  = 3
number_of_sensor  = 7
EpsisampleWordLength= ADCWordlength*number_of_sensor
epsisample_per_block  = 160
EPSIWordlength = ADCWordlength *  number_of_sensor * epsisample_per_block



lines=fid.read()
blocks=lines.split(b'$MADRE')



EpsiStamp     = np.zeros(len(blocks)-2)
TimeStamp     = np.zeros(len(blocks)-2)
Voltage       = np.zeros(len(blocks)-2)
Checksum_aux1 = np.zeros(len(blocks)-2)
Checksum_aux2 = np.zeros(len(blocks)-2)
Checksum_map  = np.zeros(len(blocks)-2)

TimeStamp0=[int(block[9:17],16) for block in blocks[1:-1]]
EPSInbsample=np.zeros((len(blocks)-2)*160)
EPSItime=np.zeros((len(blocks)-2)*160)
t1=np.zeros((len(blocks)-2)*160)
t2=np.zeros((len(blocks)-2)*160)
s1=np.zeros((len(blocks)-2)*160)
s2=np.zeros((len(blocks)-2)*160)
a1=np.zeros((len(blocks)-2)*160)
a2=np.zeros((len(blocks)-2)*160)
a3=np.zeros((len(blocks)-2)*160)

if (len(blocks[1].split(b'$AUX1'))==2):
   Aux1Stamp=np.zeros((len(blocks)-2)*11)
   T=np.zeros((len(blocks)-2)*11)
   S=np.zeros((len(blocks)-2)*11)
   P=np.zeros((len(blocks)-2)*11)

test=[]

for i,block in enumerate(blocks[1:-1]):
    if len(block)==3724:
        header     = block[:53]
        aux1block  = block[60:60+297]
        epsiblock  = block[362:362+EPSIWordlength] 
    
        dev_block = header
    
        EpsiStamp[i]     = int(dev_block.split(b',')[0],16)
        #TimeStamp[i]     = int(dev_block.split(b',')[1],16)
        TimeStamp[i]     = int(dev_block.split(b',')[1],16)
        Voltage[i]       = int(dev_block.split(b',')[2],16)
        Checksum_aux1[i] = int(dev_block.split(b',')[3],16)
        Checksum_aux2[i] = int(dev_block.split(b',')[4],16)
        Checksum_map[i]  = int(dev_block.split(b',')[5],16)
    
        aux1block=aux1block.split(b'\r\n')[:-1]
        for k,sample in enumerate(aux1block):
            print(sample)
            
            if i==0:
                Aux1Stamp[i*(len(aux1block))+k]=int(sample.split(b',')[0],16)
                SBEsample.raw=sample.split(b',')[1]
                SBEsample =  SBE_temp(SBEcal,SBEsample)
                SBEsample =  SBE_Pres(SBEcal,SBEsample)
                SBEsample =  SBE_cond(SBEcal,SBEsample)
                
                T[i*(len(aux1block))+k]= SBEsample.temperature
                P[i*(len(aux1block))+k]= SBEsample.pressure
                S[i*(len(aux1block))+k]= SBEsample.conductivity
            else:
                if (int(sample.split(b',')[0],16)!=Aux1Stamp[(i-1)*(len(aux1block))+k]):
                    Aux1Stamp[i*(len(aux1block))+k]=int(sample.split(b',')[0],16)
                    SBEsample.raw=sample.split(b',')[1]
                    SBEsample =  SBE_temp(SBEcal,SBEsample)
                    SBEsample =  SBE_Pres(SBEcal,SBEsample)
                    SBEsample =  SBE_cond(SBEcal,SBEsample)
                    
                    T[i*(len(aux1block))+k]= SBEsample.temperature
                    P[i*(len(aux1block))+k]= SBEsample.pressure
                    S[i*(len(aux1block))+k]= SBEsample.conductivity
                    
        for k in range(epsisample_per_block):
            EPSInbsample[i*epsisample_per_block+k]=EpsiStamp[i]-epsisample_per_block-1+k;
            EPSItime[i*epsisample_per_block+k]=TimeStamp[i]-TimeStamp[0]-.5+k*0.5/epsisample_per_block;
            sample=epsiblock[k*EpsisampleWordLength:(k+1)*EpsisampleWordLength]
            [t1[i*epsisample_per_block+k],t2[i*epsisample_per_block+k]] \
                       = EPSI_temp_univolt(sample.hex());
            [s1[i*epsisample_per_block+k],s2[i*epsisample_per_block+k]] \
                       = EPSI_shear_univolt(sample.hex());
            a1[i*epsisample_per_block+k], \
            a2[i*epsisample_per_block+k], \
            a3[i*epsisample_per_block+k] \
                       = EPSI_accel_unig(sample.hex());
    
 
t1=t1[EPSInbsample>0];
t2=t2[EPSInbsample>0];
s1=s1[EPSInbsample>0];
s2=s2[EPSInbsample>0];
a1=a1[EPSInbsample>0];
a2=a2[EPSInbsample>0];
a3=a3[EPSInbsample>0];
EPSItime=EPSItime[EPSInbsample>0];
EPSInbsample=EPSInbsample[EPSInbsample>0];

EPSImat={'EPSItime':EPSItime, \
         'nbsample':EPSInbsample, \
         'Sensor1':t1,  \
         'Sensor2':t2,  \
         'Sensor3':s1,  \
         'Sensor4':s2,  \
         'Sensor5':[0], \
         'Sensor6':a1,  \
         'Sensor7':a2,  \
         'Sensor8':a3}
sio.savemat('Plumex18_matthewtest_epsi.mat',EPSImat)


T=T[Aux1Stamp>0];  
S=S[Aux1Stamp>0];  
P=P[Aux1Stamp>0];  
Aux1Stamp=Aux1Stamp[Aux1Stamp>0];  

SBEmat={'ctdtime':Aux1Stamp,\
        'T':T,\
        'C':S,\
        'P':P}
sio.savemat('Plumex18_matthewtest_ctd.mat',SBEmat)



