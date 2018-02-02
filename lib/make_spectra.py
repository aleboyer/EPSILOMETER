#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt


def makefft(dataBuffer,Fs):
  T,V    = dataBuffer.shape
  df       = Fs/T;                # Frequential resolution

  # hanning window to get rid of edges influence
  hanning = np.mat(0.5 * (1-np.cos(2*np.pi*np.linspace(0,T-1,T)/(T-1))));
  E=np.ones([1,V]);
  H=np.dot(hanning.T,E);
  wc=1/np.mean(np.array(hanning)**2);            # window correction factor

#TODO very BADDDD  use of matrix and np.dot ect. if time change that ALB 02/07/2017 ... 
  data=np.array(H)*np.array(dataBuffer-np.dot(np.ones([T,1]),np.mat(np.mean(dataBuffer,0))));# detrend  A2=A-mean(A)
  pspec=np.abs(np.fft.fft(data,axis=0))**2;
  pspec=pspec/T**2/df;
  spec=pspec*wc;       # spectrum where variance is sum(spec)*df
  if np.mod(T,2)==0:
     k=np.linspace(-T/2*df,T/2*df-df,T);
  else:
     kp=np.linspace(df,df*np.floor(T/2),T/2);
     k=np.concatenate((-kp[::-1],np.array([0]),kp));
  spec_pos=spec[k>=0,:]
  spec_pos=spec_pos[::-1,:]
  k=k[k>=0]
  return k,spec_pos

def bitnoise(Fs,FR=3,Nb_bi=24):
    # Fs sampling frequency
    Fn    = .5*Fs  # Nyquist frequency
 #= [(full range = 3V)/2^24 ]^2 / f_N where f_N =200 =#
    noise= (FR/2**Nb_bi)**2 /Fn
    return noise

#### read file



def split_block(data,Fs,Lsec=20):
    print('split time in block, default is 20s')
    Ts=int(Lsec*Fs)
    T=data.shape[0]
    dof=int(T/Ts)
    segments_data = np.zeros([Ts, dof])
    for i,l in enumerate(np.arange(0,dof*Ts,Ts)):
        segments_data[:,i]=data[l:l+Ts]
    
    return segments_data,dof

def plot_epsispectra(k,data,datarms,Fs,dof,title,xlabel,ylabel,filename):
    fig = plt.figure(figsize=(20,10))
    ax1 = fig.add_subplot(1, 1, 1)

    # set up subplot 
    ax1.set_title(title + '- dof:%i' % dof)
    ax1.set_ylabel(ylabel)
    ax1.set_xlabel(xlabel)
    ax1.loglog(k,data,'b',label="%s-rms=%2.3f" % (title,datarms) )


    noise24= bitnoise(Fs,Nb_bi=24);
    noise20= bitnoise(Fs,Nb_bi=20);
    noise16= bitnoise(Fs,Nb_bi=16);
    
    f      = np.pi*k[1:]/Fs
    sinc4  = (np.sin(f)/f)**4;

    ax1.loglog(k,noise24+0*k,'k',label="noise 24 bit",lw=1)
    ax1.loglog(k,noise20+0*k,'k--',label="noise 20 bit",lw=1)
    ax1.loglog(k,noise16+0*k,'k.',label="noise 16 bit",lw=1)
    ax1.loglog(k[1:],np.nanmedian(data[:20])*sinc4,'c',label="sinc4")
    ax1.legend()

    plt.savefig(filename)
    plt.show()    





