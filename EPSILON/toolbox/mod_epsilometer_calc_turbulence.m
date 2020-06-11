function Profile=mod_epsilometer_calc_turbulence(CTDProfile,EpsiProfile,dz,Meta_Data)

%  Profile structure for Micro Structure. Inside Profile you ll find
%  temperature spectra in degC Hz^-1
%  Horizontal  velocity spectra in m^2/s^-2 Hz^-1
%  Acceleration/speed spectra in s^-1 Hz^-1 
%
%  Created by Arnaud Le Boyer on 7/28/18.

%% get channels
channels=Meta_Data.PROCESS.channels;

nfft=Meta_Data.PROCESS.nfft;
nfftc=Meta_Data.PROCESS.nfftc;
Fs_epsi=Meta_Data.PROCESS.Fs_epsi;
Fs_ctd=Meta_Data.PROCESS.Fs_ctd;


fpump=Meta_Data.PROCESS.ctd_fc;
tscan=Meta_Data.PROCESS.tscan;

%% Gravity  ... of the situation :)
G       = 9.81;
twoG    =2*G;
%% limit speed 20 cm s^{-1}
limit_speed=.2;
%% define the fall rate of the Profile. 
%  Add Profile.w with w the vertical vel. 
%  We are using the pressure from other sensors (CTD);

%% TODO check the dimension of the raw time series to remove this line

% profile to process
Prmin=min(CTDProfile.P);
Prmax=max(CTDProfile.P);
Profile=mod_epsilometer_merge_profile(CTDProfile,EpsiProfile,Prmin,Prmax);

% cut profile to compute coherence
% this  depth range to compute the coherence. 
% this WILL choke when depth is varying. 
% TODO change the coherence estimation to use a range in percentage of the
% profile 

dP=max(CTDProfile.P)-min(CTDProfile.P);
Prmin=min(CTDProfile.P)+.2*dP;
Prmax=max(CTDProfile.P)-.2*dP;
Profile_coh=mod_epsilometer_merge_profile(CTDProfile,EpsiProfile,Prmin,Prmax);

                    
switch Meta_Data.vehicle
    case 'FISH'
        Profile.dPdt = compute_fallrate_downcast(CTDProfile);
    case 'WW'
        % TODO: make the P from the WW CTD in the same unit as SEABIRD
        Profile.dPdt = compute_speed_upcast(CTDProfile);
        Profile.dPdt = -Profile.dPdt/1e7;
end
%% define a Pressure axis to an which I will compute epsilon and chi. 
%  The spectra will be nfft long centered around P(z) +/- tscan/2. 
%  

Pr=ceil(min(Profile.P)):dz:floor(max(Profile.P));
nbscan=length(Pr);

LCTD=length(Profile.P);% length of profile
% number of samples for a scan. I make sure it is always even
N_epsi=tscan.*Fs_epsi-mod(tscan*Fs_epsi,2);
N_ctd=tscan.*Fs_ctd-mod(tscan*Fs_ctd,2);

% get index of the acceleration channels (usefull when the number of channels is not 8)
inda1=find(cellfun(@(x) strcmp(x,'a1'),channels));
inda2=find(cellfun(@(x) strcmp(x,'a2'),channels));
inda3=find(cellfun(@(x) strcmp(x,'a3'),channels));

% get shear probe calibration coefficient.
Sv1=Meta_Data.epsi.s1.Sv;
Sv2=Meta_Data.epsi.s2.Sv;
% Sensitivity of FPO7 probe, nominal
dTdV(1)=Meta_Data.epsi.t1.dTdV; % define in mod_epsi_temperature_spectra
dTdV(2)=Meta_Data.epsi.t2.dTdV; % define in mod_epsi_temperature_spectra 

fe=Meta_Data.PROCESS.fe;
h_freq=Meta_Data.PROCESS.h_freq;
FPO7noise=Meta_Data.PROCESS.FPO7noise;


% start creating the Profile structure
% get nb of scans in the profile
Profile.pr        = Pr;
Profile.nbscan    = nbscan;
Profile.nfft      = nfft;
Profile.nfftc     = nfftc;
Profile.tscan     = tscan;
Profile.fpump     = fpump; % arbitrary cut off frequency usually extract from coherence spectra shear/accel 
Profile.fe        = fe;

%initialize process flags
Profile.process_flag=Pr*0;
Profile.epsilon=zeros(nbscan,2).*nan;
Profile.sh_fc=zeros(nbscan,2).*nan;
Profile.chi=zeros(nbscan,2).*nan;
Profile.tg_fc=zeros(nbscan,2).*nan;
Profile.tg_flag=zeros(nbscan,2).*nan;

for c=1:length(channels)
    wh_channel=channels{c};
    Profile.Pc1c2.(wh_channel)=Pr*0;
    switch wh_channel
        case {'a1','a2','a3'}
            fieldstr1=sprintf('Cu1%s',wh_channel);
            Profile.Cc1c2.(fieldstr1)=Pr*0;
            fieldstr2=sprintf('Cu2%s',wh_channel);
            Profile.Cc1c2.(fieldstr2)=Pr*0;
    end
end

% Profile.w=zeros(nbscan,1).*nan;
Profile.t=zeros(nbscan,1).*nan;
Profile.w=zeros(nbscan,1).*nan;
Profile.s=zeros(nbscan,1).*nan;
Profile.dnum=zeros(nbscan,1).*nan;


% compute Coherence over the whole profile.
for c=[inda1 inda2 inda3]
    wh_channel=channels{c};
    [scan.Cu1a.(wh_channel),scan.Cu2a.(wh_channel),...
     ~,~,~]=mod_efe_scan_coherence(Profile_coh,wh_channel,Meta_Data);
     
    fieldstr1=sprintf('Cu1%s',wh_channel);
    Profile.(fieldstr1)=fe*0;
    fieldstr2=sprintf('Cu2%s',wh_channel);
    Profile.(fieldstr2)=fe*0;

end

% loop along the pressure axis.
average_scan=@(x,y) (nanmean(x(y)));
for p=1:nbscan % p is the scan index.
    [~,indP] = sort(abs(Profile.P-Pr(p)));
    indP=indP(1);
    ind_ctdscan = indP-N_ctd/2:indP+N_ctd/2; % ind_scan is even
    scan.w   = average_scan(Profile.dPdt,ind_ctdscan(ind_ctdscan>0 & ind_ctdscan<LCTD));
    % check if the scan is not too shallow or too close to the end of the
    % profile. Also check if the speed if >20 cm s^{-1}
    if (ind_ctdscan(1)>N_ctd/2 && ind_ctdscan(end)<LCTD-N_ctd/2 && scan.w>limit_speed) 
        ind_Pr_epsi = find(EpsiProfile.epsitime>CTDProfile.ctdtime(indP),1,'first');
        ind_epsiscan = ind_Pr_epsi-N_epsi/2:ind_Pr_epsi+N_epsi/2; % ind_scan is even
        % compute mean values of w,T,S of each scans
        scan.w    = average_scan(Profile.dPdt,ind_ctdscan);
        scan.t    = average_scan(Profile.T,ind_ctdscan);
        scan.s    = average_scan(Profile.S,ind_ctdscan);
        scan.pr   = average_scan(Profile.P,ind_ctdscan); % I know this redondant with Pr axis
        scan.dnum = average_scan(Profile.ctdtime,ind_ctdscan);
        scan.kvis=nu(scan.s,scan.t,scan.pr);
        scan.ktemp=kt(scan.s,scan.t,scan.pr);
        scan.kmax=fpump./scan.w;
        
        for c=1:length(channels)
            wh_channel=channels{c};
            switch wh_channel
            case {'a1','a2','a3'}
            scan.(wh_channel)=Profile.(wh_channel)(ind_epsiscan)*G; % time series in m.s^{-2}
            case 's1'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_epsiscan).*twoG./(Sv1.*scan.w); % time series in m.s^{-1}
            case 's2'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_epsiscan).*twoG./(Sv2.*scan.w); % time series in m.s^{-1}
            case 't1'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_epsiscan).*dTdV(1); % time series in Celsius
            case 't2'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_epsiscan).*dTdV(2); % time series in Celsius
            end
        end
        
        % compute spectra for acceleration channels.
        for c=[inda1 inda2 inda3]
            wh_channel=channels{c};
            fieldstr1=sprintf('Cu1%s',wh_channel);
            fieldstr2=sprintf('Cu2%s',wh_channel);
            
            [~,Profile.Pc1c2.(wh_channel)(p),~]= ...
                mod_efe_scan_acceleration(scan,wh_channel,Meta_Data);
            [~,~,Profile.Cc1c2.(fieldstr1)(p),Profile.Cc1c2.(fieldstr2)(p),~]= ...
                mod_efe_scan_coherence(scan,wh_channel,Meta_Data);
        end
        
        % get the filter transfer functions.
        % TODO add Profile.Pc1c2 for t1 t2 s1 s2 
        for c=1:length(channels)
            wh_channel=channels{c};
            switch wh_channel
                case 't1'
                    [~,~,~,scan.chi(1),scan.tg_fc(1),scan.tg_flag(1)]=mod_efe_scan_chi(scan,wh_channel,Meta_Data,h_freq,FPO7noise);
                case 't2'
                    [~,~,~,scan.chi(2),scan.tg_fc(2),scan.tg_flag(2)]=mod_efe_scan_chi(scan,wh_channel,Meta_Data,h_freq,FPO7noise);
                case 's1'
                    [~,~,~,~,~,scan.epsilon(1),scan.sh_fc(1),~]=mod_efe_scan_epsilon(scan,wh_channel,'a3',Meta_Data);
                case 's2'
                    [~,~,~,~,~,scan.epsilon(2),scan.sh_fc(2),~]=mod_efe_scan_epsilon(scan,wh_channel,'a3',Meta_Data);
            end
        end
        Profile.epsilon(p,1)=scan.epsilon(1);
        Profile.epsilon(p,2)=scan.epsilon(2);
        Profile.sh_fc(p,1)=scan.sh_fc(1);
        Profile.sh_fc(p,2)=scan.sh_fc(2);

        Profile.chi(p,1)=scan.chi(1);
        Profile.chi(p,2)=scan.chi(2);
        Profile.tg_fc(p,1)=scan.tg_fc(1);
        Profile.tg_fc(p,2)=scan.tg_fc(2);
        Profile.tg_flag(p,1)=scan.tg_flag(1);
        Profile.tg_flag(p,2)=scan.tg_flag(2);

        Profile.w(p)=scan.w;
        Profile.t(p)=scan.t;
        Profile.s(p)=scan.s;
        Profile.dnum(p)=scan.dnum;
        Profile.process_flag(p)=1;
        
    end
end

