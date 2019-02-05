nb_headerline=6;
filename1='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_t1.csv';
M1 = read_digilient_network_analysis(filename1);
filename2='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_t2.csv';
M2 = read_digilient_network_analysis(filename2);
filename16='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN6/MAP_SN6_t1.csv';
M16 = read_digilient_network_analysis(filename16);
filename26='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN6/MAP_SN6_t2.csv';
M26 = read_digilient_network_analysis(filename26);


fid=fopen('/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/EPSILON/toolbox/FILTER/EpsidTdt_H/Epsi_FPO7dTdt_ri.txt');
C=textscan(fid,'%f %f,%f %f,%f','Headerlines',1);
Vin=complex(C{2},C{3});
Vout=complex(C{4},C{5});

Temp.coef_filt=abs(Vout./Vin);
Temp.freq=C{1};

 
close all;
ax(1)=subplot(211);
semilogx(M1.f,M1.Vout./M1.Vin,'k')
hold on
semilogx(M2.f,M2.Vout./M2.Vin,'r')
semilogx(M16.f,M16.Vout./M16.Vin,'c')
semilogx(M26.f,M26.Vout./M26.Vin,'m')
semilogx(Temp.freq,Temp.coef_filt,'b')
title('Temp','fontsize',20)
legend('t1-SN8','t2-SN8','t1-SN6','t2-SN6','SPICE')
grid on
xlim([1e-2 1e4])
set(gca,'fontsize',20)
ylabel('H (no units)','fontsize',20)

%% shear

filename3='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_s1.csv';
M3 = read_digilient_network_analysis(filename3);
filename4='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_s2.csv';
M4 = read_digilient_network_analysis(filename4);

filename5='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN6/MAP_SN6_s1.csv';
M5 = read_digilient_network_analysis(filename5);
filename6='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN6/MAP_SN6_s2.csv';
M6 = read_digilient_network_analysis(filename6);

Charge_Amp=load('charge_coeffilt.mat');

coeffit=polyfit(log10(M3.f),M3.Vout./M3.Vin,7);
%coef_filt = polyval(coeffit,log10(M3.f));
coef_filt = polyval(coeffit,log10(Charge_Amp.freq));
%coef_filt = M3.Vout./M3.Vin;


ax(2)=subplot(212);
semilogx(M3.f,20*log10(M3.Vout./M3.Vin),'k')
hold on
semilogx(M4.f,20*log10(M4.Vout./M4.Vin),'r')
semilogx(M5.f,20*log10(M5.Vout./M5.Vin),'c')
semilogx(M6.f,20*log10(M6.Vout./M6.Vin),'m')
semilogx(Charge_Amp.freq,20*log10(Charge_Amp.coef_filt),'b')
title('Shear','fontsize',20)
legend('s1-SN8','s2-SN8','s1-SN6','s2-SN6','SPICE','location','southeast')
xlim([1e-2 1e4])
ylim([0 1])
grid on
set(gca,'fontsize',20)
ylabel('H (dB)','fontsize',20)
xlabel('Hz','fontsize',20)
fig=gcf;fig.PaperPosition=[0 0 15 10];
print('-dpng2','~/ARNAUD/SCRIPPS/EPSILOMETER/CALIBRATION/ELECTRONICS/AFE_TF_board.png')

freq=Charge_Amp.freq;
%save('charge_coeffilt_09312019.mat','freq','coef_filt');




