function [MS]=calc_turbulence(Profile,tscan,f,fmax,Meta_Data,dsp,i)

%  MS structure for Micro Structure. Inside MS you ll find
%  temperature spectra in degC Hz^-1
%  Horizontal  velocity spectra in m^2/s^-2 Hz^-1
%  Acceleration/speed spectra in s^-1 Hz^-1 
%
%  input: 
% .     Meta_Data
% . created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
% . path to calibration file and EPSI configuration needed to process the
% . epsi data
% .     Profile
% . EPSI data splitted in cast + T,S,P from the ctd (from EPSI_create_profile)
% .     tscan
% . length in second of the scan (piece of the profile)
% .     f
% . frequency array on wich you will 
% .     fmax
%  
%  output:
% . MS=
%  indscan: {1×237 cell} :  indexes of 3s scan from profile 
%        nbscan: 237 => number of scans
%          fmax: 45 => hard cut off frequency
%     nbchannel: 7 => number of channels
%             w: [1×237 double] => vertical speed per scan
%             t: [1×237 double] => temperature per scan
%             s: [1×237 double] => salinity per scan
%            pr: [1×237 double] => pressure per scan
%          kvis: [237×1 double] => kinematic viscosity per scan
%         ktemp: [237×1 double] => diffusivity per scan
%             f: [1×485 double] => frequency array
%             k: [1×1201 double] => Vertical wavenumber array
%            Pf: [7×237×485 double]: Frequency spectra per scan and channels 
%          kmax: [1×237 double]=> dynamic cut off frequency per scan
%       PphiT_k: [237×1201×2 double] => T? gradiant wavenumber spectra 
%      Pshear_k: [237×1201×2 double] => shear wavenumber spectra
%      Paccel_k: [237×1201×3 double]=>acceleration wavenumber spectra
%       epsilon: [237×2 double]: epsilon profiles
%            kc: [237×2 double]=>
%          Ppan: [237×1201×2 double]=> Panchev spectra
%      fc_index: [237×2 double]=> dynmic cut off for T? spectra
%           chi: [237×2 double]=>chi profile
% 



%
%  Created by Arnaud Le Boyer on 7/28/18.

%% get channels
channels=Meta_Data.PROCESS.channels;
nb_channels=length(channels);
%% Gravity  ... of the situation :)
G       = 9.81;

%% Length of the Profile
T       = length(Profile.epsitime);
df      = f(1);
%% define number of scan in the profile
Lscan   = tscan*2*f(end);
nbscan  = floor(T/Lscan);

%% we compute spectra on scan with 50% overlap
nbscan=2*nbscan-1;

%% define the fall rate of the Profile. 
%  Add Profile.w with w the vertical vel. 
%  We are using the pressure from other sensors (CTD);
switch Meta_Data.vehicle
    case 'FISH'
        Profile = compute_fallrate_downcast(Profile);
    case 'WW'
        Profile = compute_speed_upcast(Profile);
        Profile.w=-Profile.w/1e7;
end
All_channels=fields(Profile);
%%
Profile=structfun(@(x) x(:),Profile,'un',0);
%% define the index in the profile for each scan
total_indscan = arrayfun(@(x) (1+floor(Lscan/2)*(x-1):1+floor(Lscan/2)*(x-1)+Lscan-1),1:nbscan,'un',0);
total_w       = cellfun(@(x) nanmean(Profile.w(x)),total_indscan); 

% make sure that we are using fast enough scans
ind_downcast = find((total_w)>.20);
nbscan=length(ind_downcast);

% start creating the MS structure
% get index of the EPSI time series defing each scans
MS.indscan   = total_indscan(ind_downcast);
% get nb of scans in the profile
MS.nbscan    = nbscan;
MS.fmax      = fmax; % arbitrary cut off frequency usually extract from coherence spectra shear/accel 
MS.nbchannel = nb_channels;

% compute mean values of T,S,P,time of each scans 
MS.w       = cellfun(@(x) nanmean(Profile.w(x)),total_indscan(ind_downcast)); 
MS.t       = cellfun(@(x) nanmean(Profile.T(x)),total_indscan(ind_downcast)); % needed to compute Kvis 
MS.s       = cellfun(@(x) nanmean(Profile.S(x)),total_indscan(ind_downcast)); % needed to compute Kvis 
MS.pr      = cellfun(@(x) nanmean(Profile.P(x)),total_indscan(ind_downcast)); % needed to compute Kvis 
MS.time    = cellfun(@(x) nanmean(Profile.epsitime(x)),total_indscan(ind_downcast)); % needed to compute Kvis 

% split time serie to make data matrice
data=zeros(nb_channels,nbscan,Lscan);
for c=1:length(All_channels)
    wh_channels=All_channels{c};
    ind=find(cellfun(@(x) strcmp(x,wh_channels),channels));
    switch wh_channels
        case {'t1','t2','s1','s2'}
            data(ind,:,:) = cell2mat(cellfun(@(x) Profile.(wh_channels)(x),MS.indscan,'un',0)).';
        case {'a1','a2','a3'}
            data(ind,:,:) = cell2mat(cellfun(@(x) Profile.(wh_channels)(x),MS.indscan,'un',0)).';
    end
end

% compute kinematic viscosity
MS.kvis=nu(MS.s,MS.t,MS.pr);
MS.ktemp=kt(MS.s,MS.t,MS.pr).';



% Profile Power and Co spectrum and Coherence. (Coherence still needs to be averaged over few scans afterwork)
[f1,~,P11,Co12]=mod_epsi_get_profile_spectrum(data,f);
%TODO comment on the Co12 sturcutre and think about reducing the size of
%the Coherence spectra (doublon)

% get 1 sided spectra
indf1=find(f1>=0);
indf1=indf1(1:end-1);
f1=f1(indf1);
Lf1=length(indf1);
Co12=Co12(:,:,:,indf1);
P11= P11(:,:,indf1);

%% do  coherence calculation here, get  a correction factor to  applya bit lower down

% get index of the channels (usefull when the number of channels is not 8)
indt1=find(cellfun(@(x) strcmp(x,'t1'),channels));
indt2=find(cellfun(@(x) strcmp(x,'t2'),channels));
inds1=find(cellfun(@(x) strcmp(x,'s1'),channels));
inds2=find(cellfun(@(x) strcmp(x,'s2'),channels));
inda1=find(cellfun(@(x) strcmp(x,'a1'),channels));
inda2=find(cellfun(@(x) strcmp(x,'a2'),channels));
inda3=find(cellfun(@(x) strcmp(x,'a3'),channels));

nsmooth=15; %how many points to smooth over for  covariance

% set coheence correction
    if ~isempty(inda1);a1f=smoothdata(squeeze(P11(inda1,:,:)),'movmean',nsmooth);
    else;a1f=0.*squeeze(P11(1,:,:));end
    if ~isempty(inda2);a2f=smoothdata(squeeze(P11(inda2,:,:)),'movmean',nsmooth);
    else;a2f=0.*squeeze(P11(1,:,:));end
    if ~isempty(inda3);a3f=smoothdata(squeeze(P11(inda3,:,:)),'movmean',nsmooth);
    else;a3f=0.*squeeze(P11(1,:,:));end

if ~isempty(inds1)
    s1=squeeze(P11(inds1,:,:));
    s1f=smoothdata(s1,'movmean',nsmooth);
    if ~isempty(inda3);Cos1a3=squeeze(Co12(inds1,inda3-1,:,:));
    else;Cos1a3=0.*s1f;end
    if ~isempty(inda2);Cos1a2=squeeze(Co12(inds1,inda2-1,:,:));
    else;Cos1a2=0.*s1f;end
    if ~isempty(inda1);Cos1a1=squeeze(Co12(inds1,inda1-1,:,:));
    else;Cos1a1=0.*s1f;end
        
    Cos1a3=abs(smoothdata(Cos1a3,'movmean',nsmooth)).^2./s1f./a3f;
    Cos1a2=abs(smoothdata(Cos1a2,'movmean',nsmooth)).^2./s1f./a2f;
    Cos1a1=abs(smoothdata(Cos1a1,'movmean',nsmooth)).^2./s1f./a1f;
    Cos1tot=max(cat(3,Cos1a1,Cos1a2,Cos1a3),[],3);
    %%Cos1tot=sqrt(Cos1a3.^2+Cos1a2.^2+Cos1a1.^2);
    ib=find(Cos1tot>1);  Cos1tot(ib)=1;  %TEMPTEMPTEMP fix
%    s1=s1.*(1-Cos1tot);
    
    if any(Cos1tot>1)
        disp('coucou')
    end
    
    

end
if ~isempty(inds2)
    s2=squeeze(P11(inds2,:,:));
    s2f=smoothdata(s2,'movmean',nsmooth);
    if ~isempty(inda3);Cos2a3=squeeze(Co12(inds2,inda3-1,:,:));
    else;Cos2a3=0.*s1f;end
    if ~isempty(inda2);    Cos2a2=squeeze(Co12(inds2,inda2-1,:,:));
    else;Cos2a2=0.*s1f;end
    if ~isempty(inda1); Cos2a1=squeeze(Co12(inds2,inda1-1,:,:));
    else;Cos2a1=0.*s1f;end
    Cos2a3=abs(smoothdata(Cos2a3,'movmean',nsmooth)).^2./s2f./a3f;
    Cos2a2=abs(smoothdata(Cos2a2,'movmean',nsmooth)).^2./s2f./a2f;
    Cos2a1=abs(smoothdata(Cos2a1,'movmean',nsmooth)).^2./s2f./a1f;
    Cos2tot=max(cat(3,Cos2a1,Cos2a2,Cos2a3),[],3);
    %%Cos1tot=sqrt(Cos1a3.^2+Cos1a2.^2+Cos1a1.^2);
    ib=find(Cos2tot>1);  Cos2tot(ib)=1;  %TEMPTEMPTEMP fix
end

%% multiply by 2 because we use 1 sided spectra
P11= 2*P11;
P11_temp=0.*P11(1:2,:,:);
P11_shear=0.*P11(1:2,:,:);

%% get MADRE filters
h_freq=get_filters_MADRE(Meta_Data,f1);

%%  get Sv for shear
Sv = [Meta_Data.epsi.s1.Sv,Meta_Data.epsi.s2.Sv];% 
% Sensitivity of probe, nominal
dTdV(1)=Meta_Data.epsi.t1.dTdV; % define in mod_epsi_temperature_spectra
dTdV(2)=Meta_Data.epsi.t2.dTdV; % define in mod_epsi_temperature_spectra 

%% compute fpo7 filters (they are speed dependent)
Emp_Corr_fac=1;
TFtemp=cell2mat(cellfun(@(x) h_freq.FPO7(x),num2cell(MS.w(:)),'un',0));

% apply transfer function and calibraiton coeficient to convert Volt^2 into
% physical spectra
for c=1:length(All_channels)
    wh_channels=All_channels{c};
    ind=find(cellfun(@(x) strcmp(x,wh_channels),channels));
    switch wh_channels
        case{'a1','a2','a3'}
            % correct transfert functions for accel spectra
            P11(ind,:,:)=squeeze(P11(ind,:,:))./...
                (ones(nbscan,1)*h_freq.electAccel(:).');
        case{'s1'}
            TF1 =@(x) (Sv(1).*x/(2*G)).^2 .* h_freq.shear .* haf_oakey(f1,x);     
            TFshear=cell2mat(cellfun(@(x) TF1(x),num2cell(MS.w(:)),'un',0));
            P11_shear(1,:,:) = squeeze(P11(ind,:,:)); % keep Volt spectrum for noise check
            P11(ind,:,:)     = squeeze(P11(ind,:,:)) ./ TFshear;      % vel frequency spectra m^2/s^-2 Hz^-1
      case{'s2'}
            TF1 =@(x) (Sv(2).*x/(2*G)).^2 .* h_freq.shear .* haf_oakey(f1,x);     
            TFshear=cell2mat(cellfun(@(x) TF1(x),num2cell(MS.w(:)),'un',0));
            P11_shear(2,:,:) = squeeze(P11(ind,:,:)); % keep Volt spectrum for noise check
            P11(ind,:,:) = squeeze(P11(ind,:,:)) ./ TFshear;      % vel frequency spectra m^2/s^-2 Hz^-1
        case{'t1','t2'}
            if strcmp(wh_channels,'t1')
                ind_dTdV=1;
                P11_temp(1,:,:) = squeeze(P11(ind,:,:)); % keep Volt spectrum for FPO7_cutoff 
            else
                ind_dTdV=2;
                P11_temp(2,:,:) = squeeze(P11(ind,:,:)); % keep Volt spectrum for FPO7_cutoff 
            end
            P11(ind,:,:) = Emp_Corr_fac * squeeze(P11(ind,:,:)).*dTdV(ind_dTdV).^2./TFtemp; % Temperature frequency C^2 Hz^-1 
    end
end


%% now apply coherence correction
s1=squeeze(P11(inds1,:,:)); s1=s1.*(1-Cos1tot);
s2=squeeze(P11(inds2,:,:)); s2=s2.*(1-Cos2tot);
Ps1k=s1;
Ps2k=s2;


%%
% convert frequency to wavenumber
k=cell2mat(cellfun(@(x) f1/x, num2cell(MS.w(:)),'un',0));
dk=cell2mat(cellfun(@(x) df/x, num2cell(MS.w(:)),'un',0));

% create a common vertical wavenumber axis. 
dk_all=nanmin(nanmean(diff(k,1,2),2));
k_all=nanmin(k(:)):dk_all:nanmax(k(:));
Lk_all=length(k_all);

% temperature, vel and accell spec as function of k
P11k  = P11.* shiftdim(repmat(ones(nb_channels,1)*MS.w(:).',[1,1,Lf1]),3);   

% Very usefull to debug but some fileds are not necessary.
% TODO: see how to reduce the number of field on the MS structure probably
% start with this one
MS.f   = f1;
MS.k   = k_all;
MS.Pf  = P11;
MS.Co12 = Co12;

% Set kmax for integration to highest bin below pump spike,
% which is between 49 and 52 Hz in a 1024-pt spectrum
MS.kmax=MS.fmax./MS.w(:); % Lowest estimate below pump spike in 1024-pt record




% Profile.Pf(3,:,:)=s1c;
% Profile.Pf(4,:,:)=s2c;





% get FPO7 channel average noise to compute chi
switch Meta_Data.MAP.temperature
    case 'Tdiff'
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
    otherwise
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
end

% calc epsilon by integrating to k with 90% variance of Panchev spec
% unless spectrum is noisy at lower k.
% Check that data window > 0.5 m, as needed for initial estimate
MS.PphiT_k=zeros(nbscan,Lk_all,2).*nan;
MS.Pshear_k=zeros(nbscan,Lk_all,2).*nan;

% % movie stuff
if dsp==1
    % % movie stuff
    v = VideoWriter(sprintf('%s_rawcast%i%s',Meta_Data.deployment,i,'.avi'));
    v.FrameRate=5;
    open(v)
    
    n0=FPO7noise.n0; n1=FPO7noise.n1; n2=FPO7noise.n2; n3=FPO7noise.n3;
    logf=log10(f1);
    noise=n0+n1.*logf+n2.*logf.^2+n3.*logf.^3;
    shearnoise=load(fullfile(Meta_Data.CALIpath,'shear_noise.mat'),'n0s','n1s','n2s','n3s');
    n0s=shearnoise.n0s; n1s=shearnoise.n1s; n2s=shearnoise.n2s; n3s=shearnoise.n3s;
    snoise=n0s+n1s.*logf+n2s.*logf.^2+n3s.*logf.^3;
    close all
    figure(10)
    set(gcf,'Position',[100 100 1000 1000])
    ax(1)=axes('Position',[.1 .52 .8 .27]);
    ax(3)=axes('Position',[.1 .83 .8 .08]);
    ax(2)=axes('Position',[.1 .06 .8 .27]);
    ax(4)=axes('Position',[.1 .36 .8 .08]);
    
    smin=-.03;smax=.03;
    tmin=-3e-4;tmax=3e-4;
end

% compute shear and temperature gradient. Get chi and epsilon values
% TODO: we do not need kall. 

for j=1:nbscan
    fprintf('scan %i over %i \n',j,nbscan)
    % compute gradient
    if ~isempty(indt1)
        MS.PphiT_k(j,:,1)  = (2*pi*k_all).^2 .* interp1(k(j,:),squeeze(P11k(indt1,j,:)),k_all);        % T1_k spec  as function of k
    end
    if ~isempty(indt2)
        MS.PphiT_k(j,:,2)  = (2*pi*k_all).^2 .* interp1(k(j,:),squeeze(P11k(indt2,j,:)),k_all);        % T2_k spec  as function of k
    end
    if ~isempty(inds1)
        MS.Pshear_k(j,:,1) = (2*pi*k_all).^2 .* interp1(k(j,:),squeeze(P11k(inds1,j,:)),k_all);        % shear spec  as function of k
        MS.Pshearco_k(j,:,1) = (2*pi*k_all).^2 .* interp1(k(j,:),squeeze(Ps1k(j,:)),k_all);        % shear spec  as function of k
    end
    if ~isempty(inds2)
        MS.Pshear_k(j,:,2) = (2*pi*k_all).^2 .* interp1(k(j,:),squeeze(P11k(inds2,j,:)),k_all);        % shear spec  as function of k
        MS.Pshearco_k(j,:,2) = (2*pi*k_all).^2 .* interp1(k(j,:),squeeze(Ps2k(j,:)),k_all);        % shear spec  as function of k
    end
    % compute epsilon 1 in eps1_mmp
    if ~isempty(inds1) % if spectrum is all nan
        if all(isnan(squeeze(P11k(inds1,j,:))))
            MS.Ppan(j,:,1)=nan.*k_all;
            MS.epsilon(j,1)=nan;
            MS.kc(j,1)=nan;
        else
            [MS.epsilon(j,1),MS.kc(j,1)]=eps1_mmp(k_all,MS.Pshear_k(j,:,1),MS.kvis(j),dk_all,MS.kmax(j)); 
            [MS.epsilon_co(j,1),MS.kc_co(j,1)]=eps1_mmp(k_all,MS.Pshearco_k(j,:,1),MS.kvis(j),dk_all,MS.kmax(j)); 
            [kpan,Ppan] = panchev(MS.epsilon(j,1),MS.kvis(j));
            MS.Ppan(j,:,1)=interp1(kpan,Ppan,k_all);
        end
    end
    % compute epsilon 2 in eps1_mmp
    if ~isempty(inds2) % if spectrum is all nan
        if all(isnan(squeeze(P11k(inds2,j,:))))
            MS.Ppan(j,:,1)=nan.*k_all;
            MS.epsilon(j,2)=nan;
            MS.kc(j,2)=nan;
        else
            [MS.epsilon(j,2),MS.kc(j,2)]=eps1_mmp(k_all,MS.Pshear_k(j,:,2),MS.kvis(j),dk_all,MS.kmax(j));
            [MS.epsilon_co(j,2),MS.kc_co(j,2)]=eps1_mmp(k_all,MS.Pshearco_k(j,:,2),MS.kvis(j),dk_all,MS.kmax(j)); 
            [kpan,Ppan] = panchev(MS.epsilon(j,2),MS.kvis(j));
            MS.Ppan(j,:,2)=interp1(kpan,Ppan,k_all);
        end
    end
    
    % compute chi 1. get frequency cutoff in  FPO7_cutoff
     if ~isempty(indt1)
        if all(isnan(squeeze(P11_temp(1,j,:))))  % if spectrum is all nan 
            MS.chi(j,1)=nan;
            MS.fc_index(j,1)=nan;
        else
            MS.fc_index(j,1)=FPO7_cutoff(f1,squeeze(P11_temp(1,j,:)).',FPO7noise);
            MS.kcfpo7(j,1)=k_all(find(k_all<=k(j,MS.fc_index(j,1)),1,'last'));
            krange=find(k_all<=k(j,MS.fc_index(j,1)));
            MS.chi(j,1)=6*MS.ktemp(j)*dk_all.*nansum(MS.PphiT_k(j,krange,1));
            MS.flag(j,1)=MS.fc_index(j,1)<round(Lf1*.95);
        end
    end
    % compute chi 2. get frequency cutoff in  FPO7_cutoff
    if ~isempty(indt2)
        if all(isnan(squeeze(P11_temp(2,j,:))))  % if spectrum is all nan
            MS.chi(j,2)=nan;
            MS.fc_index(j,2)=nan;
        else
            MS.fc_index(j,2)=FPO7_cutoff(f1,squeeze(P11_temp(2,j,:)).',FPO7noise);
            MS.kcfpo7(j,2)=k_all(find(k_all<=k(j,MS.fc_index(j,2)),1,'last'));
            krange=find(k_all<=k(j,MS.fc_index(j,2)));
            MS.chi(j,2)=6*MS.ktemp(j)*dk_all.*nansum(MS.PphiT_k(j,krange,2));
            MS.flag(j,2)=MS.fc_index(j,2)<round(Lf1*.95);
        end
    end

    
    % movie stuff
    if (dsp==1 && all(~isnan([MS.chi(j,1) MS.chi(j,2) MS.epsilon(j,1) MS.epsilon(j,2)])) )
        
        
        loglog(ax(1),f1,squeeze(P11_temp(1,j,:)),'r')
        hold(ax(1),'on')
        loglog(ax(1),f1,squeeze(P11_temp(2,j,:)),'b')
        if ~isempty(indt1)
            loglog(ax(1),f1(1:MS.fc_index(j,1)),squeeze(P11_temp(1,j,1:MS.fc_index(j,1))),'c')
        else
            loglog(ax(1),f1(1:MS.fc_index(j,2)),squeeze(P11_temp(2,j,1:MS.fc_index(j,2))),'c')
        end
        loglog(ax(1),f1,10.^noise,'k')
        ylim(ax(1),[1e-15 1e-5])
        xlim(ax(1),f1([1 end]))
        hold(ax(1),'off')
        ylabel(ax(1),'t_{1,2} (V^2/Hz)','fontsize',20)
        set(ax(1),'fontsize',15)
        legend(ax(1),'t1 raw','t2','t1 signal','MADRE noise','location','southwest')
        set(ax(1),'Xscale','log','Yscale','log')
        grid(ax(1),'on')       
        lab={};
        if ~isempty(indt1)
            plot(ax(3),(MS.indscan{j}-MS.indscan{j}(1))/320,detrend(squeeze(data(indt1,j,:))),'r');
            lab{1}='t1';
        end
        hold(ax(3),'on')
        if ~isempty(indt2)
            plot(ax(3),(MS.indscan{j}-MS.indscan{j}(1))/320,detrend(squeeze(data(indt2,j,:))),'b');
            lab{2}='t2';
        end
        hold(ax(3),'off')
        legend(ax(3),lab(cellfun(@(x) ~isempty(x),lab)))
        xlabel(ax(3),'s' ,'fontsize',20)
        ylabel(ax(3),'V' ,'fontsize',20)
        ylim(ax(3),[tmin tmax])
        title(ax(3),{'raw Temperature', ...
            sprintf(' %s %s Cast %i ',Meta_Data.mission,Meta_Data.deployment,i)}, ...
                   'fontsize',20)
        
  
               
        loglog(ax(2),f1,squeeze(P11_shear(1,j,:)),'r')
        hold(ax(2),'on')
        loglog(ax(2),f1,squeeze(P11_shear(2,j,:)),'b')
        ind_s1=find(k(j,:)<MS.kc(j,1));
        loglog(ax(2),f1(ind_s1),squeeze(P11_shear(1,j,ind_s1)),'c')
%         ind_s2=find(k(j,:)<MS.kc(j,1));
%         loglog(ax(2),f1(ind_s2),squeeze(P11_shear(2,j,ind_s2)),'b')
        loglog(ax(2),f1,10.^snoise,'k')
        ylim(ax(2),[1e-15 1e-1])
        xlim(ax(2),f1([1 end]))
        hold(ax(2),'off')
        set(ax(2),'Xscale','log','Yscale','log')
        ylabel(ax(2),'s_{1,2} (V^2/Hz)','fontsize',20)
        xlabel(ax(2),'Hz' ,'fontsize',20)
        set(ax(2),'fontsize',15)
        legend(ax(2),'s1 raw','s2','s1 signal','MADRE noise','location','southwest')
        grid(ax(2),'on')       

        plot(ax(4),(MS.indscan{j}-MS.indscan{j}(1))/320,detrend(squeeze(data(inds1,j,:))),'r')
        hold(ax(4),'on')
        plot(ax(4),(MS.indscan{j}-MS.indscan{j}(1))/320,detrend(squeeze(data(inds2,j,:))),'b')
        hold(ax(4),'off')
        legend(ax(4),{'s1','s2'})
        title(ax(4),'raw Shear','fontsize',20)
        xlabel(ax(4),'s' ,'fontsize',20)
        ylim(ax(4),[smin smax])
        ylabel(ax(4),'V' ,'fontsize',20)

        
        pause(.1)
        frame=getframe(gcf);
        writeVideo(v,frame)
        cla(ax(3))
        cla(ax(4))
    end
    % movie stuff
end
if dsp==1
    close(v)
end



