#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May 17 07:32:42 2018

@author: MS
"""
import numpy as np
import matplotlib.pyplot as plt

#fid=open('/Volumes/MS/science/GRANITE/SD_card_data/ep_test_20170101_000000_1.dat','rb')
fid=open('ep_test_20170101_000000_1.dat','rb')
lines=fid.read();

MADREblocks=lines.split(b'$MADRE')
chsum_board=np.zeros(len(MADREblocks[1:-1]))
chsum_post=np.zeros(len(MADREblocks[1:-1]))
for (i,MADREblock) in enumerate(MADREblocks[1:-1]):
    Iblock=MADREblock.split(b'$AUX1')
    Header=Iblock[0]
    IIblock=Iblock[1].split(b'$EPSI')
    Auxblock=IIblock[0].split(b'\n')
    Epsiblock=IIblock[1].split(b'\n')
    checksumEPSI=Header.split(b',')[-1][:-1]
    checksumAUX=Header.split(b',')[3]
    if len(checksumEPSI.split(b'\x00'))>1:
        checksumEPSI=checksumEPSI.split(b'\x00')[-1]
    if len(checksumAUX.split(b'\x00'))>1:
        checksumAUX=checksumAUX.split(b'\x00')[-1]
    
    chsum_board[i]=int(checksumEPSI,16)
    
    chsum1=0;
    for epsi in Epsiblock[1:-1]:
        for posi in range(round(len(epsi)/2)): 
            sample=int(epsi[2*posi:2*posi+2].hex(),16)
            chsum1=chsum1^sample 
    chsum_post[i]=int(checksumEPSI,16)
        
fid.close()

plt.plot(chsum_board-chsum_post)
plt.show()

