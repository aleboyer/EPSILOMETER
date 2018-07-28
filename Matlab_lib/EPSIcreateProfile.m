function EPSIcreateProfile(Meta_Data)

root_data=Meta_Data.path_mission;
epsifile = sprintf('epsi_%s.mat',Meta_Data.deployement);
ctdfile  = sprintf('ctd_%s.mat',Meta_Data.deployement);

% need seawater to use sw_bfrq
addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/scripts/mixing_library/mixing_library/private1/seawater
addpath Toolbox/

ctdpath  = Meta_Data.CTDpath;
epsipath = Meta_Data.EPSIpath;
L1path   = Meta_Data.L1path;


Epsi = load([epsipath epsifile]);
CTD  = load([ctdpath ctdfile]);
%% if there are discrepancie with previous profile process TODO: fix the discrepancies upstream ... 
if isfield(CTD,'time')
    CTD.ctdtime=CTD.time;
end

[CTDProfile.up,CTDProfile.down,CTDProfile.dataup,CTDProfile.datadown] = ...
                                               get_upcast_sbe(CTD,1.5);
Epsi.Sensor5=Epsi.Sensor1*nan;
[EpsiProfile.up,EpsiProfile.down,EpsiProfile.dataup,EpsiProfile.datadown] =...
                                                     get_upcast_epsi(Epsi,CTD.ctdtime,CTDProfile.up,CTDProfile.down);


save([L1path 'Profiles_' name_ctd],'CTDProfile','EpsiProfile','-v7.3');



