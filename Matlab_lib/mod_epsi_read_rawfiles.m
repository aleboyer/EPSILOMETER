function mod_epsi_read_rawfiles(Meta_Data)


% get the filenames of the raw data in the  raw or sdraw folder
switch Meta_Data.PROCESS.recording_mod
    case 'STREAMING'
        list_files = dir(fullfile(Meta_Data.RAWpath,'*.epsi'));

    case 'SD'
        list_files = dir(fullfile(Meta_Data.SDRAWpath,'*.bin'));
        if isempty(list_files)
            list_files = dir(fullfile(Meta_Data.SDRAWpath,'*.dat'));
        end
end
filenames = {list_files.name};
dirnames = {list_files.folder};

% sort the files from (1 12 112 2 3) to (1 2 3 .... 12 .... 112)
% 
filenames=natsortfiles(filenames);
for i = 1:numel(filenames)
    filenames{i} = fullfile(dirnames{i},filenames{i});
end

% actual read.  be very carefull on the Meta_Data Structure.
a = mod_read_epsi_raw(filenames,Meta_Data);
if ~isfield(a.epsi,'c')
    ramp_count=0*a.epsi.s1;
else
    ramp_count=a.epsi.c_count;
end


% save the whole time series 
switch Meta_Data.PROCESS.recording_mod
    case 'STREAMING'
        a.aux1.S=sw_salt(a.aux1.C*10./sw_c3515,a.aux1.T,a.aux1.P);
        a.aux1.sig=sw_pden(a.aux1.S,a.aux1.T,a.aux1.P,0);
        a.aux1.aux1time=a.aux1.time;
        a.epsi.epsitime=a.epsi.time;
        save(fullfile(Meta_Data.RAWpath,['STR' Meta_Data.deployment '.mat']),'a','-v7.3')
    case 'SD'
        % the computation of S sig is done in sd buildtime
        %TODO this somewhere else maybe a function common to
        % SD and streaming since there are no good reason to have them separate. 
        SD=mod_epsi_sd_buildtime(Meta_Data,a);
        save(fullfile(Meta_Data.SDRAWpath,['SD' Meta_Data.deployment '.mat']),'a','-v7.3')
        a=SD;
end


% 01/30/2019 we are using c as a ramp samp signal or scan count 
a.epsi.ramp_count=ramp_count;


% plot some scan count checks
%ax(1)=subplot(311);plot(1:length(a.madre.EpsiStamp),a.madre.TimeStamp,'b')
ax(1)=subplot(411);plot(1:length(a.madre.EpsiStamp),a.madre.EpsiStamp,'b')
ax(2)=subplot(412);plot(1:length(a.madre.EpsiStamp)-1,diff(a.madre.EpsiStamp))
ylim([0 200])
ax(3)=subplot(413);plot((1:length(diff(a.epsi.ramp_count)))/160,diff(a.epsi.ramp_count));
ylim([-5 2])
ax(4)=subplot(414);plot(1:length(a.madre.EpsiStamp),a.madre.TimeStamp/86400+datenum(1970,1,1),'b');
hold on
plot((1:length(a.epsi.epsitime))/160,a.epsi.epsitime,'r');




linkaxes(ax,'x')
print('-dpng2',[Meta_Data.SDRAWpath 'check_timestamp.png'])
close all

% save CTD in the ctd folder
if isfield(a,'aux1')
    clear F
    F=fieldnames(a.aux1);
    command=[];
    for f=1:length(F)
        wh_F=F{f}; 
         eval(sprintf('%s.%s=a.aux1.%s;',['ctd_' Meta_Data.deployment ],wh_F,wh_F))
%         eval(sprintf('%s=a.aux1.%s;',wh_F,wh_F))
%         command=[command ',' sprintf('''%s''',F{f})];
    end
    filepath=fullfile(Meta_Data.CTDpath,['ctd_' Meta_Data.deployment '.mat']);
%      command=sprintf('save(''%s''%s)',filepath,command);
%      disp(command)
%      eval(command);
     save(filepath,['ctd_' Meta_Data.deployment]);
end



% save EPSI in the epsi
clear F
F=fieldnames(a.epsi);
command=[];
for f=1:length(F)
    wh_F=F{f};
    eval(sprintf('%s=a.epsi.%s;',wh_F,wh_F))
    command=[command ',' sprintf('''%s''',F{f})];
end
filepath=fullfile(Meta_Data.Epsipath,['epsi_' Meta_Data.deployment '.mat']);
command=sprintf('save(''%s''%s)',filepath,command);
disp(command)
eval(command);

toc
end


