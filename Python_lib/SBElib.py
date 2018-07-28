#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan 14 10:00:51 2018

@author: aleboyer
"""
import numpy as np

## local library
#  reads and apply calibration to the conductivity data
def get_CalSBE(filename='SBE49_4935239-0058_cal.dat'):
    class SBEcal_class:
        pass
    SBEcal=SBEcal_class
    fid=open(filename)
    line=fid.readline()
    SBEcal.SN=line[-5:-1]
   ## Temperature Cal 
    line=fid.readline()
    SBEcal.TempCal_date=line[-10:-1]
    line=fid.readline()
    SBEcal.ta0=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ta1=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ta2=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ta3=float(line[-14:-1])
    line=fid.readline()
    SBEcal.toffset=float(line[-14:-1])
   ## Conductivity Cal 
    line=fid.readline()
    SBEcal.CondCal_date=line[-10:-1]
    line=fid.readline()
    SBEcal.g=float(line[-14:-1])
    line=fid.readline()
    SBEcal.h=float(line[-14:-1])
    line=fid.readline()
    SBEcal.i=float(line[-14:-1])
    line=fid.readline()
    SBEcal.j=float(line[-14:-1])
    line=fid.readline()
    SBEcal.tcor=float(line[-14:-1])
    line=fid.readline()
    SBEcal.pcor=float(line[-14:-1])
    line=fid.readline()
    SBEcal.cslope=float(line[-14:-1])
   ## Pressure Cal
    line=fid.readline()
    SBEcal.PresCal_date=line[-10:-1]
    line=fid.readline()
    SBEcal.pa0=float(line[-14:-1])
    line=fid.readline()
    SBEcal.pa1=float(line[-14:-1])
    line=fid.readline()
    SBEcal.pa2=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptca0=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptca1=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptca2=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptcb0=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptcb1=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptcb2=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptempa0=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptempa1=float(line[-14:-1])
    line=fid.readline()
    SBEcal.ptempa2=float(line[-14:-1])
    line=fid.readline()
    SBEcal.poffset=float(line[-14:-1])
  
    return SBEcal 

def SBE_temp(SBEcal,SBEsample):
    a0 = SBEcal.ta0;
    a1 = SBEcal.ta1;
    a2 = SBEcal.ta2;
    a3 = SBEcal.ta3;
    
    rawT = int(SBEsample.raw[:6],16);
    mv = (rawT-524288)/1.6e7;
    r = (mv*2.295e10 + 9.216e8)/(6.144e4-mv*5.3e5);
    SBEsample.temperature = a0+a1*np.log(r)+a2*np.log(r)**2+a3*np.log(r)**3;
    SBEsample.temperature = 1/SBEsample.temperature - 273.15;
    return SBEsample 

def SBE_cond(SBEcal,SBEsample):
    g    = SBEcal.g;
    h    = SBEcal.h;
    i    = SBEcal.i;
    j    = SBEcal.j;
    tcor = SBEcal.tcor;
    pcor = SBEcal.pcor;
     
    f = int(SBEsample.raw[6:12],16)/256/1000;
    SBEsample.conductivity = (g+h*f**2+i*f**3+j*f**4)/(1+tcor*SBEsample.temperature+pcor*SBEsample.pressure);
 
    return SBEsample
 
#  reads and apply calibration to the pressure data
def SBE_Pres(SBEcal,SBEsample):
    pa0     = SBEcal.pa0;
    pa1     = SBEcal.pa1;
    pa2     = SBEcal.pa2;
    ptempa0 = SBEcal.ptempa0;
    ptempa1 = SBEcal.ptempa1;
    ptempa2 = SBEcal.ptempa2;
    ptca0   = SBEcal.ptca0;
    ptca1   = SBEcal.ptca1;
    ptca2   = SBEcal.ptca2;
    ptcb0   = SBEcal.ptcb0;
    ptcb1   = SBEcal.ptcb1;
    ptcb2   = SBEcal.ptcb2;
    
    rawP = int(SBEsample.raw[12:18],16);
    y    = int(SBEsample.raw[18:22],16)/13107;
 
    t = ptempa0+ptempa1*y+ptempa2*y**2;
    x = rawP-ptca0-ptca1*t-ptca2*t**2;
    n = x*ptcb0/(ptcb0+ptcb1*t+ptcb2*t**2);
     
    SBEsample.pressure = (pa0+pa1*n+pa2*n**2-14.7)*0.689476;
     
    return SBEsample


def Aux1block2sample(SBEcal,Auxsample,Auxblock):
    Auxsample.raw = Auxblock[:22]
    Auxsample     = SBE_Pres(SBEcal,SBEsample)
    Auxsample     = SBE_temp(SBEcal,SBEsample)
    Auxsample     = SBE_cond(SBEcal,SBEsample)
    return SBEsample

