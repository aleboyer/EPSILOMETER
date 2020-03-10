function Profile=calc_turbulence(Profile,tscan,nfft,nfftc,df,dz,fpump,Meta_Data)

%  Profile structure for Micro Structure. Inside Profile you ll find
%  temperature spectra in degC Hz^-1
%  Horizontal  velocity spectra in m^2/s^-2 Hz^-1
%  Acceleration/speed spectra in s^-1 Hz^-1 
%
%  Created by Arnaud Le Boyer on 7/28/18.

%% get channels
channels=Meta_Data.PROCESS.channels;
nb_channels=length(channels);
%% Gravity  ... of the situation :)
G       = 9.81;
%% limit speed 20 cm s^{-1}
limit_speed=.2;
%% define the fall rate of the Profile. 
%  Add Profile.w with w the vertical vel. 
%  We are using the pressure from other sensors (CTD);
switch Meta_Data.vehicle
    case 'FISH'
        Profile = compute_fallrate_downcast(Profile);
    case 'WW'
        % TODO: make the P from the WW CTD in the same unit as SEABIRD
        Profile = compute_speed_upcast(Profile);
        Profile.w=-Profile.w/1e7;
end
%% TODO check the dimension of the raw time series to remove this line
Profile=structfun(@(x) x(:),Profile,'un',0);
%% define a Pressure axis to an which I will compute epsilon and chi. 
%  The spectra will be nfft long centered around P(z) +/- tscan/2. 
%  

Pr=ceil(min(Profile.P)):dz:floor(max(Profile.P));
nbscan=length(Pr);
T=length(Profile.P);% length of profile
% numbuer of samples for a scan. I make sure it is always even
N=tscan.*df-mod(tscan*df,2);

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

% get FPO7 channel average noise to compute chi
switch Meta_Data.MAP.temperature
    case 'Tdiff'
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
    otherwise
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
end



% start creating the Profile structure
% get nb of scans in the profile
Profile.pr        = Pr;
Profile.nbscan    = nbscan;
Profile.nfft      = nfft;
Profile.tscan     = tscan;
Profile.fpump     = fpump; % arbitrary cut off frequency usually extract from coherence spectra shear/accel 
Profile.nbchannel = nb_channels;

%initialize process flags
Profile.process_flag=Pr*0+1;
Profile.epsilon=zeros(nbscan,2).*nan;
Profile.sh_fc=zeros(nbscan,2).*nan;
Profile.chi=zeros(nbscan,2).*nan;
Profile.tg_fc=zeros(nbscan,2).*nan;
Profile.tg_flag=zeros(nbscan,2).*nan;

% Profile.w=zeros(nbscan,1).*nan;
Profile.t=zeros(nbscan,1).*nan;
Profile.s=zeros(nbscan,1).*nan;
Profile.dnum=zeros(nbscan,1).*nan;

% loop along the pressure axis.
average_scan=@(x,y) (nanmean(x(y)));
for p=1:nbscan % p is the scan index.
    [~,indP] = sort(abs(Profile.P-Pr(p)));
    indP=indP(1);
    ind_scan = indP-N/2:indP+N/2; % ind_scan is even
    scan.w   = average_scan(Profile.w,ind_scan(ind_scan>0 & ind_scan<T));
    % check if the scan is not too shallow or too close to the end of the
    % profile. Also check if the speed if >20 cm s^{-1}
    if (ind_scan(1)>0 && ind_scan(end)<T && scan.w>limit_speed) 
        % compute mean values of w,T,S of each scans
        scan.w    = average_scan(Profile.w,ind_scan);
        scan.t    = average_scan(Profile.T,ind_scan);
        scan.s    = average_scan(Profile.S,ind_scan);
        scan.pr   = average_scan(Profile.P,ind_scan); % I know this redondant with Pr axis
        scan.dnum = average_scan(Profile.time,ind_scan);
        scan.kvis=nu(scan.s,scan.t,scan.pr);
        scan.ktemp=kt(scan.s,scan.t,scan.pr);
        scan.kmax=fpump./scan.w;
        % compute spectra for acceleration channels.
        for c=[inda1 inda2 inda3]
            wh_channels=channels{c};
            scan.(wh_channels)=Profile.(wh_channels)(ind_scan)*G; % time series in m.s^{-2}
            [scan.P.(wh_channels),fe] = pwelch(detrend(scan.(wh_channels)),nfft,[],nfft,df,'psd');
        end
        % get the filter transfer functions.
        if ~exist('h_freq','var')
            h_freq=get_filters_MADRE(Meta_Data,fe);
        end

        for c=1:length(channels)
            wh_channel=channels{c};
            switch wh_channel
                case 't1'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_scan).*dTdV(1); % time series in Celsius
                    [~,~,~,scan.chi(1),scan.tg_fc(1),scan.tg_flag(1)]=mod_efe_scan_chi(scan,wh_channel,h_freq,nfft,df,dTdV(1),FPO7noise);
                case 't2'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_scan).*dTdV(2); % time series in Celsius
                    [~,~,~,scan.chi(2),scan.tg_fc(2),scan.tg_flag(2)]=mod_efe_scan_chi(scan,wh_channel,h_freq,nfft,df,dTdV(1),FPO7noise);
                case 's1'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_scan).*G./(Sv1.*scan.w); % time series in m.s^{-1}
                    [~,~,~,scan.epsilon(1),scan.sh_fc(1)]=mod_efe_scan_epsilon(scan,wh_channel,'a3',h_freq,nfft,nfftc,df,fpump);
                case 's2'
                    scan.(wh_channel)=Profile.(wh_channel)(ind_scan).*G ./(Sv2.*scan.w); % time series in m.s^{-1}
                    [~,~,~,scan.epsilon(2),scan.sh_fc(2)]=mod_efe_scan_epsilon(scan,wh_channel,'a3',h_freq,nfft,nfftc,df,fpump);
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
        
    end
end
Profile.fe=fe;

