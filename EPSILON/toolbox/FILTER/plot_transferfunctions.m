nb_headerline=6;
filename1='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_t1.csv';
M1 = read_digilient_network_analysis(filename1);
filename2='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_t2.csv';
M2 = read_digilient_network_analysis(filename2);

fid=fopen('/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/EPSILON/toolbox/FILTER/EpsidTdt_H/Epsi_FPO7dTdt_ri.txt');
Vin=complex(C{2},C{3});
Vout=complex(C{4},C{5});

Temp.coef_filt=abs(Vout./Vin);
Temp.freq=C{1};

 
close all;
ax(1)=subplot(211);
semilogx(M1.f,M1.Vout./M1.Vin,'k')
hold on
semilogx(M2.f,M2.Vout./M2.Vin,'r')
semilogx(Temp.freq,Temp.coef_filt,'b')
title('Temp')
legend('t1','t2','SPICE')




filename3='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_s1.csv';
M3 = read_digilient_network_analysis(filename3);
filename4='/Volumes/MOD_dev/Projects/Epsilometer/CALIBRATION/AFE/SN8/MAP_SN8_s2.csv';
M4 = read_digilient_network_analysis(filename4);

Charge_Amp=load('charge_coeffilt.mat');

ax(2)=subplot(212);
semilogx(M3.f,M3.Vout./M3.Vin,'k')
hold on
semilogx(M4.f,M4.Vout./M4.Vin,'r')
semilogx(Charge_Amp.freq,Charge_Amp.coef_filt,'b')
title('Shear')
legend('s1','s2','SPICE')


