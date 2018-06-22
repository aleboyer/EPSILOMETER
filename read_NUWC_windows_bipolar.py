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
sys.path.insert(0,'/Users/MS/science/EPSILOMETER/lib')


from IOlib import open_datafile 

from EPSIlib import EPSI_channel_bivolt
from EPSIlib import EPSI_channel_big

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

SBEcal=get_CalSBE('/Users/MS/science/EPSILOMETER/SBE49/0133.cal')

if len(sys.argv)>=2:
   filename=sys.argv[1]
   fid,eof=open_datafile('/Users/MS/science/NISKINE_alb/NISKINE/epsifish1/d5/raw/'+filename)
   epsifile='/Users/MS/science/NISKINE_alb/NISKINE/epsifish1/d5/epsi/'+filename
   ctdfile= '/Users/MS/science/NISKINE_alb/NISKINE/epsifish1/d5/ctd/'+sys.argv[1]
else:
   filename='/Users/MS/science/NISKINE_alb/NISKINE/epsifish1/d5/raw/epsifish1_d5.dat' 
   fid,eof=open_datafile(filename)
   epsifile='/Users/MS/science/NISKINE_alb/NISKINE/epsifish1/d5/epsi/epsifish1_d5.dat'
   ctdfile='/Users/MS/science/NISKINE_alb/NISKINE/epsifish1/d5/ctd/epsifish1_d5.dat'
   

lines=fid.read()
blocks=lines.split(b'$MADRE')

EpsiStamp     = np.zeros(len(blocks)-2)
TimeStamp     = np.zeros(len(blocks)-2)
Voltage       = np.zeros(len(blocks)-2)
Checksum_aux1 = np.zeros(len(blocks)-2)
Checksum_aux2 = np.zeros(len(blocks)-2)
Checksum_map  = np.zeros(len(blocks)-2)

EPSItime=np.zeros((len(blocks)-2)*160)
t1=np.zeros((len(blocks)-2)*160)
t2=np.zeros((len(blocks)-2)*160)
c=np.zeros((len(blocks)-2)*160)
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
    try:
        Splitblock=block.split(b'$')
        print('Block %i over %i' % (i,len(blocks)))
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
                            t1[i*len(epsiblock)+k]=EPSI_channel_bivolt(sample,0)
                            t2[i*len(epsiblock)+k]=EPSI_channel_bivolt(sample,6)
                            s1[i*len(epsiblock)+k]=EPSI_channel_bivolt(sample,12)
                            s2[i*len(epsiblock)+k]=EPSI_channel_bivolt(sample,18)
                            c[i*len(epsiblock)+k]=EPSI_channel_count(sample,24)  # scie saw signal
                            a1[i*len(epsiblock)+k]=EPSI_channel_big(sample,30)
                            a2[i*len(epsiblock)+k]=EPSI_channel_big(sample,36)
                            a3[i*len(epsiblock)+k]=EPSI_channel_big(sample,42)
    except:
        test=np.nan*np.ones(160)
        test1=np.nan*len(aux1block)
        test2=np.nan
        EPSItime[i*len(epsiblock):i*len(epsiblock)]=test2
        TimeStamp[i*len(epsiblock):i*len(epsiblock)]=test2
        t1[i*len(epsiblock):i*len(epsiblock)+160]=test
        t2[i*len(epsiblock):i*len(epsiblock)+160]=test
        s1[i*len(epsiblock):i*len(epsiblock)+160]=test
        s2[i*len(epsiblock):i*len(epsiblock)+160]=test
        c[i*len(epsiblock):i*len(epsiblock)+160]=test
        a1[i*len(epsiblock):i*len(epsiblock)+160]=test
        a2[i*len(epsiblock):i*len(epsiblock)+160]=test
        a3[i*len(epsiblock):i*len(epsiblock)+160]=test
        T[i*len(aux1block):i*len(aux1block)+len(aux1block)]=test1
        C[i*len(aux1block):i*len(aux1block)+len(aux1block)]=test1
        P[i*len(aux1block):i*len(aux1block)+len(aux1block)]=test1
        Aux1Stamp[i*len(aux1block):i*len(aux1block)+len(aux1block)]=test1
        

print(' print in'+ epsifile[:-4] +'_EPSI.mat')
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
print(' print in'+ epsifile[:-4] +'_EPSI.npy')
np.save(epsifile[:-4] +'_EPSI.npy',(t1,t2,s1,s2,a1,a2,a3))


if (len(blocks[1].split(b'$AUX1'))==2):
    T=T[Aux1Stamp>0];  
    C=C[Aux1Stamp>0];  
    P=P[Aux1Stamp>0];  
    Aux1Stamp=Aux1Stamp[Aux1Stamp>0];  
    print(' print in '+ ctdfile[:-4] +'_SBE.mat')
    SBEmat={'time':Aux1Stamp,\
            'T':T,\
            'C':C,\
            'P':P}
    sio.savemat(ctdfile[:-4] +'_SBE.mat',SBEmat)
    print(' print in '+ ctdfile[:-4] +'_SBE.npy')
    np.save(ctdfile[:-4] +'_SBE.npy',(T,C,P,Aux1Stamp))




