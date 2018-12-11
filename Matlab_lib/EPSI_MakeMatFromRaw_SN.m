function EPSI_MakeMatFromRaw_SN(Meta_Data)

% dirname = '/Volumes/DataDrive/SODA/ww_deployment_2/';
% suffixe = '*.dat'
epsiDIR=Meta_Data.Epsipath;
filenames = dir(fullfile(epsiDIR,Meta_Data.suffixe));
filenames = struct2cell(filenames);
% 
filenames = filenames(1,:);
filenames=natsortfiles(filenames);

% sort file bby date time
%filedates = cell2mat(filenames(6,:));
%[filedates, indx] = sort(filedates);
%filenames = filenames(indx);

for i = 1:numel(filenames)
    filenames{i} = fullfile(dirname,filenames{i});
end

% read file 1 to 10 (change 1 to 10 to read another subset)
a = mod_read_epsi_raw(filenames(1:end));

EPSI=a.epsi;
AUX=a.epsi;


[ctdtime,Ictdtime]=sort(ctdtime);
T=T(Ictdtime);
C=C(Ictdtime);
P=P(Ictdtime);
S=S(Ictdtime);
sig=sig(Ictdtime);

name_channels=strsplit(Meta_Data.PROCESS.channels,',');
nbchannels=str2double(Meta_Data.PROCESS.nb_channels);



save([ctdDIR 'ctd_' Meta_Data.deployement '.mat'],'ctdtime','C','T','P','S','sig','lastfile')
command=[];
for n=1:nbchannels
    command=[command ',' sprintf('''%s''',name_channels{n})];
end
command=['''index'',''epsitime'',''sderror'',''chsum1'',''alti'',''chsumepsi''' command];
command=sprintf('save(''%sepsi_%s.mat'',%s)',epsiDIR,Meta_Data.deployement,command);
eval(command);
disp('stop concatanate')
toc
end

