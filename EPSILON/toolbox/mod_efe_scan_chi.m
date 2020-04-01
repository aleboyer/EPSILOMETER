function [Pt,Ptk,Ptgk,chi,fc,flag,fe]=mod_efe_scan_chi(scan,fpo7_channel,Meta_Data,h_freq,FPO7noise)

switch fpo7_channel
    case 't1'
        dTdV=Meta_Data.epsi.t1.dTdV;
    case 't2'
        dTdV=Meta_Data.epsi.t2.dTdV;
    otherwise
        disp('wrong epsi channel to compute chi')
end

nfft=Meta_Data.PROCESS.nfft;
df=Meta_Data.df_epsi;


% first get the spectrum in Volt so we can estimate the noise level and get
% a cut-off freqeuncy
[P0,~] = pwelch(detrend(scan.(fpo7_channel))./dTdV,nfft,[],nfft,df,'psd');
[P,fe] = pwelch(detrend(scan.(fpo7_channel)),nfft,[],nfft,df,'psd');

if nargin<5
    h_freq=get_filters_MADRE(Meta_Data,fe);
    % get FPO7 channel average noise to compute chi
    switch Meta_Data.MAP.temperature
        case 'Tdiff'
            FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
        otherwise
            FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
    end
end



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
