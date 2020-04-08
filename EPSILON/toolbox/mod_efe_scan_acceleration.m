function [Pa,Cu1a,Cu2a,sumP,sumCu1a,sumCu2a,fe]=mod_efe_scan_acceleration(scan,acceleration_channel,Meta_Data)
% get epsilon and the cutting frequency 


nfft=Meta_Data.PROCESS.nfft;
nfftc=Meta_Data.PROCESS.nfftc;
Fs=Meta_Data.PROCESS.Fs_epsi;
fc1=Meta_Data.PROCESS.fc1;
fc2=Meta_Data.PROCESS.fc2;
h_freq=Meta_Data.PROCESS.h_freq;


[P,fe] = pwelch(detrend(scan.(acceleration_channel)),nfft,[],nfft,Fs,'psd');
[Cu1a,~] = mscohere(detrend(scan.s1),detrend(scan.(acceleration_channel)),nfftc,[],nfft,Fs);
[Cu2a,~] = mscohere(detrend(scan.s2),detrend(scan.(acceleration_channel)),nfftc,[],nfft,Fs);


filter_TF=(h_freq.electAccel);
Pa   = P./filter_TF;
sumP=sum(Pa(fe>fc1 & fe<fc2))*nanmean(diff(fe));
sumCu1a=sum(Cu1a(fe>fc1 & fe<fc2))*nanmean(diff(fe));
sumCu2a=sum(Cu2a(fe>fc1 & fe<fc2))*nanmean(diff(fe));
