function [Pa,fe]=mod_efe_scan_acceleration(scan,acceleration_channel,Meta_Data,h_freq)
% get epsilon and the cutting frequency 


nfft=Meta_Data.PROCESS.nfft;
df=Meta_Data.df_epsi;

[P,fe] = pwelch(detrend(scan.(acceleration_channel)),nfft,[],nfft,df,'psd');

% get the filter transfer functions.
if nargin<5
    h_freq=get_filters_MADRE(Meta_Data,fe);
end

filter_TF=(h_freq.electAccel);
Pa   = P./filter_TF;
