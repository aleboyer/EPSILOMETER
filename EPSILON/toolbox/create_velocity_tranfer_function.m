function [H1,H2,fH]=create_velocity_tranfer_function(scans,Meta_Data,df)
% Create a transfer function using the Cross spectrum of u (from shear probes)
% and a3 or a1 ( it depends which axes influence most the shear probes).
% Turbulence_scans are raw spectra and time series from a single deployment
% with the lowest measured epsilon. It will serve to define the minimal noise floor 
% and the shape of the noise we can remove from every others scans. 
% The number of scans is undefined (user's discretion).
% 
%
% code inspired by Bethan Wynne-Cattanach's code
% written by Arnaud Le Boyer 02/06/2020.

Nscans=length(scans);
if nargin<2
    df=325;
end

Sv1=Meta_Data.epsi.s1.Sv;
Sv2=Meta_Data.epsi.s2.Sv;
G=9.81;
twoG =2*G; %ael due to gravity


%%
for n=1:Nscans
    nfft=ceil(length(scans{n}.s1)/3); %window length
    if mod(nfft,2)==0
        TF=zeros(Nscans,ceil(nfft/2)+1);
    else
        TF=zeros(Nscans,ceil(nfft/2));
    end
    
%     u1=scans{n}.s1.*twoG./(Sv1.*scans{n}.w); %Gregg
%     u2=scans{n}.s2.*twoG./(Sv2.*scans{n}.w); %Gregg
    u1=scans{n}.s1; %attention s1 is actually in m/s. Change was done in mod_som_make_scan_v2
    u2=scans{n}.s2; %attention s2 is actually in m/s. Change was done in mod_som_make_scan_v2
    a3 = scans{n}.a3;%attention a3 is actually in m/s^2. Change was done in mod_som_make_scan_v2
    [Pa3,fe] = pwelch(detrend(a3),nfft,[],nfft,df,'psd');
    [PCu1a3,~]=cpsd(detrend(u1),detrend(a3),nfft,[],nfft,df);
    [PCu2a3,~]=cpsd(detrend(u2),detrend(a3),nfft,[],nfft,df);
    TF1(n,:)=abs(PCu1a3)./Pa3;
    TF2(n,:)=abs(PCu2a3)./Pa3;

%     du1dt=diff(u1)*df;
%     du2dt=diff(u2)*df;
%     s1=du1dt./w; %Shear from velocity
%     s2=du2dt./w; %Shear from velocity
    
%     [Pu1,~] = pwelch(detrend(u1),nfft,[],nfft,df,'psd');
%     [Pu2,~] = pwelch(detrend(u2),nfft,[],nfft,df,'psd');

%     [Ps1,~] = pwelch(detrend(s1),nfft,[],nfft,df,'psd');
    
%     [Cu1a3,fCe] = mscohere(detrend(u1),detrend(a3),nfft,[],nfft,df);
%     Pu1p=Pu1.*(1-Cu1a3);
    
%     h_freq=get_filters_MADRE(Meta_Data,fCe);
%     TF1 =@(x) (Sv1.*x/(2*G)).^2 .* h_freq.shear .* haf_oakey(fCe,w);
%     TFvel  = cell2mat(cellfun(@(x) TF1(x),num2cell(w),'un',0).').';
%     Pvel   = Ps1./squeeze(TFvel)';
%     ke=fCe/w;
%     Pshear = Pvel.*(2*pi*ke).^2;
%     TF_coh=sqrt(Cu1a3(:,1).*Pu1(:,1)./Pa3(:,1));
    
%     close all
%     loglog(fCe,Pa3,'r','linewidth',3)
%     hold on
%     loglog(fCe,Pu1,'g','linewidth',3)
%     loglog(fCe,Pu1p,'b','linewidth',3)
%     loglog(fCe,TF(n,:).*Pa3','k','linewidth',5) % this should match exactly u1 
%     loglog(fCe,TF_coh.*Pa3,'m','linewidth',1)
%     title(sprintf('%i',n))
%     legend('Pa3','Pu1','Pu1p','TF','TF_coh')
%     pause
    
    
end
H1=smoothdata(nanmean(TF1,1),'movmean',3);
H2=smoothdata(nanmean(TF2,1),'movmean',3);
fH=fe;
%%
% loglog(fCe,H)
%


