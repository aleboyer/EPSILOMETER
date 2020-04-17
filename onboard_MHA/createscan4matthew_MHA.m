%create scan for matthew
% epsilon with s2 = -8.3883
%              s1 = -9.6308

%load('/Volumes/GoogleDrive/My Drive/DATA/PISTON/sr1914/epsi/PC2/d12/L1/Profiles_d12.mat')
%load('/Volumes/GoogleDrive/My Drive/DATA/PISTON/sr1914/epsi/PC2/d12/L1/Turbulence_Profiles0.mat')

%MHA: use d10 because that is what I have.
load('/Users/malford/GoogleDrive/Data/epsi/PISTON/Cruises/sr1914/data/epsi/PC2/d10/L1/Profiles_d10.mat') %This gives CTDProfiles and EpsiProfiles
load('/Users/malford/GoogleDrive/Data/epsi/PISTON/Cruises/sr1914/data/epsi/PC2/d10/L1/Turbulence_Profiles0.mat')

%%
id_profile=1;
id_scan=48; %A region of strong-ish turbulence

id_scan=95; %weak turbulence


indscan=MS{id_profile}.indscan{id_scan};

scan.s1=EpsiProfiles.datadown{id_profile}.s1(indscan);
scan.s2=EpsiProfiles.datadown{id_profile}.s2(indscan);
scan.t1=EpsiProfiles.datadown{id_profile}.t1(indscan);
scan.t2=EpsiProfiles.datadown{id_profile}.t2(indscan);
scan.a1=EpsiProfiles.datadown{id_profile}.a1(indscan);
scan.a2=EpsiProfiles.datadown{id_profile}.a2(indscan);
scan.a3=EpsiProfiles.datadown{id_profile}.a3(indscan);


%%
clf
semilogx(MS{id_profile}.epsilon,MS{id_profile}.pr);axis ij


%% Now some MHA sanity checks
%I don't think I need to recompute the spectra as I recall trusting them.
%But I'd still better check.

%indscan=MS{id_profile}.indscan{id_scan};

%scan.s1=EpsiProfiles.datadown{id_profile}.s1(indscan);


data=detrend(scan.s1);
%%
WINDOW=512;
[P2,f2] = pwelch(data,WINDOW,[],WINDOW,325,'psd'); %Set NFFT equal to window length

loglog(f2,P2)

%Ok, so I don't know what Pf and Pf_0 are as they don't seem to show 50-Hz
%peaks.  ??

%But I can try making a simple estimate of the wavenumber spectrum from
%this estimated frequency spectrum.

%%
ca_filter = load('/Users/malford/GoogleDrive/Work/Projects/SSTP/chiometer_epsilometer/EPSILOMETER/EPSILON/toolbox/FILTER/charge_coeffilt.mat'); %from network analysis
f=ca_filter.freq;
Hs1filter=(sinc(f/(325))).^4;
h2oakey=1 ./ (1 + (0.02*f / w).^2)';
h2elec=Hs1filter'.^2.*abs(ca_filter.coef_filt).^2.*h2oakey; 

%%
f1=MS{id_profile}.f;

h2elec1=interp1(f,h2elec,f2);

w=0.49;

k1=f2/w;
g=9.8;
Sv=37.38; %Sv for s2 in PISTON

kspec_sh=(2*g/Sv/w)^2 .* P2 ./ h2elec1 .* (2 * pi * k1).^2;
% (2g/Sv/w)^2 * [H^2_sinc4 H^2_oakey H^2_elec]^-1


%% Great.  I have verified that the computed spectrum of the s1 data, multiplied by the transfer functions, match the calculated wavenumber spectra pretty well.

clf
loglog(MS{id_profile}.k,squeeze(MS{id_profile}.Pshear_k(id_scan,:,1)),...
    MS{id_profile}.k,squeeze(MS{id_profile}.Ppan(id_scan,:,1)))
hold on
loglog(k1,kspec_sh,'k-')
hold off
shg

%% Plot v freq so we can spot check in C code

loglog(f2,kspec_sh,'k-')

%%

i1=find(k1 > 2 & k1 < 10);
dk=k1(2)-k1(1);
sum(kspec_sh(i1))*dk
%% The fall rate for this scan was 0.49 m/s.
MS{id_profile}.w(id_scan)
%%
clf
loglog(MS{id_profile}.f,squeeze(MS{id_profile}.Pf(1,id_scan,:)))
hold on
loglog(MS{id_profile}.f,squeeze(MS{id_profile}.Pf_0(1,id_scan,:)),'g-')
loglog(f2,P2,'r-')
hold off
%%
%id_profile=4;
%id_scan=3;
%%
%save('/Users/malford/GoogleDrive/Work/Projects/SSTP/chiometer_epsilometer/EPSILOMETER/onboard_MHA/Piston_PC2_d10_profile1_scan_48.mat','scan')

%%

%output test data
for c=1:512
    disp([num2strMHA(scan.s1(c),8) ',' ])
end

%% output test data
str=[];
for c=1:512
    str=[str num2strMHA(scan.s1(c),8),', '];
end
str
%%
tmp=scan.s1(1:512)';
save('tmp','tmp','-ascii')