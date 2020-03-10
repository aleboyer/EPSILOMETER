function [Pt,Ptk,Ptgk,chi,fc,flag]=mod_efe_scan_chi(scan,fpo7_channel,h_freq,nfft,df,dTdV,FPO7noise)


% first get the spectrum in Volt so we can estimate the noise level and get
% a cut-off freqeuncy
[P0,~] = pwelch(detrend(scan.(fpo7_channel))./dTdV,nfft,[],nfft,df,'psd');

[P,fe] = pwelch(detrend(scan.(fpo7_channel)),nfft,[],nfft,df,'psd');
filter_TF=h_freq.FPO7(scan.w);
Pt   = P./filter_TF;
Ptk   = Pt.*scan.w;
ke=fe/scan.w;
Ptgk = Ptk.*(2*pi*ke).^2;

dk=nanmean(diff(ke));

fc_index=FPO7_cutoff(fe,P0,FPO7noise);
fc= fe(find(fe<=fe(fc_index),1,'last'));
krange=find(ke<=ke(fc_index));
chi=6*scan.ktemp*dk.*nansum(Ptgk(krange));
% high signal flag: The cut off frequency is very high. 
% this could mean that the whole scan is corrupt since the spectrum is way
% above the noise floor.
flag=fc_index<round(.95*length(fe));
