%dirname = '/Volumes/EPSI_SD_4/';
%dirname = '/Users/aleboyer/ARNAUD/SCRIPPS/DEV/bench132/SD_FIX/raw/'
%dirname = '/Volumes/Ahua/data_archive/WaveChasers-DataArchive/SODA/cruiseshare/processed_data/epsilometer/data/ww_deployment_3/';
dirname='/Volumes/DataDrive/SODA/WW/d2/sd_raw/';

%filenames = dir(fullfile(dirname,'*.bin'));
filenames = dir(fullfile(dirname,'*.dat'));

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
a = mod_read_epsi_raw(filenames([1:end]));

save('/Volumes/DataDrive/SODA/WW/d2/epsi/SDepsi_d2.mat','a','-v7.3')

ax(1)=subplot(311);plot(sort(a.madre.EpsiStamp),a.madre.EpsiStamp)
ax(2)=subplot(312);plot(sort(a.madre.EpsiStamp(1:end-1)),diff(a.madre.EpsiStamp))
ax(3)=subplot(313);plot(a.epsi.EPSInbsample(1:end-1),mod(diff(a.epsi.ramp_count),450));
linkaxes(ax,'x')

