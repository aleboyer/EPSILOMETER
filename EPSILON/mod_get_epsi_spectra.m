function [P,k]=mod_get_epsi_spectra(EpsiProfile,CTDProfile,Pr,tscan)

% nbscan number of segment
% tscan length of a segment in second
% Pr: pressure around which the diagnostic is performed. Pr can be an
% array
% Epsi and CTD Profiles are the Epsi and CTD time series 

if max(Pr)>max(CTDProfile.P)
    error('The profile does is not deep enough. Select a pressure within %3.2fm %3.2fm',min(CTDProfile.P),max(CTDProfile.P));
end
timeaxis=86400*(EpsiProfile.epsitime-EpsiProfile.epsitime(1));
if isfield(CTDProfile,'ctdtime')
    speed=diff(CTDProfile.P)./diff(CTDProfile.ctdtime*86400);
    CTDtimeaxis=86400*(CTDProfile.ctdtime(2:end)-CTDProfile.ctdtime(1));
else
    CTDtimeaxis=86400*(CTDProfile.time(2:end)-CTDProfile.time(1));
    speed=diff(CTDProfile.P)./diff(CTDProfile.time*86400);
end

%% spectra param

epsi_df = 1./nanmean(diff(EpsiProfile.epsitime*86400));
% define parameters to compute the spectra.
epsi_Lscan  = floor(tscan*epsi_df);  
k=make_kaxis(tscan,epsi_df);
LK=numel(k);


%% depending on the casrt direction up or down
if sign(mean(speed))==1 % downcast
    % find the CTD time and epsi index of the defined Pr.
    time_Pr = arrayfun(@(x) (CTDtimeaxis(find(CTDProfile.P>=x,1,'first'))),Pr);
else % upcast
    % find the CTD time and epsi index of the defined Pr.
    time_Pr = arrayfun(@(x) (CTDtimeaxis(find(CTDProfile.P>=x,1,'last'))),Pr);
end
ind_Pr  = arrayfun(@(x) (find(timeaxis<=x,1,'last')),time_Pr);


% define frequnecy axis for ctd and epsi spectra.
epsi_indscan = arrayfun(@(x) (x+(-floor(epsi_Lscan/2):floor(epsi_Lscan/2))),ind_Pr,'un',0);
epsi_indscan = cellfun(@(x) (x(1:LK)),epsi_indscan,'un',0);
%% split data into segments for 1st time split
data_a1 = cell2mat(cellfun(@(x) filloutliers( ...
                EpsiProfile.a1(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_a2 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.a2(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_a3 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.a3(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_s1 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.s1(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_s2 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.s2(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';

% multiply by 2 becasue it is a 2 sided spectrum             
P.a1=2*alb_power_spectrum(data_a1,1./tscan);
P.a2=2*alb_power_spectrum(data_a2,1./tscan);
P.a3=2*alb_power_spectrum(data_a3,1./tscan);
P.s1=2*alb_power_spectrum(data_s1,1./tscan);
P.s2=2*alb_power_spectrum(data_s2,1./tscan);



