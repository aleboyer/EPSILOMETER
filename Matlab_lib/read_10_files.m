dirname = '/Volumes/EPSI_SD_4/';
%dirname = '/Users/aleboyer/ARNAUD/SCRIPPS/DEV/bench132/SD_FIX/raw/'
%dirname = '/Volumes/Ahua/data_archive/WaveChasers-DataArchive/SODA/cruiseshare/processed_data/epsilometer/data/ww_deployment_3/';

filenames = dir(fullfile(dirname,'*.bin'));

filenames = struct2cell(filenames);
% 
filedates = cell2mat(filenames(6,:));
filenames = filenames(1,:);
filenames=natsortfiles(filenames);
% sort file bby date time
%[filedates, indx] = sort(filedates);

%filenames = filenames(indx);

for i = 1:numel(filenames)
    filenames{i} = fullfile(dirname,filenames{i});
end

% read file 1 to 10 (change 1 to 10 to read another subset)
a = mod_read_epsi_raw(filenames([2:end]));


ax(1)=subplot(411);plot(sort(a.madre.EpsiStamp),a.madre.EpsiStamp)
ax(2)=subplot(412);plot(sort(a.madre.EpsiStamp(1:end-1)),diff(a.madre.EpsiStamp))
ax(3)=subplot(413);plot(a.epsi.EPSInbsample(1:end-1),mod(diff(a.epsi.ramp_count),450));
ax(4)=subplot(414);plot(a.madre.EpsiStamp,a.madre.fsync_err);
hold(ax(4),'on')
plot(ax(4),a.madre.EpsiStamp,a.madre.EpsiStamp*0+160,'-.')
linkaxes(ax,'x')

xlabel(ax(4),'EPSI sample','fontsize',25)
ylabel(ax(1),'EPSI sample','fontsize',25)
ylabel(ax(2),'EPSI sample','fontsize',25)
ylabel(ax(3),'EPSI sample','fontsize',25)
ylabel(ax(4),'EPSI sample','fontsize',25)
ax(1).XTickLabel='';
ax(2).XTickLabel='';
ax(3).XTickLabel='';

title(ax(1),'indexes ','fontsize',25)
title(ax(2),'diff index header','fontsize',25)
title(ax(3),'diff ramp','fontsize',25)
title(ax(4),'pending sample after fsync after SD write','fontsize',25)
set(ax(1),'fontsize',20)
set(ax(2),'fontsize',20)
set(ax(3),'fontsize',20)
set(ax(4),'fontsize',20)
ylim(ax(4),[0,170])
ax(4).YTick=[0 100 160];
fig=gcf;fig.PaperPosition = [0 0 20 10];
%print('-dpng2','/Users/aleboyer/ARNAUD/SCRIPPS/DEV/bench132/CHECK_fsync/fync.png')

%print('-dpng2','/Users/aleboyer/ARNAUD/SCRIPPS/DEV/bench132/CHECK_fsync/zoom_fync.png')




