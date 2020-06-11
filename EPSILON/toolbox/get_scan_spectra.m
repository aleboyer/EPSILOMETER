function [scan] = get_scan_spectra(Profile,id_scan,Meta_Data)

% function [scan] = get_scan_spectra(Profile,id_scan,Meta_Data)
%
% INPUTS:
%   Profile = Profile### structure 
%   id_scan = Index of Profile.pr on which to compute spectra
%   Meta_Data
%
% OUTPUTS:
%   scan = Structure similar to Profile### but only for current index and
%          now including spectra
%
% Nicole Couto | June 2020
% -------------------------------------------------------------------------
%% Gather some data
% -------------------------------------------------------------------------

Pr          = Profile.pr(id_scan);

tscan       = Meta_Data.PROCESS.tscan;
Fs_epsi     = Meta_Data.PROCESS.Fs_epsi;
N_epsi      = tscan.*Fs_epsi-mod(tscan*Fs_epsi,2);
Fs_ctd      = Meta_Data.PROCESS.Fs_ctd;
N_ctd       = tscan.*Fs_ctd-mod(tscan*Fs_ctd,2);
h_freq      = Meta_Data.PROCESS.h_freq;

[~,indP]    = sort(abs(Profile.P-Pr));
indP        = indP(1);
ind_ctdscan = indP-N_ctd/2:indP+N_ctd/2; % ind_scan is even
ind_Pr_epsi = find(Profile.epsitime<Profile.ctdtime(indP),1,'last');
ind_scan    = ind_Pr_epsi-N_epsi/2:ind_Pr_epsi+N_epsi/2; % ind_scan is even

scan.w      = Profile.w(id_scan);
scan.pr     = Profile.P(ind_ctdscan);
scan.t      = Profile.T(ind_ctdscan);
scan.s      = nanmean(Profile.S(ind_ctdscan));
scan.kvis   = nu(Profile.s(id_scan),Profile.t(id_scan),Profile.pr(id_scan));
scan.ktemp  = kt(scan.s,scan.t,scan.pr);

% get FPO7 channel average noise to compute chi
switch Meta_Data.MAP.temperature
    case 'Tdiff'
        Meta_Data.PROCESS.FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
    otherwise
        Meta_Data.PROCESS.FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
end

FPO7noise   = Meta_Data.PROCESS.FPO7noise;

% Gravity  ... of the situation :)
G = 9.81;
twoG = 2*G;

% Calibration values
Sv1         = Meta_Data.epsi.s1.Sv;
Sv2         = Meta_Data.epsi.s2.Sv;
dTdV1       = Meta_Data.epsi.t1.dTdV; % define in mod_epsi_temperature_spectra
dTdV2       = Meta_Data.epsi.t2.dTdV; % define in mod_epsi_temperature_spectra 

channels    = Meta_Data.PROCESS.channels;

for c=1:length(channels)
    currChannel=channels{c};
    switch currChannel
        case {'a1','a2','a3'}
            scan.(currChannel)=Profile.(currChannel)(ind_scan)*G; % time series in m.s^{-2}
        case 's1'
            scan.(currChannel)=Profile.(currChannel)(ind_scan).*twoG./(Sv1.*scan.w); % time series in m.s^{-1}
        case 's2'
            scan.(currChannel)=Profile.(currChannel)(ind_scan).*twoG./(Sv2.*scan.w); % time series in m.s^{-1}
        case 't1'
            scan.(currChannel)=Profile.(currChannel)(ind_scan).*dTdV1; % time series in Celsius
        case 't2'
            scan.(currChannel)=Profile.(currChannel)(ind_scan).*dTdV1; % time series in Celsius
    end
end

% Put new variables in the structure
varList = {'Pr','tscan','Fs_epsi','N_epsi',...
            'Fs_ctd','N_ctd','h_freq',...
            'indP','ind_ctdscan','ind_Pr_epsi','ind_scan',...
            'Sv1','Sv2','dTdV1','dTdV2','FPO7noise'};       
for iVar=1:numel(varList)
    scan.(varList{iVar}) = eval(varList{iVar}); 
end


%% Compute spectra for acceleration channels
% -------------------------------------------------------------------------

chanList = {'a1','a2','a3'};
for iChan=1:numel(chanList)
    %c = find(cellfun(@(x) strcmp(x,chanList{iChan}),channels));    
    %currChannel = channels{c};
    currChannel = chanList{iChan};
    
    % Get the spectrum for the current acceleration channel
    [Pa,sumPa,fe]= mod_efe_scan_acceleration(scan,currChannel,Meta_Data);
    
    % Get the coherence spectra between each shear probe and the current
    % acceleration channel
    [Cu1a,Cu2a,sumCu1a,sumCu2a,fe]= ...
        mod_efe_scan_coherence(scan,currChannel,Meta_Data);
    
    % Put new variables in the structure
    varList = {'Pa','sumPa','fe','Cu1a','Cu2a','sumCu1a','sumCu2a'};    
    for iVar=1:numel(varList)
        scan.(varList{iVar}).(currChannel) = eval(varList{iVar});
    end
end

%% Compute shear spectra and epsilon
% -------------------------------------------------------------------------

chanList = {'s1','s2'};
for iChan=1:numel(chanList)
    currChannel = chanList{iChan};
    
    [P,Pv,Pvk,Psk,Cua,epsilon,fc,fe] = mod_efe_scan_epsilon(scan,currChannel,'a3',Meta_Data);
    
    % Put new variables in the structure
    varList = {'P','Pv','Pvk','Psk','Cua','epsilon','fc','fe'};    
    for iVar=1:numel(varList)
        scan.(varList{iVar}).(currChannel) = eval(varList{iVar});
    end
end

%% Compute temperature spectra and chi
% -------------------------------------------------------------------------

chanList = {'t1','t2'};
for iChan=1:numel(chanList)
    currChannel = chanList{iChan};
    chanFieldName = sprintf('%sspectra',currChannel);
    
    [Pt,Ptk,Ptgk,chi,fc,flag,fe] = ...
        mod_efe_scan_chi(scan,currChannel,Meta_Data,h_freq,FPO7noise);

    % Put new variables in the structure
    varList = {'Pt','Ptk','Ptgk','chi','fc','flag','fe'};    
    for iVar=1:numel(varList)
        scan.(varList{iVar}).(currChannel) = eval(varList{iVar});
    end
end

%% Add variable descriptions and units
% -------------------------------------------------------------------------
% Set up all the variable info fields now. I'll fill them all in later. 
scanFields = fields(scan);
for iField=1:numel(scanFields)
   scan.varInfo.(scanFields{iField}).Description = [];
   scan.varInfo.(scanFields{iField}).Units = [];
end

scan.varInfo.Pa.Description = 'accleration frequency power spectrum';
scan.varInfo.sumP.Description = 'integrated acceleratation frequency power spectrum between Meta_Data.PROCESS.fc1 and Meta_Data.PROCESS.fc2';
scan.varInfo.fe.Description = 'frequency array';
scan.varInfo.P.Description   = 'shear frequency power spectrum'; 
scan.varInfo.Pv.Description  = 'non-coherent shear frequency power spectrum (full profile coherence with a3 channel has been removed)'; 
scan.varInfo.Pvk.Description = 'non-coherent shear wavenumber power spectrum';
scan.varInfo.Psk.Description = 'non-coherent shear 2pi*wavenumber power spectrum';
scan.varInfo.Cua.Description = 'full profile coherence between shear channel and a3, computed earlier with mod_efe_scan_coherence';
scan.varInfo.epsilon.Description = 'epsilon calculated from Psk';
scan.varInfo.fc.Description  = 'cutoff frequency';
scan.varInfo.fe.Description  = 'frequency array';