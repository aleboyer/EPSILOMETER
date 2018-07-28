#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan 31 11:09:23 2018

@author: aleboyer
"""

eof=fid.tell()
fid.seek(0)
blocklen,headerlen,aux1len,aux2len,epsilen,freq= \
                                define_block(fid,eof)



segments_shear1,dof=split_block(s1,freq,Lsec=20)
[k,spec_shear1]=makefft(segments_shear1,freq)
mspec_shear1=np.mean(spec_shear1,1)
S1rms= np.sqrt(np.mean(s1**2));
plot_epsispectra(k,mspec_shear1,S1rms,freq,dof,'raw Shear1','Hz','Volt^2/Hz',filename[:-4]+'_S1spectrum.png')


segments_t1,dof=split_block(t1,freq,Lsec=20)
[k,spec_t1]=makefft(segments_t1,freq)
mspec_t1=np.mean(spec_t1,1)
t1rms= np.sqrt(np.mean(t1**2));
plot_epsispectra(k,mspec_t1,t1rms,freq,dof,'raw Temp 1','Hz','Volt^2/Hz',filename[:-4]+'_T1spectrum.png')


segments_a3,dof=split_block(a3,freq,Lsec=20)
[k,spec_a3]=makefft(segments_a3,freq)
mspec_a3=np.mean(spec_a3,1)
a3rms= np.sqrt(np.mean(a3**2));
plot_epsispectra(k,mspec_a3,a3rms,freq,dof,'raw Az','Hz','Volt^2/Hz',filename[:-4]+'_a3spectrum.png')

