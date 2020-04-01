function [P,Pv,Pvk,Psk,Cu1a3,epsilon,fc,fe]=mod_efe_scan_epsilon(scan,shear_channel,acceleration_channel,Meta_Data,h_freq)
% get epsilon and the cutting frequency 


nfft=Meta_Data.PROCESS.nfft;
nfftc=Meta_Data.PROCESS.nfftc;
df=Meta_Data.df_epsi;
fpump=Meta_Data.fpump;

[P,fe] = pwelch(detrend(scan.(shear_channel)),nfft,[],nfft,df,'psd');

% get the filter transfer functions.
if nargin<5
    h_freq=get_filters_MADRE(Meta_Data,fe);
end

[Cu1a3,~] = mscohere(detrend(scan.(shear_channel)),detrend(scan.(acceleration_channel)),nfftc,[],nfftc,df);
Pp=P.*(1-Cu1a3);
filter_TF=(h_freq.shear .* haf_oakey(fe,scan.w))/2^2;
Pv   = Pp./filter_TF;
Pvk   = Pv.*scan.w;
ke=fe/scan.w;
Psk = Pvk.*(2*pi*ke).^2;
kmax=fpump./scan.w;
[epsilon,kc]=eps1_mmp(ke,Psk,scan.kvis,kmax);
fc=kc.*scan.w;