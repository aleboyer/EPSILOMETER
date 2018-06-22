#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan 14 10:01:27 2018

@author: aleboyer
"""
import numpy as np

def EPSI_temp_count(sample):
    T1  = int(sample[:6],16)
    T2  = int(sample[6:12],16)
    return T1,T2
def EPSI_shear_count(sample):
    S1  = int(sample[12:18],16)
    S2  = int(sample[18:24],16)
    return S1,S2 
def EPSI_cond_count(sample):
    C  = int(sample[24:30],16)
    return C 
def EPSI_accel_count(sample):
#    A1  = int(sample[30:36],16)
#    A2  = int(sample[36:42],16)
#    A3  = int(sample[42:48],16)
    A1  = int(sample[30:36],16)
    A2  = int(sample[36:42],16)
    A3  = int(sample[42:48],16)
    return A1,A2,A3 
def EPSI_channel_count(sample,posi):
    Cha  = int(sample[posi:posi+6],16)
    return Cha

def Count2Volt_unipol(count,N=24,Full_Range=2.5,Gain=1):
    Vin=Full_Range*np.array(count)/2**N/Gain;
    return Vin;
def Volt2Count_unipol(Vin,N=24,Full_Range=2.5,Gain=1):
    counts=(2**N * Vin * Gain) / Full_Range;
    return counts;

def Count2Volt_bipol(count,N=24,Full_Range=2.5,Gain=1):
    Vin=Full_Range/Gain*(np.array(count)/2**(N-1)-1);
    return Vin;
def Volt2count_bipol(Vin,N=24,Full_Range=2.5,Gain=1):
    counts=2**N * ( (Vin * Gain) / Full_Range +1 );
    return counts;

def Volt2g(V,offset=1.65):
    g_in=(np.array(V)-offset)/.66;
    return g_in

def EPSI_temp_univolt(sample):
    T1  = Count2Volt_unipol(int(sample[:6],16))
    T2  = Count2Volt_unipol(int(sample[6:12],16))
    return T1,T2

def EPSI_shear_univolt(sample):
    S1  = Count2Volt_unipol(int(sample[12:18],16))
    S2  = Count2Volt_unipol(int(sample[18:24],16))
    return S1,S2 


def EPSI_cond_univolt(sample):
    C  = Count2Volt_unipol(int(sample[24:30],16))
    return C 
def EPSI_accel_univolt(sample):
    A1  = Count2Volt_unipol(int(sample[30:36],16))
    A2  = Count2Volt_unipol(int(sample[36:42],16))
    A3  = Count2Volt_unipol(int(sample[42:48],16))
    return A1,A2,A3 
def EPSI_channel_univolt(sample,posi):
    Cha  = Count2Volt_unipol(int(sample[posi:posi+6],16))
    return Cha



def EPSI_temp_bivolt(sample,gain):
    T1  = Count2Volt_bipol(int(sample[:6],16))
    T2  = Count2Volt_bipol(int(sample[6:12],16),Gain=gain)
    return T1,T2
def EPSI_shear_bivolt(sample):
    S1  = Count2Volt_bipol(int(sample[12:18],16))
    S2  = Count2Volt_bipol(int(sample[18:24],16))
    return S1,S2 
def EPSI_cond_bivolt(sample):
    C  = Count2Volt_bipol(int(sample[24:30],16))
    return C 
def EPSI_accel_bivolt(sample):
    A1  = Count2Volt_bipol(int(sample[30:36],16))
    A2  = Count2Volt_bipol(int(sample[36:42],16))
    A3  = Count2Volt_bipol(int(sample[42:48],16))
    return A1,A2,A3 
#def EPSI_accel_unig(sample):
#    A1  = Volt2g(Count2Volt_unipol(int(sample[30:36],16)))
#    A2  = Volt2g(Count2Volt_unipol(int(sample[36:42],16)))
#    A3  = Volt2g(Count2Volt_unipol(int(sample[42:48],16)))
#    return A1,A2,A3 
def EPSI_accel_unig(sample):
    A1  = Volt2g(Count2Volt_unipol(int(sample[24:30],16)))
    A2  = Volt2g(Count2Volt_unipol(int(sample[30:36],16)))
    A3  = Volt2g(Count2Volt_unipol(int(sample[36:42],16)))
    return A1,A2,A3 
def EPSI_accel_big(sample):
    A1  = Volt2g(Count2Volt_bipol(int(sample[30:36],16)))
    A2  = Volt2g(Count2Volt_bipol(int(sample[36:42],16)))
    A3  = Volt2g(Count2Volt_bipol(int(sample[42:48],16)))
    return A1,A2,A3 
def EPSI_channel_bivolt(sample,posi):
    Cha  = Count2Volt_bipol(int(sample[posi:posi+6],16))
    return Cha

def EPSI_channel_unig(sample,posi):
    Cha  = Volt2g(Count2Volt_unipol(int(sample[posi:posi+6],16)))
    return Cha
def EPSI_channel_big(sample,posi):
    Cha  = Volt2g(Count2Volt_bipol(int(sample[posi:posi+6],16)))
    return Cha





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
    RTC1=int(Splitblock[0].split(b',')[1],16)
    RTC2=int(Splitblock1[0].split(b',')[1],16)
    epsisample_per_block=len(Splitblock[1][6:].split(b'\r\n'))-1
    freq=epsisample_per_block*32768/(RTC2-RTC1)
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
    



def get_shear_calibration(Meta_Epsi):
    path2file1=  '%s/%s/Calibration_%s.txt' % (Meta_Epsi.shearcal_path,Meta_Epsi.s1.SN,Meta_Epsi.s1.SN);
    path2file2=  '%s/%s/Calibration_%s.txt' % (Meta_Epsi.shearcal_path,Meta_Epsi.s2.SN,Meta_Epsi.s2.SN);

    fid1=open(path2file1,'r');
    Cal1=fid1.readlines();
    Meta_Epsi.s1.Sv=Cal1[-1].split(',')[1];
    fid1.close();

    fid2=open(path2file2,'r');
    Cal2=fid2.readlines();
    Meta_Epsi.s2.Sv=Cal2[-1].split(',')[1];
    fid2.close();
    return Meta_Epsi



def get_filters_name_MADRE(Meta_Data):
    if Meta_Data.Firmware.version=='MADRE2.1':
        shearfilt = 'sinc4';
        FPO7filt  = 'sinc4';
        Meta_Data.epsi.s1.ADCfilter=shearfilt;
        Meta_Data.epsi.s2.ADCfilter=shearfilt;
        Meta_Data.epsi.t1.ADCfilter=FPO7filt;
        Meta_Data.epsi.t2.ADCfilter=FPO7filt;

    return Meta_Data








## end local library TO DO: move it somewhere else

def Epsiblock2sample(EPSIsample,Epsiblock):

    EPSIsample.raw = Epsiblock
    epsisamples    = EPSIsample.raw  ## TODO change because it only works when madre send hex
    
    EPSIsample.T1 = [];
    EPSIsample.T2 = [];
    EPSIsample.S1 = [];
    EPSIsample.S2 = [];
    EPSIsample.C  = [];
    EPSIsample.A1 = [];
    EPSIsample.A2 = [];
    EPSIsample.A3 = [];
    for (i,sample) in enumerate(epsisamples): 
           t1,t2    = EPSI_temp(sample[:-2])
           s1,s2    = EPSI_shear(sample[:-2])
#           c        = EPSI_cond(sample[:-2])
           a1,a2,a3 = EPSI_accel(sample[:-2])
           EPSIsample.T1.append(t1);   EPSIsample.T2.append(t2);           
           EPSIsample.S1.append(s1);   EPSIsample.S2.append(s2);          
#           EPSIsample.C.append(c);           
           EPSIsample.A1.append(a1);EPSIsample.A2.append(a2);           
           EPSIsample.A3.append(a3);           
           
    return EPSIsample


