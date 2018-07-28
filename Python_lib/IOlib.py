#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan 14 10:02:19 2018

@author: aleboyer
"""

import time
import matplotlib.pyplot as plt
from matplotlib.widgets import RadioButtons,Slider

global epsisample_per_block


## local library for plotting

def init_figure(num_sub):
    fig = plt.figure(0)
    #fig1 = plt.figure(1)
    #fig.add_subplot(1,1,1,autoscale_on=True)
    return fig

def init_axes(fig):
    ax0=plt.axes([.3,.4,.5,.5])
    ax1=plt.axes([.1,.1,.15,.2])
    ax2=plt.axes([.3,.01,.5,.05])
    ax3=plt.axes([.3,.1,.5,.05])
    ax4=plt.axes([.1,.4,.15,.5])
    # set up subplot 
    ax0.cla()
    lineF0, = ax0.plot([],[], '.-', alpha=0.8, color="gray", markerfacecolor="red")
    lineV1, = ax0.plot([],[], '.-', alpha=0.8, color="gray", markerfacecolor="green")
    lineV2, = ax0.plot([],[], '.-', alpha=0.8, color="gray", markerfacecolor="cyan")
    radio = RadioButtons(ax1, ('Counts', 'Volts')) 
    radio1 = RadioButtons(ax4, ('t1', 't2','s1','s2','a1','a2','a3'))
    Sl_ymin = Slider(ax2, 'Ymin', 0, 1, valinit=.5)
    Sl_ymax = Slider(ax3, 'Ymax', 0, 1, valinit=.5)
    ax0.set_xlabel('Second')
    ax0.set_ylabel('Counts')
    return lineF0,lineV1,lineV2,radio,radio1,Sl_ymin,Sl_ymax,ax0



def read_allfile(filename='MADRE2.1.dat'):
    fid=open('../data/' + filename,'br')
    eof=fid.seek(0,2)
    fid.seek(0)
    return fid,eof


def open_datafile(filename='../data/MADRE2.1.dat'):
    fid=open(filename,'br')
    eof=fid.seek(0,2)
    fid.seek(0)
    return fid,eof


def seekend_datafile(fid,eof):
    fid.seek(eof-3*7500) # 7500 is about the size of 1 block (.5 second) with SBE49 
    line=fid.readline()
#    while(len(line)!=29):
    while(line[:6]!=b'$MADRE'):
          line=fid.readline()
          print('tracking header !!!')

    print('header found. Start plotting !!!')
    fid.seek(fid.tell()-61)
    #fid.seek(0)
    return fid,eof
    
    
def read_header(fid):
    class header_class:
          pass
    header=header_class
    header.raw=fid.readline()
    header.EpsiStamp      = int(header.raw[6:6+8],16)
    header.TimeStamp      = int(header.raw[15:15+8],16)
    header.Voltage        = int(header.raw[24:24+8],16)
    header.aux1_checksum  = int(header.raw[33:33+8],16)
    header.aux2_checksum  = int(header.raw[42:42+8],16)
    header.block_checksum = int(header.raw[51:51+8],16)

    header.local_timestamp= time.time()
    return header    

def read_block(fid):   
    block=[fid.readline() for i in range(epsisample_per_block)] # 24 is for the length of the SBE49 sample
    return block
def read_aux1sample(fid):   
    block=[fid.readline() for i in range(aux1sample_per_block)] # 24 is for the length of the SBE49 sample
    return block


 
 
