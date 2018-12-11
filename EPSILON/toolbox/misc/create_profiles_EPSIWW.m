root_data='/Volumes/DataDrive/';
root_script='/Users/aleboyer/ARNAUD/SCRIPPS/EPSILON/';
epsifile = 'SDepsi_d3.mat';
ctdfile  = 'Profiles_SODA_rbr_d3.mat';

Cruise_name='SODA'; % 
vehicle_name='WW'; % 
deployement='d3';

% need seawater to use sw_bfrq
addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/scripts/mixing_library/mixing_library/private1/seawater
addpath Toolbox/

ctdpath=sprintf('%s/%s/%s/%s/ctd/',root_data,Cruise_name,vehicle_name,deployement);
epsipath=sprintf('%s/%s/%s/%s/epsi/',root_data,Cruise_name,vehicle_name,deployement);
WWpath=sprintf('%s/%s/%s/%s/L1/',root_data,Cruise_name,vehicle_name,deployement);

name_ctd=[vehicle_name '_ctd_' deployement];


Epsi = load([epsipath epsifile]);
% only for SODA
Epsi.a.epsi.c=Epsi.a.epsi.ramp_count;

%SD=buildepsiWWtime(Meta_Data,Epsi.a);
SD=buildepsiWWtime(Epsi.a,Meta_Data);

SD=rmfield(SD,'timeheader');

CTD  = load([ctdpath ctdfile]);

CTDProfile=CTD.RBRprofiles;
%Epsi.Sensor5 = Epsi.Sensor1*nan;
EpsiProfile  = get_cast_epsiWW(SD,CTDProfile);
for i=1:length(CTDProfile)
    CTDProfile{i}.ctdtime=CTDProfile{i}.time;
end

% % previous version
% for i=1:length(EpsiProfile)
%     EpsiProfile{i}.epsitime=EpsiProfile{i}.EPSItime;
%     for n=1:nbchannels
%         wh_field=['Sensor' int2str(n)];
%         EpsiProfile{i}.(name_channels{n})=EpsiProfile{i}.(wh_field);
%     end
% end
% 
% for i=1:length(EpsiProfile)
%     for n=1:nbchannels
%         wh_field=['Sensor' int2str(n)];
%         EpsiProfile{i}=rmfield(EpsiProfile{i},wh_field);
%     end
% end


plot(SD.epsitime,SD.s2)
hold on
for i=1:length(EpsiProfile)
    plot(EpsiProfile{i}.epsitime,EpsiProfile{i}.s2)
end

save([WWpath 'Profiles_' deployement '.mat'],'CTDProfile','EpsiProfile','-v7.3');


