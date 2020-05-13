function [Tnoise1,Tnoise2]=mod_epsilometer_get_temperature_noise(Meta_Data,fc)
% adjust the epsilometer temperature channel electrical noise to the data by fitting the high freqeuncy part of the average T spectrum
% to the testbench electrical. It is used later to define the cut-off
% frequency for the TG spectrum integration.
% 
%
% written by Arnaud Le Boyer 02/06/2020.

listfile=dir(fullfile(Meta_Data.L1path,'Turbulence_Profiles*.mat'));
listfilename=natsort({listfile.name});



fe=Meta_Data.PROCESS.fe;
% get FPO7 channel average noise to compute chi
switch Meta_Data.MAP.temperature
    case 'Tdiff'
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
    otherwise
        FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
end

logf=log10(fe);
n0=FPO7noise.n0; n1=FPO7noise.n1; n2=FPO7noise.n2; n3=FPO7noise.n3;
noise=10.^(n0+n1.*logf+n2.*logf.^2+n3.*logf.^3);

count1=1;
scan1=[];
allPt1=0;
allPt2=0;
nfft=Meta_Data.PROCESS.nfft;
Fs=Meta_Data.PROCESS.Fs_epsi;
dTdV(1)=Meta_Data.epsi.t1.dTdV; % define in mod_epsi_temperature_spectra
dTdV(2)=Meta_Data.epsi.t2.dTdV; % define in mod_epsi_temperature_spectra 

for f=1:length(listfilename)
    load(fullfile(listfile(f).folder,listfilename{f}))
%     load(fullfile(listfile(f).folder,listfilename{f}),'nb_profile_perfile')
    disp(listfilename{f});
    for p=1:nb_profile_perfile
%         load(fullfile(listfile(f).folder,listfilename{f}),sprintf('Profile%03i',f))
        eval(sprintf('Profile=Profile%03i;',p));
        
        for i=1:Profile.nbscan
            if(Profile.process_flag(i)==1)
                scan1.Pr=Profile.pr(i);
                scan1.w=Profile.w(i);
                scan1.s=Profile.s(i);
                scan1.t=Profile.t(i);
                
                scan1.ktemp=kt(scan1.s,scan1.t,scan1.Pr);
                scan1 =mod_epsilometer_make_scan_v2(Profile,scan1,Meta_Data);
                % first get the spectrum in Volt so we can estimate the noise level and get
                % a cut-off freqeuncy
                [P1,~] = pwelch(detrend(scan1.t1)./dTdV(1),nfft,[],nfft,Fs,'psd');
                [P2,~] = pwelch(detrend(scan1.t2)./dTdV(1),nfft,[],nfft,Fs,'psd');

                 allPt1=allPt1+P1;
                 allPt2=allPt2+P2;
                 count1=count1+1;
            end
        end
    end
end

noise1=allPt1./count1;
noise2=allPt2./count1;

coef1=nanmean(noise1(fe>fc)./noise(fe>fc));
coef2=nanmean(noise2(fe>fc)./noise(fe>fc));

polynoise1=polyfit(log10(fe(~isnan(noise))),log10(coef1.*noise(~isnan(noise))),3);

Tnoise1.n0=polynoise1(4);
Tnoise1.n1=polynoise1(3);
Tnoise1.n2=polynoise1(2);
Tnoise1.n3=polynoise1(1);

polynoise2=polyfit(log10(fe(~isnan(noise))),log10(coef2.*noise(~isnan(noise))),3);

Tnoise2.n0=polynoise2(4);
Tnoise2.n1=polynoise2(3);
Tnoise2.n2=polynoise2(2);
Tnoise2.n3=polynoise2(1);

Meta_Data.MAP.temperature




