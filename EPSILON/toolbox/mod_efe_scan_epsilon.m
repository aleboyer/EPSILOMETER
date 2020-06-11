function [P,Pv,Pvk,Psk,Cua,epsilon,fc,fe]=mod_efe_scan_epsilon(scan,shear_channel,acceleration_channel,Meta_Data)
% get epsilon and the cutting frequency 
%
% OUTPUTS:
%   P   = shear frequency power spectrum 
%   Pv  = non-coherent shear frequency power spectrum (full profile coherence with a3 channel has been removed) 
%   Pvk = non-coherent shear wavenumber power spectrum
%   Psk = non-coherent shear 2pi*wavenumber power spectrum
%   Cua = full profile coherence between shear channel and a3, computed
%         earlier with mod_efe_scan_coherence
%   epsilon = epsilon calculated from Psk
%   fc  = cutoff frequency
%   fe  = frequency array

nfft=Meta_Data.PROCESS.nfft;
Fs=Meta_Data.PROCESS.Fs_epsi;
fpump=Meta_Data.PROCESS.ctd_fc;

[P,fe] = pwelch(detrend(scan.(shear_channel)),nfft,[],nfft,Fs,'psd');

% get the filter transfer functions.
h_freq=Meta_Data.PROCESS.h_freq;

% [Cu1a3,~] = mscohere(detrend(scan.(shear_channel)),detrend(scan.(acceleration_channel)),nfftc,[],nfftc,Fs);
switch shear_channel
    case 's1'
        Cua = scan.Cu1a.(acceleration_channel);
    case 's2'
        Cua = scan.Cu2a.(acceleration_channel);
end
Pp=P.*(1-Cua);
filter_TF=(h_freq.shear .* haf_oakey(fe,scan.w));
Pv   = Pp./filter_TF;
Pvk  = Pv.*scan.w;
ke   = fe/scan.w;
Psk = Pvk.*(2*pi*ke).^2;
kmax=fpump./scan.w;
[epsilon,kc]=eps1_mmp(ke,Psk,scan.kvis,kmax);
fc=kc.*scan.w;