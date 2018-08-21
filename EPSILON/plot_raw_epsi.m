function EPSI_plot_raw(Meta_Data)

root_data = Meta_Data.path_mission;
Cruise_name = Meta_Data.mission;
vehicle_name = Meta_Data.mission;
deployment = 'd1';




pathname = [root_data '/' Cruise_name '/' vehicle_name '/' deployment '/epsi/'];
%readpath= [root_data '/' Cruise_name '/' vehicle_name '/' deployment '/read'];
%tic

%eval(sprintf('! python %s/store_DEV_test_env_d6.py',readpath))
%i=0
%while (i<1000)
%    i=i+1;
%end

x = dir([pathname '*.mat']);
datefile=[x.datenum];
[~,I]=max(datefile);

filename = x(I).name;
epsi = load([pathname filename]);
disp([pathname filename])

T1 = epsi.t1;
T2 = epsi.t2;
S1 = epsi.s1;
S2 = epsi.s2;
C  = epsi.c;
A1 = epsi.a1;
A2 = epsi.a2;
A3 = epsi.a3;
%EPSItime = epsi.EPSItime/3600/24+datenum(1970,1,1,0,0,0);






dt = 1/325;
tdummy = (1:length(T1))*dt;
%tdummy = EPSItime;
tdummy = epsi.epsitime*3600*24;
dt = (tdummy(2)-tdummy(1))*3600*24;

trange = [0 1e10]; %default
%trange = [datenum( 1200];
%t1 = datenum(2018,07,13, 12,37,00);
%t2 = datenum(2018,07,13, 12,37,10);
%trange = [t1 t2];


idt = find(trange(1) < tdummy & tdummy < trange(2));
if rem(length(idt),2)==1
    idt = idt(1:end-1);
end

T1 = T1(idt);
T2 = T2(idt);
S1 = S1(idt);
S2 = S2(idt);
C  = C(idt);
A1 = A1(idt);
A2 = A2(idt);
A3 = A3(idt);

tdummy = tdummy(idt);





%%% Time Series

sname = [Cruise_name ' / ' vehicle_name ' / ' deployment];
fname = [Cruise_name '_' deployment '_' x(I).name];
id =findstr(fname,'.mat');
fname = fname(1:id-1);
fname = 'jul11_test5_MOTOR';


F = figure(1);clf
set(F,'position',[50 100 1400 850])

h1 = axes('position',[.1 .52 .22 .4]);
plot(tdummy,T1,'k')
title('Temp1')
set(gca,'fontsize',16,'xticklabel','')
grid on
ylabel('Volts')

 

h2 = axes('position',[.1 .08 .22 .4]);
plot(tdummy,T2,'k')
title('Temp2')
set(gca,'fontsize',16)
grid on
ylabel('Volts')


h3 = axes('position',[.38 .52 .22 .4]);
plot(tdummy,S1,'k')
title('Shear1')
set(gca,'fontsize',16,'xticklabel','')
grid on


h4 = axes('position',[.38 .08 .22 .4]);
plot(tdummy,S2,'k')
title('Shear2')
set(gca,'fontsize',16)
grid on
xlabel('time [s]')


h5 = axes('position',[.67 .56 .3 .20]);
plot(tdummy,A1,'k')
title('Acc1')
set(gca,'fontsize',16,'xticklabel','')
grid on


h6 = axes('position',[.67 .32 .3 .20]);
plot(tdummy,A2,'k')
title('Acc2')
set(gca,'fontsize',16,'xticklabel','')
grid on

h7 = axes('position',[.67 .08 .3 .20]);
plot(tdummy,A3,'k')
title('Acc3')
set(gca,'fontsize',16)
grid on
xlabel('time [s]')

h8 = axes('position',[.67 .8 .3 .12]);
plot(tdummy(1:end-1),mod(diff(C),450),'k') % 450 is ramp maximum / length
title('Ramp Diff')
set(gca,'fontsize',16,'xticklabel','')
grid on


linkaxes([h1 h2 h3 h4 h5 h6 h7 h8],'x')

hl = suplabel(sname,'t');
set(hl,'fontsize',20)
%%
%saveas(gcf,['../../' Cruise_name '/' vehicle_name '/' deployment '/figs/raw_ts/' fname],'jpg')


%% COMPUTE SPECTRA
warning off

tscan = 3;

blockid = [1:tscan*dt^-1:length(T1)];

clear St1 St2 Ss1 Ss2 Sa1 Sa2 Sa3
for ii = 1:length(blockid)-1
   iduse = ceil(blockid(ii)):floor(blockid(ii+1));
   
   [f St1(ii,:)] = alb_fastspec(dt,T1(iduse));
   [f St2(ii,:)] = alb_fastspec(dt,T2(iduse));
   [f Ss1(ii,:)] = alb_fastspec(dt,S1(iduse));
   [f Ss2(ii,:)] = alb_fastspec(dt,S2(iduse));
   [f Sa1(ii,:)] = alb_fastspec(dt,A1(iduse));
   [f Sa2(ii,:)] = alb_fastspec(dt,A2(iduse));
   [f Sa3(ii,:)] = alb_fastspec(dt,A3(iduse));
    
    
    
end

%% TEMPERATURE
load /Users/MS/science/EPSILOMETER/EPSILON/toolbox/PLOTS/comparison_temp_granite_sproul.mat
load /Users/MS/science/EPSILOMETER/EPSILON/toolbox/PLOTS/d7_spectra.mat


F = figure(3);clf
set(F,'position',[50 100 1400 850])


dt = 1/320;
fff = pi*f/(f(end)*2);
sinc4 = (sin(fff)./fff).^4;
N = [16 20 24];
bitnoise = (2.5./2.^N).^2./f(end);



h3 = loglog(k_granite,spec_granite,'m','linewidth',2);hold on
h4 = loglog(k_sproul,spec_sproul,'r','linewidth',2);
h7 = loglog(d7.f,d7.T1_spec,'-','linewidth',3,'color',[0 0 1]);

h5 = loglog([1e-1 1e3],[1 1]*bitnoise(1),'k--','linewidth',2);
h6 = loglog([1e-1 1e3],[1 1]*bitnoise(2),'k:','linewidth',2);


h1 = loglog(f,mean(St1),'k','linewidth',3);
h2 = loglog(f,mean(St2),'color',[1 1 1]*.7,'linewidth',3);

legend([h1 h2 h3 h4 h7 h5 h6],{'temp1','temp2','granite','sproul','Maybench','16-bit','20-bit'})

title([sname '  [Temp]'])
grid on
xlim([1e-1 3e2])
ylim([1e-17 1e-6])
set(gca,'fontsize',20)
xlabel('Hz')
ylabel('V^2 / Hz')

%saveas(gcf,['../../' Cruise_name '/' vehicle_name '/' deployment '/figs/raw_temp_spec/' fname],'jpg')


%% SHEAR
load /Users/MS/science/EPSILOMETER/EPSILON/toolbox/PLOTS/comparison_shear_granite_sproul.mat

F = figure(4);clf
set(F,'position',[50 100 1400 850])

N = [16 20 24];
bitnoise = (2.5./2.^N).^2./f(end);

h3 = loglog(k_granite,spec_granite,'m','linewidth',2); hold on
h4 = loglog(k_sproul,spec_sproul,'r','linewidth',2);

h7 = loglog(d7.f,d7.S1_spec,'-','linewidth',3,'color',[0 0 1]);


h1 = loglog(f,mean(Ss1),'k','linewidth',3);hold on
h2 = loglog(f,mean(Ss2),'color',[1 1 1]*.7,'linewidth',3);

h5 = loglog([1e-1 1e3],[1 1]*bitnoise(1),'k--','linewidth',2);
h6 = loglog([1e-1 1e3],[1 1]*bitnoise(2),'k:','linewidth',2);



legend([h1 h2 h3 h4 h7 h5 h6],{'shear1','shear2','granite','sproul','Maybench','16-bit','20-bit'})

title([sname '  [Shear]'])
grid on
xlim([1e-1 3e2])
ylim([1e-15 1e-2])
set(gca,'fontsize',20)
xlabel('Hz')
ylabel('V^2 / Hz')

%saveas(gcf,['../../' Cruise_name '/' vehicle_name '/' deployment '/figs/raw_shear_spec/' fname],'jpg')




%% ACCEL

load /Users/MS/science/EPSILOMETER/EPSILON/toolbox/PLOTS/comparison_accel_granite_sproul.mat


F = figure(5);clf
set(F,'position',[50 100 1400 850])

partnoise = (45e-6)^2*ones(size(f));





h4 = loglog(k_granite,spec_granite,'m','linewidth',2); hold on
h5 = loglog(k_sproul,spec_sproul,'r','linewidth',2);
h7 = loglog(d7.f,d7.A1_spec,'-','linewidth',3,'color',[0 0 1]);


h6 = plot(f,partnoise,'k--');

h1 = loglog(f,mean(Sa1),'k','linewidth',3);
h2 = loglog(f,mean(Sa2),'color',[1 1 1]*.45,'linewidth',3);hold on
h3 = loglog(f,mean(Sa3),'color',[1 1 1]*.75,'linewidth',3);


xlim([1e-1 3e2])
ylim([1e-11 1e-3]) 
legend([h1 h2 h3 h4 h5 h7 h6],{'acc1','acc2','acc3','granite','sproul','Maybench','partnoise'})

%legend([h1 h2 h3 h4 h5 h6],{'shear1','shear2','granite','sproul','16-bit','20-bit'})

%legend([h1 h2 h3 h4 h5 h6],{'a1','a2','a3','granite','sproul','part noise'})
title([sname '  [Acceleration]'])
grid on
set(gca,'fontsize',20)
xlabel('Hz')
ylabel('g^2 / Hz')

%saveas(gcf,['../../' Cruise_name '/' vehicle_name '/' deployment '/figs/raw_acc_spec/' fname],'jpg')


%% COHERENCE

F = figure(8);clf
set(F,'position',[50 0 1200 650])


subplot(211)
[Pxy F] = mscohere(A1,S1,hamming(300),150,300,1/dt);
semilogx(F,Pxy)
title('Coherence S1 & A3')
grid on
set(gca,'fontsize',16)

F = figure(2);clf
set(F,'position',[100 100 900 500])
%%
[Pxy F] = mscohere(A1,S2,hamming(300),150,300,1/dt);
semilogx(F/2,Pxy,'k','linewidth',3)
title('Coherence (Shear2 & Acc1)')
grid on
set(gca,'fontsize',16)
xlabel('Wavenumber [cpm]')
ylabel('Coherence')
set(gca,'fontsize',20)
xlim([1e-1 1e2])


% 
% 
% %% CTD
% 
% F = figure(2);clf
% set(F,'position',[100 -100 1200 650])
% 
% h1 = subplot(311);
% plot(time,P)
% title('Pressure')
% 
% h2 = subplot(312);
% plot(time,T)
% title('Temp')
% 
% h3 = subplot(313);
% plot(time,C)
% title('Salinity')
% 
% linkaxes([h1 h2 h3],'x')


%%

Ff = figure(2);clf

subplot(211)
semilogx(F,Pxy,'k','linewidth',2)
xlim([1e-0 2e2])
ylabel('Coherence^2')
set(gca,'fontsize',20)
grid on

subplot(212)
loglog(f,mean(Ss2),'k','linewidth',2)

Pxyint = interp1(F,Pxy,f);

hold on
loglog(f,mean(Ss2).*(1-Pxyint),'r','linewidth',2)
xlim([1e-0 2e2])
ylabel('V^2/Hz')
xlabel('Hz')
set(gca,'fontsize',20)
ylim([5e-11 1e-4])

legend('original','coherence corrected')
grid on













