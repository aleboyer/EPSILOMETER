function mod_epsi_read_rawfiles(Meta_Data)

% define path and name channel
epsiDIR = Meta_Data.Epsipath;
ctdDIR  = Meta_Data.CTDpath;

% get the filenames in the folder
filenames = dir(fullfile(Meta_Data.SDRAWpath,'*.bin'));
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

a = mod_read_epsi_raw(filenames);

if ~isfield(a.epsi,'c')
    a.epsi.c=a.epsi.ramp_count;
end
SD=mod_epsi_sd_buildtime(Meta_Data,a);

save([Meta_Data.SDRAWpath 'SD' Meta_Data.deployment '.mat'],'a','-v7.3')

ax(1)=subplot(311);plot(sort(a.madre.EpsiStamp),a.madre.EpsiStamp)
ax(2)=subplot(312);plot(sort(a.madre.EpsiStamp(1:end-1)),diff(a.madre.EpsiStamp))
ax(3)=subplot(313);plot(a.epsi.EPSInbsample(1:end-1),mod(diff(a.epsi.ramp_count),450));
linkaxes(ax,'x')
print('-dpng2',[Meta_Data.SDRAWpath 'check_timestamp.png'])
close all

% save CTD
if isfield(SD,'aux1')
    clear F
    F=fieldnames(SD.aux1);
    command=[];
    for f=1:length(F)
        wh_F=F{f};
        eval(sprintf('%s=SD.aux1.%s;',wh_F,wh_F))
        command=[command ',' sprintf('''%s''',F{f})];
    end
    command=sprintf('save(''%sctd_%s.mat''%s)',ctdDIR,Meta_Data.deployment,command);
    disp(command)
    eval(command);
end



% save EPSI
clear F
F=fieldnames(SD.epsi);
command=[];
for f=1:length(F)
    wh_F=F{f};
    eval(sprintf('%s=SD.epsi.%s;',wh_F,wh_F))
    command=[command ',' sprintf('''%s''',F{f})];
end
command=sprintf('save(''%sepsi_%s.mat''%s)',epsiDIR,Meta_Data.deployment,command);
disp(command)
eval(command);

toc
end


