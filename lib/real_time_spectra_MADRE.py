#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  2 19:24:01 2018

@author: aleboyer
"""

#!/usr/bin/env python
import sys
sys.path.insert(0,'lib')


##  only look at shear and temp from madre
from IOlib import open_datafile 
from IOlib import seekend_datafile

from EPSIlib import Count2Volt_unipol, EPSI_temp_count
from EPSIlib import EPSI_shear_count, EPSI_accel_count

from SBElib import SBE_temp,SBE_cond,SBE_Pres,get_CalSBE

from make_spectra import makefft,bitnoise



import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.widgets import RadioButtons,Slider
from matplotlib import style

import sys


# style of graphes
style.use('fivethirtyeight')

## local library for plotting

def init_figure(numfig):
    if numfig==1:
        fig0 = plt.figure(0)
        fig1 = []
    if numfig==2:
        fig0 = plt.figure(0)
        fig1 = plt.figure(1)
    return fig0,fig1

def init_axes_fig0(fig):
    ax0=plt.axes([.3,.4,.5,.5])
    ax1=plt.axes([.1,.1,.15,.2])
    ax2=plt.axes([.3,.01,.5,.05])
    ax3=plt.axes([.3,.1,.5,.05])
    ax4=plt.axes([.1,.4,.15,.5])
    # set up subplot 
    ax0.cla()
    lineF0, = ax0.loglog([],[], '.-', alpha=0.8, color="gray", markerfacecolor="red")
    lineV1, = ax0.loglog([],[], '.-', alpha=0.8, color="gray", markerfacecolor="green")
    lineV2, = ax0.loglog([],[], '.-', alpha=0.8, color="gray", markerfacecolor="cyan")
    radio = RadioButtons(ax1, ('Hanning', 'other (notthereyet)')) 
    radio1 = RadioButtons(ax4, ('t1', 't2','s1','s2','a1','a2','a3'))
    Sl_ymin = Slider(ax2, 'Ymin', -20, 0, valinit=-5)
    Sl_ymax = Slider(ax3, 'Ymax', -20, 0, valinit=1)
    ax0.set_xlabel('Hz')
    ax0.set_ylabel('Volts^2/Hz')
    return lineF0,lineV1,lineV2,radio,radio1,Sl_ymin,Sl_ymax,ax0


def init_axes_fig1(fig):
    ax0=plt.axes([.3,.4,.5,.5])
    ax1=plt.axes([.1,.1,.15,.2])
    ax2=plt.axes([.3,.01,.5,.05])
    ax3=plt.axes([.3,.1,.5,.05])
    ax4=plt.axes([.1,.4,.15,.5])
    # set up subplot 
    ax0.cla()
    lineF0, = ax0.loglog([],[], '.-', alpha=0.8, color="gray", markerfacecolor="red")
    lineV1, = ax0.loglog([],[], '.-', alpha=0.8, color="gray", markerfacecolor="green")
    lineV2, = ax0.loglog([],[], '.-', alpha=0.8, color="gray", markerfacecolor="cyan")
    radio = RadioButtons(ax1, ('Hanning', 'Other (not there yet)')) 
    radio1 = RadioButtons(ax4, ('t1', 't2','s1','s2','a1','a2','a3'))
    Sl_ymin = Slider(ax2, 'Ymin', -20, 0, valinit=-5)
    Sl_ymax = Slider(ax3, 'Ymax', -20, 0, valinit=1)
    ax0.set_xlabel('Hz')
    ax0.set_ylabel('Volts^2/Hz')
    return lineF0,lineV1,lineV2,radio,radio1,Sl_ymin,Sl_ymax,ax0

def define_block(fid,eof):
    allblocks = fid.read(eof-fid.tell()) # all block should around the size of 3 MADRE block
    blocks    = allblocks.split(b'$MADRE')
    block     = blocks[1]
    block1     = blocks[2]
    blocklen  = len(block)+6
    
    aux1len=0
    aux2len=0
    epsilen=0
    
    Splitblock = block.split(b'$')
    Splitblock1 = block1.split(b'$')
    headerlen  = len(Splitblock[0])
#    RTC1=int(Splitblock[0].split(b',')[1],16)
#    RTC2=int(Splitblock1[0].split(b',')[1],16)
#    freq=epsisample_per_block*32768/(RTC2-RTC1)
    freq=325
    
    if Splitblock[1][:4]==b'AUX1':
        aux1len = len(Splitblock[1])
    else:
        epsilen = len(Splitblock[1])
    print(len(Splitblock))
    if len(Splitblock)>2:
        if Splitblock[2][:4]==b'AUX2':
            aux2len = len(Splitblock[2])
        else:
            epsilen = len(Splitblock[2])
    
    fid.seek(fid.tell()-len(allblocks.split(b'$MADRE')[-1])-6)    
    return blocklen,headerlen,aux1len,aux2len,epsilen,freq
    


  
def update_sample(fid,ii):
    SBEsample   = SBEsample_class
    block=fid.read(blocklen)   
    Splitblock=block.split(b'$')
    print('coucou ii')
    print(ii)
    for j,dev_block in enumerate(Splitblock[1:]):
        if j==0:
            EpsiStamp[ii]     = int(dev_block[5:].split(b',')[0],16)
            TimeStamp[ii]     = int(dev_block[5:].split(b',')[1],16)
            Voltage[ii]       = int(dev_block[5:].split(b',')[2],16)
            Checksum_aux1[ii] = int(dev_block[5:].split(b',')[3],16)
            Checksum_aux2[ii] = int(dev_block[5:].split(b',')[4],16)
            Checksum_map[ii]  = int(dev_block[5:].split(b',')[5],16)
        else:
            if dev_block[:4]==b'AUX1':
                aux1block=dev_block[6:].split(b'\r\n')[:-1]
                for k,sample in enumerate(aux1block):
                    indextime=int(sample.split(b',')[0],16)
                    if indextime>0:
                        Aux1Stamp[ii,k]=int(sample.split(b',')[0],16)*freq
                        SBEsample.raw=sample.split(b',')[1]
                        SBEsample =  SBE_temp(SBEcal,SBEsample)
                        SBEsample =  SBE_Pres(SBEcal,SBEsample)
                        SBEsample =  SBE_cond(SBEcal,SBEsample)
                        T[ii,k]= SBEsample.temperature
                        P[ii,k]= SBEsample.pressure
                        C[ii,k]= SBEsample.conductivity
                    else:
                        T[ii,k]= np.nan
                        P[ii,k]= np.nan
                        C[ii,k]= np.nan
                        Aux1Stamp[ii,k]=np.nan
                            
            if dev_block[:4]==b'EPSI':
                epsiblock=dev_block[6:].split(b'\r\n')[:-1]
                for k,sample in enumerate(epsiblock):
                    t1[ii,k],t2[ii,k]= EPSI_temp_count(sample);
                    s1[ii,k],s2[ii,k]= EPSI_shear_count(sample);
                    a1[ii,k],a2[ii,k],a3[ii,k] = EPSI_accel_count(sample);
                                               


def animate(i,radio,radio1,Sl_ymin,Sl_ymax):
    global index_store
    global index_plot
    global update
    global time_tempo
    global data_tempo
    
    if(radio1.value_selected=='t1'):
       data=t1
    if(radio1.value_selected=='t2'):
       data=t2
    if(radio1.value_selected=='s1'):
       data=s1
    if(radio1.value_selected=='s2'):
       data=s2
    if(radio1.value_selected=='a1'):
       data=a1
    if(radio1.value_selected=='a2'):
       data=a2
    if(radio1.value_selected=='a3'):
       data=a3

    ax0xmax=0xffffff
    ax0xmin=0
    data=Count2Volt_unipol(data)
    
    ax0xmin=10**Sl_ymin.val
    ax0xmax=10**Sl_ymax.val
    ax0.set_ylabel('Volts^2/Hz')
    
    posi=fid.tell()
    eof=fid.seek(0,2)
    fid.seek(posi)
    if((eof-posi)>blocklen):
        print(['update: %i' % index_store])
        update_sample(fid,index_store)
        index_store=(index_store+1)%LBuffer
        update=True
    
    if update==False:
                
        [k,spec]=makefft(data.T,325.0)
        lineF0.set_data( k,spec.mean(axis=1))
        lineV1.set_data(k,k*0+bitnoise(325,FR=2.5,Nb_bi=20))
        lineV2.set_data(k,k*0+bitnoise(325,FR=2.5,Nb_bi=16))

                    
        fig0.axes[0].set_xlim([k[1],k[-1]])   
        fig0.axes[0].set_ylim([ax0xmin,ax0xmax]) 
        fig0.axes[0].legend(['rms=%3.3f' % np.sqrt(np.mean(data**2))],loc=2)  
        
    if update:
       update=False
    
    return lineF0,lineV1,lineV2,



#####################################################################

#eof=fid.seek(0,2)
#fid.seek(0)


# define classe SBE sample and epsi sample
# define classe SBE sample and epsi sample
class SBEsample_class:
    pass
class EPSIsample_class:
    pass


Aux1WordLength       = 0
ADCWordlength        = 3
number_of_sensor     = 7
epsisample_per_block = 160 # ???? 
aux1sample_per_block = 9

EpsisampleWordLength= ADCWordlength*number_of_sensor
EPSIWordlength = ADCWordlength *  number_of_sensor * epsisample_per_block

SBEcal      = get_CalSBE()


if len(sys.argv)>=2:
   filename=sys.argv[1]
   fid,eof=open_datafile('RAWPATH'+filename)
else:
   filename='RAWFILE' 
   fid,eof=open_datafile(filename)
   
fid,eof=seekend_datafile(fid,eof)
blocklen,headerlen,aux1len,aux2len,epsilen,freq= \
                                define_block(fid,eof)


LBuffer= 5 # number of blocks stored
Lplot  = 1 # number of blocks plotted

index_plot  = 0
index_store = 0
update=True


LepsiBuffer= LBuffer*epsisample_per_block
Lepsiplot  = Lplot*epsisample_per_block

Laux1Buffer=LBuffer*aux1sample_per_block

#initialze the buffers
EpsiStamp     = np.zeros(LBuffer)*np.nan
TimeStamp     = np.zeros(LBuffer)*np.nan
Voltage       = np.zeros(LBuffer)*np.nan
Checksum_aux1 = np.zeros(LBuffer)*np.nan
Checksum_aux2 = np.zeros(LBuffer)*np.nan
Checksum_map  = np.zeros(LBuffer)*np.nan

EPSI_time=np.zeros(LepsiBuffer)*np.nan

# for circular buffer edges issues while plotting
data_tempo=np.zeros(Lepsiplot)*np.nan
time_tempo=np.zeros(Lepsiplot)*np.nan


t1=np.zeros([LBuffer,epsisample_per_block])*np.nan
t2=np.zeros([LBuffer,epsisample_per_block])*np.nan
s1=np.zeros([LBuffer,epsisample_per_block])*np.nan
s2=np.zeros([LBuffer,epsisample_per_block])*np.nan
a1=np.zeros([LBuffer,epsisample_per_block])*np.nan
a2=np.zeros([LBuffer,epsisample_per_block])*np.nan
a3=np.zeros([LBuffer,epsisample_per_block])*np.nan

if aux1len>0:
   Aux1Stamp=np.zeros([LBuffer,aux1sample_per_block])
   T=np.zeros([LBuffer,aux1sample_per_block])*np.nan
   C=np.zeros([LBuffer,aux1sample_per_block])*np.nan
   P=np.zeros([LBuffer,aux1sample_per_block])*np.nan






if aux1len>0:
#    fig0,fig1=init_figure(2)    
    fig0,fig1=init_figure(1) # just the for dev    
    lineF0,lineV1,lineV2,radio,radio1,Sl_ymin,Sl_ymax,ax0= \
                                            init_axes_fig0(fig0)
else:
    fig0,fig1=init_figure(1)    
    lineF0,lineV1,lineV2,radio,radio1,Sl_ymin,Sl_ymax,ax0= \
                                            init_axes_fig0(fig0)
    
    
ani = animation.FuncAnimation(fig0, animate,fargs=(radio,radio1,Sl_ymin,Sl_ymax),interval=10)
plt.show()
   
