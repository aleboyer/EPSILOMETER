function [Pv,Pvk,Psk,epsilon,fc]=mod_efe_scan_epsilon(scan,shear_channel,acceleration_channel,h_freq,nfft,nfftc,df,fpump)

% get epsilon and the cutting frequency 

[P,fe] = pwelch(detrend(scan.(shear_channel)),nfft,[],nfft,df,'psd');
[Cu1a3,~] = mscohere(detrend(scan.(shear_channel)),detrend(scan.(acceleration_channel)),nfftc,[],nfftc,df);
Pp=P.*(1-Cu1a3);
filter_TF=(h_freq.shear .* haf_oakey(fe,scan.w));
Pv   = Pp./filter_TF;
Pvk   = Pv.*scan.w;
ke=fe/scan.w;
Psk = Pvk.*(2*pi*ke).^2;
kmax=fpump./scan.w;
[epsilon,kc]=eps1_mmp(ke,Psk,scan.kvis,kmax);
fc=kc.*scan.w;