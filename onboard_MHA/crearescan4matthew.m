%create scan for matthew
% epsilon with s2 = -8.3883
%              s1 = -9.6308

load('/Volumes/GoogleDrive/My Drive/DATA/PISTON/sr1914/epsi/PC2/d12/L1/Profiles_d12.mat')
load('/Volumes/GoogleDrive/My Drive/DATA/PISTON/sr1914/epsi/PC2/d12/L1/Turbulence_Profiles0.mat')


id_profile=1;
id_scan=100;
indscan=MS{id_profile}.indscan{id_scan};

scan.s1=EpsiProfiles.datadown{id_profile}.s1(indscan);
scan.s2=EpsiProfiles.datadown{id_profile}.s2(indscan);
scan.t1=EpsiProfiles.datadown{id_profile}.t1(indscan);
scan.t2=EpsiProfiles.datadown{id_profile}.t2(indscan);
scan.a1=EpsiProfiles.datadown{id_profile}.a1(indscan);
scan.a2=EpsiProfiles.datadown{id_profile}.a2(indscan);
scan.a3=EpsiProfiles.datadown{id_profile}.a3(indscan);


save('/Volumes/GoogleDrive/My Drive/DATA/PISTON/sr1914/epsi/PROC/Piston_PC2_d12_profile1_scan_100.mat','scan')
