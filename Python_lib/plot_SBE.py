#!/usr/bin/env python
import sys
sys.path.insert(0,'/Users/Shared/EPSILOMETER/EPSILOMETER/lib')


##  only look at shear and temp from madre
from IOlib import open_datafile 
from IOlib import seekend_datafile

from EPSIlib import EPSI_temp_count
from EPSIlib import EPSI_shear_count
from EPSIlib import EPSI_accel_count
from EPSIlib import EPSI_cond_count



from SBElib import SBE_temp
from SBElib import SBE_cond
from SBElib import SBE_Pres
from SBElib import get_CalSBE

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import style

import sys


# style of graphes
style.use('fivethirtyeight')

## local library for plotting

def init_figure():
    fig0 = plt.figure(0)
    return fig0

def init_axes_fig0(fig):
    ax0=plt.axes([.1,.7,.8,.2])
    ax1=plt.axes([.1,.4,.8,.2])
    ax2=plt.axes([.1,.1,.8,.2])
    # set up subplot 
    ax0.cla()
    ax1.cla()
    ax2.cla()
    lineP, = ax0.plot([],[], '.-', alpha=0.8, color="gray", markerfacecolor="red")
    lineT, = ax1.plot([],[], '.-', alpha=0.8, color="gray", markerfacecolor="green")
    lineC, = ax2.plot([],[], '.-', alpha=0.8, color="gray", markerfacecolor="cyan")
    ax2.set_xlabel('Second')
    ax0.set_ylabel('Pr')
    ax1.set_ylabel('T')
    ax2.set_ylabel('C')
    return lineP,lineT,lineC,ax0,ax1,ax2
 
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
    RTC1=int(Splitblock[0].split(b',')[0],16)
    RTC2=int(Splitblock1[0].split(b',')[0],16)    
    #freq=epsisample_per_block*32768/(RTC2-RTC1)
    freq=(RTC2-RTC1)/0.5;
    print(RTC2-RTC1)
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
    print("posi in plot buffer")
    print(ii)
    for j,dev_block in enumerate(Splitblock[1:]):
        if j==0:
            EpsiStamp[ii]     = int(dev_block[5:].split(b',')[0],16)
            TimeStamp[ii]     = int(dev_block[5:].split(b',')[1],16)
            Voltage[ii]       = int(dev_block[5:].split(b',')[2],16)
            Checksum_aux1[ii] = int(dev_block[5:].split(b',')[3],16)
            Checksum_aux2[ii] = int(dev_block[5:].split(b',')[4],16)
            #Checksum_map[ii]  = int(dev_block[5:].split(b',')[5],16)
        else:
            if dev_block[:4]==b'AUX1':
                aux1block=dev_block[6:].split(b'\r\n')[:-1]
                for k,sample in enumerate(aux1block):
                    indextime=int(sample.split(b',')[0],16)
                    if indextime>0:
                        Aux1Stamp[ii*(len(aux1block))+k]=int(sample.split(b',')[0],16)/freq
                        SBEsample.raw=sample.split(b',')[1]
                        try:
                           SBEsample =  SBE_temp(SBEcal,SBEsample)
                           SBEsample =  SBE_Pres(SBEcal,SBEsample)
                           SBEsample =  SBE_cond(SBEcal,SBEsample)
                           T[(ii*(len(aux1block))+k)]= SBEsample.temperature
                           P[(ii*(len(aux1block))+k)]= SBEsample.pressure
                           C[(ii*(len(aux1block))+k)]= SBEsample.conductivity
                        except:
                           T[(ii*(len(aux1block))+k)]= np.nan
                           P[(ii*(len(aux1block))+k)]= np.nan
                           C[(ii*(len(aux1block))+k)]= np.nan
                           Aux1Stamp[(ii*(len(aux1block))+k)]=np.nan
                            
                        
                        
                    else:
                        T[(ii*(len(aux1block))+k)]= np.nan
                        P[(ii*(len(aux1block))+k)]= np.nan
                        C[(ii*(len(aux1block))+k)]= np.nan
                        Aux1Stamp[(ii*(len(aux1block))+k)]=np.nan
                            


def animate(i):
    global index_store
    global index_plot
    global EPSI_time
    global eof_old
    global time_tempo
    global data_tempo
    global index_plotmax
    global T
    global C
    global P
    global Aux1Stamp
    
    
    posi=fid.tell()
    eof=fid.seek(0,2)
    fid.seek(posi)
    if (eof-eof_old)>0:
        if((eof-posi)>=blocklen):
            print(['update: %i' % index_store])
            if ((aux1len>0) & (index_store==LBuffer)):
               Aux1Stamp=np.zeros(Laux1Buffer)*np.nan
               T=np.zeros(Laux1Buffer)*np.nan
               C=np.zeros(Laux1Buffer)*np.nan
               P=np.zeros(Laux1Buffer)*np.nan

            update_sample(fid,index_store)
#            Indsort=Aux1Stamp.argsort()
#            T=T[Indsort];                                          
#            P=P[Indsort];                                          
#            C=C[Indsort];                                          
#            Aux1Stamp=Aux1Stamp[Indsort]
            
            print('C')
            print(C)
            print('P')
            print(P)
            print('T')
            print(T)
            
            index_store=(index_store+1)%LBuffer
            index_plot=np.arange(0,index_store*aux1sample_per_block)
            lineP.set_data(Aux1Stamp,P)
            lineT.set_data(Aux1Stamp,T)
            lineC.set_data(Aux1Stamp,C)


            fig0.axes[1].set_xlim([np.min(Aux1Stamp),np.min(Aux1Stamp)+.5*LBuffer])   
            fig0.axes[1].set_ylim([5.50,10.0]) 
            
            fig0.axes[0].set_xlim([np.min(Aux1Stamp),np.min(Aux1Stamp)+.5*LBuffer])   
            fig0.axes[0].set_ylim([0,700]) 
            fig0.axes[0].legend(['Pr=%3.3f' % np.nanmean(P[:-5])],loc=2)

            fig0.axes[2].set_xlim([np.min(Aux1Stamp),np.min(Aux1Stamp)+.5*LBuffer])   
            fig0.axes[2].set_ylim([0,5]) 
#            fig0.axes[0].legend(['rms=%3.3f' % np.sqrt(np.mean(P**2))],loc=2)  
            
#            fig0.axes[1].set_xlim([Aux1Stamp[index_plot[0]],Aux1Stamp[index_plot[0]]+.5*LBuffer])   
#            fig0.axes[1].set_ylim([ax0xmin,ax0xmax]) 
#            fig0.axes[1].legend(['rms=%3.3f' % np.sqrt(np.mean(T**2))],loc=2)  

#           fig0.axes[2].set_xlim([Aux1Stamp[index_plot[0]],Aux1Stamp[index_plot[0]]+.5*LBuffer])   
#            fig0.axes[2].set_ylim([ax0xmin,ax0xmax]) 
#           fig0.axes[2].legend(['rms=%3.3f' % np.sqrt(np.mean(C**2))],loc=2)  
            
#    return lineP,lineT,lineC,
    return lineT,lineP,lineC,



#####################################################################



# define classe SBE sample and epsi sample
# define classe SBE sample and epsi sample
class SBEsample_class:
    pass
class EPSIsample_class:
    pass


Aux1WordLength       = 0
ADCWordlength        = 3
number_of_sensor     = 5
epsisample_per_block = 160 # ???? 
aux1sample_per_block = 9

EpsisampleWordLength= ADCWordlength*number_of_sensor
EPSIWordlength = ADCWordlength *  number_of_sensor * epsisample_per_block

SBEcal      = get_CalSBE('/Users/Shared/EPSILOMETER/EPSILOMETER/SBE49/0133.cal')


if len(sys.argv)>=2:
   filename=sys.argv[1]
   fid,eof=open_datafile('/Users/Shared/EPSILOMETER/NISKINE/epsifish1/d5/raw/'+filename)
else:
   filename='/Users/Shared/EPSILOMETER/NISKINE/epsifish1/d5/raw/epsifish1_d5.dat' 
   fid,eof=open_datafile(filename)
   
fid,eof=seekend_datafile(fid,eof)
blocklen,headerlen,aux1len,aux2len,epsilen,freq= \
                                define_block(fid,eof)


LBuffer= 10 # number of blocks stored
Lplot  = 1 # number of blocks plotted

index_plot  = 0
index_store = 0
update=True


LepsiBuffer= LBuffer*epsisample_per_block
Lepsiplot  = Lplot*epsisample_per_block

Laux1Buffer = LBuffer*aux1sample_per_block
Laux1plot   = Lplot*aux1sample_per_block

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
eof_old = 0

t1=np.zeros(LepsiBuffer)*np.nan
t2=np.zeros(LepsiBuffer)*np.nan
s1=np.zeros(LepsiBuffer)*np.nan
s2=np.zeros(LepsiBuffer)*np.nan
c =np.zeros(LepsiBuffer)*np.nan
a1=np.zeros(LepsiBuffer)*np.nan
a2=np.zeros(LepsiBuffer)*np.nan
a3=np.zeros(LepsiBuffer)*np.nan

if aux1len>0:
   Aux1Stamp=np.zeros(Laux1Buffer)*np.nan
   T=np.zeros(Laux1Buffer)*np.nan
   C=np.zeros(Laux1Buffer)*np.nan
   P=np.zeros(Laux1Buffer)*np.nan






#    fig0,fig1=init_figure(2)    
fig0=init_figure() # just the for dev    
lineP,lineT,lineC,ax0,ax1,ax2=init_axes_fig0(fig0)
    
    
ani = animation.FuncAnimation(fig0, animate,interval=10)
plt.show()

