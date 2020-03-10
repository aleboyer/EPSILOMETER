function [H,fH]=create_velocity_tranfer_function(scans,Meta_Data,df)
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
if narg<2
    df=325;
end

Sv1=Meta_Data.epsi.s1.Sv;
Sv2=Meta_Data.epsi.s2.Sv;
G = 9.81; %accel due to gravity


%%
for n=1:Nscans
    nfft=ceil(length(scans{n}.s1)/3); %window length
    TF=zeros(Nscans,ceil(nfft/2)+1);
    w=scans{n}.w;
    u1=scans{n}.s1.*2.*9.81./(Sv1.*scans{n}.w); %Gregg
    u2=scans{n}.s2.*2.*9.81./(Sv2.*scans{n}.w); %Gregg
    du1dt=diff(u1)*df;
    du2dt=diff(u2)*df;
    s1=du1dt./w; %Shear from velocity
    s2=du2dt./w; %Shear from velocity
    
    a3 = scans{n}.a3;
    [Pa3,~] = pwelch(detrend(a3),nfft,[],nfft,df,'psd');
    [Pu1,~] = pwelch(detrend(u1),nfft,[],nfft,df,'psd');
    [Pu2,~] = pwelch(detrend(u2),nfft,[],nfft,df,'psd');

    [Ps1,~] = pwelch(detrend(s1),nfft,[],nfft,df,'psd');
    [PE1,fe] = pwelch(detrend(E1),nfft,[],nfft,df,'psd');
    
    [Cu1a3,fCe] = mscohere(detrend(u1),detrend(a3),nfft,[],nfft,df);
    Pu1p=Pu1.*(1-Cu1a3);
    [PCu1a3,~]=cpsd(detrend(u1p),detrend(u1),nfft,[],nfft,df);
    
    h_freq=get_filters_MADRE(Meta_Data,fe);
    TF1 =@(x) (Sv1.*x/(2*G)).^2 .* h_freq.shear .* haf_oakey(fe,w);
    TFvel  = cell2mat(cellfun(@(x) TF1(x),num2cell(w),'un',0).').';
    Pvel   = PE1./squeeze(TFvel)';
    ke=fe/w;
    Pshear = Pvel(:,n).*(2*pi*ke(:,n)).^2;
    TF(n,:)=abs(PCu1a3)./Pa3;
    TF_coh=sqrt(Cu1a3(:,1).*Pu1(:,1)./Pa3(:,1));
    
    close all
    loglog(fe,Pa3,'r','linewidth',3)
    hold on
    loglog(fe,Pu1,'g','linewidth',3)
    loglog(fe,Pu1p,'b','linewidth',3)
    loglog(fe,TF(1,:).*Pa3','k','linewidth',1) % this should match exactly u1 
    loglog(fe,TF_coh.*Pa3,'m','linewidth',1)
    
    
end
H=smoothdata(nanmean(TF,1),'movmean',3);
fH=fCe;
%%
% loglog(fCe,H)
%


