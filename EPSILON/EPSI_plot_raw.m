function EPSI_plot_raw(Meta_Data)

Cruise_name  = Meta_Data.mission;
vehicle_name = Meta_Data.vehicle_name;
deployment   = Meta_Data.deployement;

epsipath = Meta_Data.Epsipath;
rawpath  = Meta_Data.RAWpath;

x = dir([epsipath 'epsi_' deployment '*.mat']);
datefile=[x.datenum];
[~,I]=max(datefile);

filename = x(I).name;
epsi = load([epsipath filename]);
disp([epsipath filename])

T1 = epsi.t1;
T2 = epsi.t2;
S1 = epsi.s1;
S2 = epsi.s2;
C  = epsi.c;
A1 = epsi.a1;
A2 = epsi.a2;
A3 = epsi.a3;


%% first plot
sname = [Cruise_name ' / ' vehicle_name ' / ' deployment];
fname = [Cruise_name '_' deployment '_' x(I).name];

dt = 1/325;
tdummy = epsi.epsitime*3600*24;


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
% select the section on which we compute spectra
% . previsously hard coded here 
% . trange = [0 1e10]; %default
% . now we use ginput
pause
[ind1,~]=ginput(2);
trange=[ind1(1) ind1(2)];

%%
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

id =strfind(fname,'.mat');


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
print([rawpath 'Timeserie_raw_' deployment '.png'],'-dpng')

%% COMPUTE SPECTRA
warning off

tscan = 3; % 3 seconds

blockid = 1:tscan*dt^-1:length(T1);

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
load EPSILON/toolbox/PLOTS/comparison_temp_granite_sproul.mat
load EPSILON/toolbox/PLOTS/d7_spectra.mat


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

print([rawpath 'Spectemp_raw_' deployment '.png'],'-dpng')


%% SHEAR
load EPSILON/toolbox/PLOTS/comparison_shear_granite_sproul.mat

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

print([rawpath 'Specshear_raw_' deployment '.png'],'-dpng')

%% ACCEL

load EPSILON/toolbox/PLOTS/comparison_accel_granite_sproul.mat


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

title([sname '  [Acceleration]'])
grid on
set(gca,'fontsize',20)
xlabel('Hz')
ylabel('g^2 / Hz')

print([rawpath 'Specaccel_raw_' deployment '.png'],'-dpng')


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
xlabel('Hz')
ylabel('Coherence')
set(gca,'fontsize',20)
xlim([1e-1 1e2])

print([rawpath 'Coh_raw_' deployment '.png'],'-dpng')


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













