#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb  1 18:58:55 2018

@author: aleboyer
"""



"""
Created on Thu Feb  1 11:10:15 2018

@author: aleboyer
"""
import sys
sys.path.insert(0,'../lib')
    

import matplotlib.pyplot as plt
from make_spectra import makefft,split_block,bitnoise
import numpy as np
import scipy.io as sio


if len(sys.argv)<=1:
    filename='SPROUL/d2/raw/oldMAD_wISO_oldMAP_raw.npy'
else:
    filename=sys.argv[1]



Accel_SPROUL=sio.loadmat('SPROUL/d2/raw/SD_sproul_accel_noise_spectrum.mat')
fa1=np.array(Accel_SPROUL.get('f'))
Pa1=np.array(Accel_SPROUL.get('Pa1'))

Shear_SPROUL=sio.loadmat('SPROUL/d2/raw/SD_sproul_shear_noise_spectrum.mat')
fs1=np.array(Shear_SPROUL.get('f'))
Ps1=np.array(Shear_SPROUL.get('Pa1'))


FPO7_SPROUL=sio.loadmat('SPROUL/d2/raw/SD_sproul_FPO7_noise_spectrum.mat')
ft1=np.array(FPO7_SPROUL.get('f'))
Pt1=np.array(FPO7_SPROUL.get('Pa2'))


d1_s1,d1_s2,d1_t1,d1_t2,d1_a1,d1_a2,d1_a3=np.load('SPROUL/d2/raw/newMAD_noISO_newMAP2_raw.npy')

# new data
d2_s1,d2_s2,d2_t1,d2_t2,d2_a1,d2_a2,d2_a3=np.load(filename)

Fs=325


d1=d1_a1[10:]
d2=d2_a1[10:]
title='Accelleration GRANITE/SPROUL'
ylabel='g^2/Hz'
xlabel='Hz'
filename_acc='Accel_GRANITE_vs_SPROUL.png'



segments_d1,dof1=split_block(d1,Fs,Lsec=20)
segments_d2,dof2=split_block(d2,Fs,Lsec=20)
k1,spec_pos1=makefft(segments_d1,Fs)
k2,spec_pos2=makefft(segments_d2,Fs)
mspec_pos1=np.mean(spec_pos1,1)
mspec_pos2=np.mean(spec_pos2,1)

Partnoise=45e-6**2+0*k1
   
fig = plt.figure(figsize=(20,10))
ax1 = fig.add_subplot(1, 1, 1)
datarms1=np.sqrt(np.mean(d1**2))
datarms2=np.sqrt(np.mean(d2**2))


# set up subplot 
ax1.set_title(title + '- dof:%i' % dof1,fontsize=25)
ax1.set_ylabel(ylabel,fontsize=25)
ax1.set_xlabel(xlabel,fontsize=25)
ax1.loglog(k1,mspec_pos2,'g',label=filename.split('/')[-1] )
ax1.loglog(fa1,Pa1.T,'r',label="SPROUL SD TEST" )
ax1.loglog(k1,mspec_pos1,'b',label="GRANITE SIObench" )

ax1.loglog(k1,Partnoise,'c',label="Part_Noise")
ax1.legend()
plt.savefig(filename_acc)


#COMPARISON_MAT={'k_granite':k1, \
#                'spec_granite':mspec_pos1, \
#                'k_sproul':np.arange(1,168), \
#                'spec_sproul':Pa1[0]}
#sio.savemat('/Volumes/KINGSTON/DEV/MADRESPROUL/d2/raw/comparison_accel_granite_sproul.mat',COMPARISON_MAT)



plt.show()    






title='Shear GRANITE/SPROUL'
ylabel='V^2/Hz'
xlabel='Hz'
filename_sh='Shear_GRANITE_vs_SPROUL_newresistance.png'

d1=d1_s1[10:]
d2=d2_s1[10:]

segments_d1,dof1=split_block(d1,Fs,Lsec=20)
segments_d2,dof2=split_block(d2,Fs,Lsec=20)
k1,spec_pos1=makefft(segments_d1,Fs)
k2,spec_pos2=makefft(segments_d2,Fs)
mspec_pos1=np.mean(spec_pos1,1)
mspec_pos2=np.mean(spec_pos2,1)

noise24= bitnoise(Fs,Nb_bi=24);
noise20= bitnoise(Fs,Nb_bi=20);
noise16= bitnoise(Fs,Nb_bi=16);
   
f      = np.pi*k1[1:]/Fs
sinc4  = (np.sin(f)/f)**4;

fig = plt.figure(figsize=(20,10))
ax1 = fig.add_subplot(1, 1, 1)
datarms1=np.sqrt(np.mean(d1**2))
datarms2=np.sqrt(np.mean(d2**2))


# set up subplot 
ax1.set_title(title + '- dof:%i' % dof1,fontsize=25)
ax1.set_ylabel(ylabel,fontsize=25)
ax1.set_xlabel(xlabel,fontsize=25)
ax1.loglog(k1,mspec_pos2,'g',label=filename.split('/')[-1]  )
ax1.loglog(fs1,Ps1.T,'r',label="SPROUL SD TEST" )
ax1.loglog(k1,mspec_pos1,'b',label="GRANITE" )
ax1.loglog(k1[1:],np.nanmedian(mspec_pos1[:20])*sinc4,'c',label="sinc4")
ax1.loglog(k1,noise24+0*k1,'k',label="noise 24 bit",lw=1)
ax1.loglog(k1,noise20+0*k1,'k--',label="noise 20 bit",lw=1)
ax1.loglog(k1,noise16+0*k1,'k.',label="noise 16 bit",lw=1)

ax1.legend()
plt.savefig(filename_sh)

plt.show()    

#COMPARISON_shear_MAT={'k_granite':k1, \
#                'spec_granite':mspec_pos1, \
#                'k_sproul':np.arange(1,168), \
#                'spec_sproul':Ps1[0]}
#sio.savemat('/Volumes/KINGSTON/DEV/MADRESPROUL/d2/raw/comparison_shear_granite_sproul.mat',COMPARISON_shear_MAT)



title='FPO7 GRANITE/SPROUL'
ylabel='V^2/Hz'
xlabel='Hz'
filename_fpo7='FPO7_GRANITE_vs_SPROUL_new_resistance.png'

d1=d1_t1[10:]
d2=d2_t1[10:]

segments_d1,dof1=split_block(d1,Fs,Lsec=20)
segments_d2,dof2=split_block(d2,Fs,Lsec=20)
k1,spec_pos1=makefft(segments_d1,Fs)
k2,spec_pos2=makefft(segments_d2,Fs)
mspec_pos1=np.mean(spec_pos1,1)
mspec_pos2=np.mean(spec_pos2,1)


noise24= bitnoise(Fs,Nb_bi=24);
noise20= bitnoise(Fs,Nb_bi=20);
noise16= bitnoise(Fs,Nb_bi=16);
   
fig = plt.figure(figsize=(20,10))
ax1 = fig.add_subplot(1, 1, 1)
datarms1=np.sqrt(np.mean(d1**2))
datarms2=np.sqrt(np.mean(d2**2))


# set up subplot 
ax1.set_title(title + '- dof:%i' % dof1,fontsize=25)
ax1.set_ylabel(ylabel,fontsize=25)
ax1.set_xlabel(xlabel,fontsize=25)
ax1.loglog(k1,mspec_pos2,'g',label=filename.split('/')[-1]   )
ax1.loglog(ft1,Pt1.T,'r',label="SPROUL SD TEST" )
ax1.loglog(k1,mspec_pos1,'b',label="GRANITE" )
ax1.loglog(k1[1:],np.nanmedian(mspec_pos1[:20])*sinc4,'c',label="sinc4")
ax1.loglog(k1,noise24+0*k1,'k',label="noise 24 bit",lw=1)
ax1.loglog(k1,noise20+0*k1,'k--',label="noise 20 bit",lw=1)
ax1.loglog(k1,noise16+0*k1,'k.',label="noise 16 bit",lw=1)

ax1.legend()
plt.savefig(filename_fpo7)

plt.show()    

#COMPARISON_MAT={'k_granite':k1, \
#                'spec_granite':mspec_pos1, \
#                'k_sproul':np.arange(1,168), \
#                'spec_sproul':Pt1[0]}
#sio.savemat('/Volumes/KINGSTON/DEV/MADRESPROUL/d2/raw/comparison_temp_granite_sproul.mat',COMPARISON_MAT)








