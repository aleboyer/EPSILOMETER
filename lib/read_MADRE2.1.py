#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 05:18:27 2018

@author: aleboyer
"""


#!/usr/bin/env python

##  only look at shear and temp from madre

# define classe SBE sample and epsi sample
# define classe SBE sample and epsi sample

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

SBEcal=get_CalSBE()

if len(sys.argv)>=2:
   filename=sys.argv[1]
   fid,eof=open_datafile('RAWPATH'+filename)
   epsifile='EPSIPATH'+filename
else:
   filename='RAWFILE' 
   fid,eof=open_datafile(filename)
   epsifile='EPSIFILE'
   
if len(sys.argv)==3:
    ctdfile= 'CTDPATH'+sys.argv[2]
else:
    ctdfile='CTDFILE'
   

lines=fid.read()
blocks=lines.split(b'$MADRE')

EpsiStamp     = np.zeros(len(blocks)-2)
TimeStamp     = np.zeros(len(blocks)-2)
Voltage       = np.zeros(len(blocks)-2)
Checksum_aux1 = np.zeros(len(blocks)-2)
Checksum_aux2 = np.zeros(len(blocks)-2)
Checksum_map  = np.zeros(len(blocks)-2)

t1=np.zeros((len(blocks)-2)*160)
t2=np.zeros((len(blocks)-2)*160)
s1=np.zeros((len(blocks)-2)*160)
s2=np.zeros((len(blocks)-2)*160)
a1=np.zeros((len(blocks)-2)*160)
a2=np.zeros((len(blocks)-2)*160)
a3=np.zeros((len(blocks)-2)*160)

if (len(blocks[1].split(b'$'))==3):
   Aux1Stamp=np.zeros((len(blocks)-2)*11)
   T=np.zeros((len(blocks)-2)*11)
   C=np.zeros((len(blocks)-2)*11)
   P=np.zeros((len(blocks)-2)*11)



for i,block in enumerate(blocks[1:-1]):
    Splitblock=block.split(b'$')
    for j,dev_block in enumerate(Splitblock):
        if j==0:
            EpsiStamp[i]     = int(dev_block.split(b',')[0],16)
            TimeStamp[i]     = int(dev_block.split(b',')[1],16)
            Voltage[i]       = int(dev_block.split(b',')[2],16)
            Checksum_aux1[i] = int(dev_block.split(b',')[3],16)
            Checksum_aux2[i] = int(dev_block.split(b',')[4],16)
            Checksum_map[i]  = int(dev_block.split(b',')[5],16)
        else:
            if dev_block[:4]==b'AUX1':
                aux1block=dev_block[6:].split(b'\r\n')[:-1]
                for k,sample in enumerate(aux1block):
                    print(sample)
                    indextime=int(sample.split(b',')[0],16)
                    if indextime>0:
                        Aux1Stamp[i*(len(aux1block))+k]=int(sample.split(b',')[0],16)
                        SBEsample.raw=sample.split(b',')[1]
                        SBEsample =  SBE_temp(SBEcal,SBEsample)
                        SBEsample =  SBE_Pres(SBEcal,SBEsample)
                        SBEsample =  SBE_cond(SBEcal,SBEsample)
                    
                        T[i*(len(aux1block))+k]= SBEsample.temperature
                        P[i*(len(aux1block))+k]= SBEsample.pressure
                        C[i*(len(aux1block))+k]= SBEsample.conductivity
                        
                
                
            if dev_block[:4]==b'EPSI':
                epsiblock=dev_block[6:].split(b'\r\n')[:-1]
                for k,sample in enumerate(epsiblock):
                        [t1[i*len(epsiblock)+k],t2[i*len(epsiblock)+k]] \
                               = EPSI_temp_univolt(sample);
                        [s1[i*len(epsiblock)+k],s2[i*len(epsiblock)+k]] \
                               = EPSI_shear_univolt(sample);
                        a1[i*len(epsiblock)+k], \
                        a2[i*len(epsiblock)+k], \
                        a3[i*len(epsiblock)+k] \
                               = EPSI_accel_unig(sample);

if (len(blocks[1].split(b'$'))==3):
    T=T[T>0]
    C=C[C>0]
    P=P[P>0]
    Aux1Stamp=Aux1Stamp[Aux1Stamp>0]





print(' print in'+ filename[:-4] +'_EPSI.mat')
EPSImat={'EPSItime':EpsiStamp, \
         'time':TimeStamp, \
         'Sensor1':t1,  \
         'Sensor2':t2,  \
         'Sensor3':s1,  \
         'Sensor4':s2,  \
         'Sensor5':[0], \
         'Sensor6':a1,  \
         'Sensor7':a2,  \
         'Sensor8':a3}
sio.savemat(epsifile[:-4] +'_EPSI.mat',EPSImat)
np.save(epsifile[:-4] +'_EPSI.npy',(t1,t2,s1,s2,a1,a2,a3))



if (len(blocks[1].split(b'$'))==3):
    print(' print in '+ filename[:-4] +'_SBE.mat')
    SBEmat={'time':Aux1Stamp,\
            'T':T,\
            'C':C,\
            'P':P}
    sio.savemat(ctdfile[:-4] +'_SBE.mat',SBEmat)
    np.save(ctdfile[:-4] +'_SBE.npy',(T,C,P,Aux1Stamp))



