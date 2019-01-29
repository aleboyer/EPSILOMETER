function mod_epsi_read_rawfiles(Meta_Data)

% define path and name channel
epsiDIR = Meta_Data.Epsipath;
ctdDIR  = Meta_Data.CTDpath;

% get the filenames in the folder
switch Meta_Data.PROCESS.recording_mod
    case 'STREAMING'
        filenames = dir(fullfile(Meta_Data.RAWpath,'*.epsi'));
    case 'SD'
        filenames = dir(fullfile(Meta_Data.SDRAWpath,'*.bin'));
end
filenames = struct2cell(filenames);

%sort filenames  
filenames = filenames(1,:);
filenames=natsortfiles(filenames);
for i = 1:numel(filenames)
    filenames{i} = fullfile(Meta_Data.SDRAWpath,filenames{i});
end

% actual read. right now there is no option for unipolar or bipolar ADC
% count conversion. 
% The channels are also hard coded 
% TODO: add Meta_Data as an argument and use the channels names and the ADC config fix these hard coded options 

a = mod_read_epsi_raw(filenames,Meta_Data);

if ~isfield(a.epsi,'c')
    a.epsi.ramp_count=0*a.epsi.s1;
else
    a.epsi.ramp_count=a.epsi.c;
end
switch Meta_Data.PROCESS.recording_mod
    case 'STREAMING'
        a.aux1.S=sw_salt(a.aux1.C*10./sw_c3515,a.aux1.T,a.aux1.P);
        a.aux1.sig=sw_pden(a.aux1.S,a.aux1.T,a.aux1.P,0);
        a.aux1.aux1time=a.aux1.time;
        a.epsi.epsitime=a.epsi.time;
        save([Meta_Data.RAWpath 'STR' Meta_Data.deployment '.mat'],'a','-v7.3')
    case 'SD'
        SD=mod_epsi_sd_buildtime(Meta_Data,a);
        save([Meta_Data.SDRAWpath 'SD' Meta_Data.deployment '.mat'],'a','-v7.3')
        a=SD;
end


ax(1)=subplot(311);plot(sort(a.madre.EpsiStamp),a.madre.EpsiStamp)
ax(2)=subplot(312);plot(sort(a.madre.EpsiStamp(1:end-1)),diff(a.madre.EpsiStamp))
ax(3)=subplot(313);plot(a.epsi.EPSInbsample(1:end-1),mod(diff(a.epsi.ramp_count),450));
linkaxes(ax,'x')
print('-dpng2',[Meta_Data.SDRAWpath 'check_timestamp.png'])
close all

% save CTD
if isfield(a,'aux1')
    clear F
    F=fieldnames(a.aux1);
    command=[];
    for f=1:length(F)
        wh_F=F{f};
        eval(sprintf('%s=a.aux1.%s;',wh_F,wh_F))
        command=[command ',' sprintf('''%s''',F{f})];
    end
    filepath=fullfile(ctdDIR,['ctd_' Meta_Data.deployment '.mat']);
    command=sprintf('save(''%s''%s)',filepath,command);
    disp(command)
    eval(command);
end



% save EPSI
clear F
F=fieldnames(a.epsi);
command=[];
for f=1:length(F)
    wh_F=F{f};
    eval(sprintf('%s=a.epsi.%s;',wh_F,wh_F))
    command=[command ',' sprintf('''%s''',F{f})];
end
filepath=fullfile(epsiDIR,['epsi_' Meta_Data.deployment '.mat']);
command=sprintf('save(''%s''%s)',filepath,command);
disp(command)
eval(command);

toc
end


