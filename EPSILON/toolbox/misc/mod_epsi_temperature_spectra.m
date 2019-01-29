function mod_epsi_temperature_spectra(Meta_Data,EPSI_Profile,CTD_Profile,titre,np,dsp,tscan,ctd_df)

%tscan=(CTD_Profile.ctdtime(end)-CTD_Profile.ctdtime(1))*86400;
epsi_df=325;
%ctd_df=16; % SBE
%ctd_df=6; % RBR

epsi_Lscan  = tscan*epsi_df; % epsi sampling frequency is 
ctd_Lscan   = tscan*ctd_df;
epsi_T      = length(EPSI_Profile.epsitime);
ctd_T       = length(CTD_Profile.ctdtime);

dTdV=[Meta_Data.epsi.t1.dTdV Meta_Data.epsi.t2.dTdV];

CTD_Profile=structfun(@(x) x(:),CTD_Profile,'un',0);

fprintf('epsi time series %3.2f seconds.\n',epsi_T/epsi_df)
fprintf('ctd time series %3.2f seconds.\n',ctd_T/ctd_df)

nbscan  = floor(epsi_T/epsi_Lscan);

epsi_k=make_kaxis(tscan,epsi_df);
ctd_k=make_kaxis(tscan,ctd_df);

CTD_Profile.w = smoothdata([diff(CTD_Profile.P(:))./diff(CTD_Profile.ctdtime(:)*86400) ;nan],...
                           'movmean',10);

% we compute spectra on scan with 50% overlap

nbscan=2*nbscan-1;
epsi_indscan = arrayfun(@(x) (1+floor(epsi_Lscan/2)*(x-1):1+floor(epsi_Lscan/2)*(x-1)+epsi_Lscan-1),1:nbscan,'un',0);
ctd_indscan = arrayfun(@(x) (1+floor(ctd_Lscan/2)*(x-1):1+floor(ctd_Lscan/2)*(x-1)+ctd_Lscan-1),1:nbscan,'un',0);
clear data_CTD
data_CTD = cell2mat(cellfun(@(x) CTD_Profile.T(x),ctd_indscan,'un',0)).';
P11_ctd=alb_power_spectrum(data_CTD,1./tscan);


P11_epsi=zeros(2,nbscan,int32(epsi_Lscan));
indt1=find(cellfun(@(x) strcmp(x,'t1'),Meta_Data.PROCESS.channels));
indt2=find(cellfun(@(x) strcmp(x,'t2'),Meta_Data.PROCESS.channels));
if ~isempty(indt1)
    EPSI_Profile.t1=fillmissing(EPSI_Profile.t1,'linear');
    EPSI_Profile.t1=filloutliers(EPSI_Profile.t1,'center','movmedian',1000);
    
    data_EPSI(indt1,:,:) = cell2mat(cellfun(@(x) filloutliers( ...
                EPSI_Profile.t1(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
    P11_epsi(indt1,:,:)=alb_power_spectrum(squeeze(data_EPSI(indt1,:,:)),1./tscan);
end
if ~isempty(indt2)
    EPSI_Profile.t2=fillmissing(EPSI_Profile.t2,'linear');
    EPSI_Profile.t2=filloutliers(EPSI_Profile.t2,'center','movmedian',1000);

    data_EPSI(indt2,:,:) = cell2mat(cellfun(@(x) filloutliers( ...
        EPSI_Profile.t2(x),'center','movmedian',5),...
              epsi_indscan,'un',0)).';
    P11_epsi(indt2,:,:)=alb_power_spectrum(squeeze(data_EPSI(indt2,:,:)),1./tscan);
end
w=cellfun(@(x) median(CTD_Profile.w(x)),ctd_indscan);


ctd_indk=find(ctd_k>=0);
ctd_indk=ctd_indk(1:end-1);
ctd_k=ctd_k(ctd_indk);

epsi_indk=find(epsi_k>=0);
epsi_indk=epsi_indk(1:end-1);
epsi_k=epsi_k(epsi_indk);


P11_ctd  = 2*squeeze(P11_ctd(:,ctd_indk));
P11_epsi = 2*squeeze(P11_epsi(:,:,epsi_indk));

h_freq=get_filters_MADRE(Meta_Data,epsi_k);
% Sensitivity of probe, nominal
dTdV(1)=Meta_Data.epsi.t1.dTdV; %1/0.018 V/deg  set for Granite t1
dTdV(2)=Meta_Data.epsi.t2.dTdV; % weird value to matrch granite t1
% compute fpo7 filters (they are speed dependent)
TFtemp=cell2mat(cellfun(@(x) h_freq.FPO7(x),num2cell(w),'un',0).');

if ~isempty(indt1)
P11_TFepsi(indt1,:,:)=squeeze(P11_epsi(indt1,:,:))*dTdV(1).^2./TFtemp;
P11_T(indt1,:) = squeeze(nanmean(P11_TFepsi(indt1,:,:),2)); % Temperature gradient frequency spectra should be ?C^2/s^-2 Hz^-1 ????
end
if ~isempty(indt2)
P11_TFepsi(indt2,:,:)=squeeze(P11_epsi(indt2,:,:))*dTdV(2).^2./TFtemp;
P11_T(indt2,:) = squeeze(nanmean(P11_TFepsi(indt2,:,:),2)); % Temperature gradient frequency spectra should be ?C^2/s^-2 Hz^-1 ???? 
end


P11_Tctd = nanmean(P11_ctd);
%P11_Tctd = P11_ctd;
A=squeeze(nanmean(P11_epsi(1,:,:),2)).*dTdV(1).^2;
B=squeeze(nanmean(P11_epsi(1,:,:),2)).*dTdV(1).^2./h_freq.electFPO7.'.^2;

switch Meta_Data.MAP.temperature
    case 'Tdiff'
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
    otherwise
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
end
n0=FPO7noise.n0; n1=FPO7noise.n1; n2=FPO7noise.n2; n3=FPO7noise.n3;
logf=log10(epsi_k);
noise=10.^(n0+n1.*logf+n2.*logf.^2+n3.*logf.^3).*dTdV(1).^2;


%
close all
hold on
loglog(ctd_k,P11_Tctd,'r','linewidth',2)
loglog(epsi_k,noise,'m','linewidth',2)
%loglog(epsi_k,10.^(mmp_noise).*dTdV(1).^2,'m--','linewidth',2)
loglog(epsi_k,A,'Color',.6* [1 1 1],'linewidth',2)
loglog(epsi_k,B,'Color',.4* [1 1 1],'linewidth',2)
if ~isempty(indt1)
    loglog(epsi_k,P11_T(indt1,:),'c','linewidth',2)
end
if ~isempty(indt2)
    loglog(epsi_k,P11_T(indt2,:),'Color',.1* [1 1 1],'linewidth',2)
end

set(gca,'XScale','log','YScale','log')
xlabel('Hz','fontsize',20)
ylabel('C^2/Hz','fontsize',20)
titre=sprintf('%s cast %i - temperature',titre,np);
title(titre,'fontsize',20)
legend('SBE49','noise','raw','t1./TF_{elec}','t1','t2','location','southwest')
grid on
ylim([1e-13 1])
xlim([1/15 170])
set(gca,'fontsize',20)

filename=sprintf('%sTctd_Tepsi_comp_cast%i_t%i.png',Meta_Data.L1path,np,1);
print('-dpng2',filename)
if dsp==1
    ind_t=1;
    for i=1:nbscan
        close all
        A=squeeze(P11_epsi(ind_t,i,:)).*dTdV(ind_t).^2;
        B=squeeze(P11_epsi(ind_t,i,:)).*dTdV(ind_t).^2./h_freq.electFPO7.'.^2;
        loglog(epsi_k,A,'c')
        hold on
        loglog(epsi_k,10.^(noise).*dTdV(ind_t).^2,'m','linewidth',2)
        loglog(epsi_k,10.^(mmp_noise).*dTdV(ind_t).^2,'m--','linewidth',2)
        %loglog(epsi_k,A,'Color',.6* [1 1 1],'linewidth',2)
        %loglog(epsi_k,B,'Color',.4* [1 1 1],'linewidth',2)
        loglog(epsi_k,squeeze(P11_TFepsi(1,i,:)),'r','linewidth',2)
        loglog(ctd_k,P11_ctd(i,:),'k')
        set(gca,'XScale','log','YScale','log')
        legend('t1 raw','noise',' mmp noise','t1','SBE')
        xlabel('Hz','fontsize',20)
        ylabel('C^2/Hz','fontsize',20)
        title(titre,'fontsize',20)
        set(gca,'fontsize',20)
        ylim([1e-13 1])
        xlim([1/15 170])
        grid on
        pause
    end
close all
end


