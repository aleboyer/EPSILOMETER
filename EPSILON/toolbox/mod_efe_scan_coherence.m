function [Cu1a,Cu2a,sumCu1a,sumCu2a,fe]=mod_efe_scan_coherence(scan,acceleration_channel,Meta_Data)
% Compute the coherence over the whole profile
% over the 1./tsan:Fs frequency frequency axis with nfft samples.


nfft=Meta_Data.PROCESS.nfft;
nfftc=Meta_Data.PROCESS.nfftc;
Fs=Meta_Data.PROCESS.Fs_epsi;
fc1=Meta_Data.PROCESS.fc1;
fc2=Meta_Data.PROCESS.fc2;

[Cu1a,fe] = mscohere(detrend(scan.s1),detrend(scan.(acceleration_channel)),nfftc,[],nfft,Fs);
[Cu2a,~] = mscohere(detrend(scan.s2),detrend(scan.(acceleration_channel)),nfftc,[],nfft,Fs);


sumCu1a=sum(Cu1a(fe>fc1 & fe<fc2))*nanmean(diff(fe));
sumCu2a=sum(Cu2a(fe>fc1 & fe<fc2))*nanmean(diff(fe));
