function Meta_Data=EPSI_MakeMatFromRaw(Meta_Data)
%
%  EPSI_MakeMatFromRaw
%  convert all epsi binary files into .mat files

%  input: Meta_Data created from create_Meta_Data
%         read the most recent file in the raw folder
%         store in epsi and ctd folder the data in .mat format 
%  output: Meta_Data, add SBEcal filed if necessary

%  Created by Arnaud Le Boyer on 7/28/18.
%  Copyright � 2018 Arnaud Le Boyer. All rights reserved.


if strcmp(Meta_Data.aux1.SN,'0000')==0
    Meta_Data.SBEcal=get_CalSBE(Meta_Data.aux1.cal_file);
else
    Meta_Data.SBEcal=[];
end
switch Meta_Data.PROCESS.recording_mode
    case 'SD'
        rawDIR=Meta_Data.SDRAWpath;
    case 'STREAMING'
        rawDIR=Meta_Data.RAWpath;
end
epsiDIR=Meta_Data.Epsipath;
ctdDIR=Meta_Data.CTDpath;
listraw=dir([rawDIR '*bin']);
listmat=dir([epsiDIR '*.mat']);
[dateraw,Iraw]=sort(datenum(vertcat(listraw.date)));
[datemat,~]=sort(datenum(vertcat(listmat.date)));

listraw=listraw(Iraw);

if isempty(dateraw)
    fprintf('no .bin file data in %s \n',rawDIR)
end
if isempty(datemat)
    fprintf('no .mat file in %s \n',epsiDIR)
    fprintf('start convert raw file in %s \n', rawDIR)
    for f=1:length(listraw)
        posi_start=0;
        file=[rawDIR listraw(f).name];
        [EPSI,AUX,posi]=EPSI_Readbin(file,posi_start,Meta_Data);
        save([epsiDIR 'epsi_raw' listraw(f).name(end-6:end-3) 'mat'],'EPSI');
        save([ctdDIR  'ctd_raw' listraw(f).name(end-6:end-3) 'mat'],'AUX');
        save([epsiDIR 'lastreadfile.mat'],'file','posi','f');
    end
else
    load([epsiDIR 'lastreadfile.mat'],'file','f');
    disp(f)
    for f=f:length(listraw)
        posi_start=0;
        file=[rawDIR listraw(f).name];
        [EPSI,AUX,posi]=EPSI_Readbin(file,posi_start,Meta_Data);
        save([epsiDIR 'epsi_raw' listraw(f).name(end-6:end-3) 'mat'],'EPSI');
        save([ctdDIR  'ctd_raw' listraw(f).name(end-6:end-3) 'mat'],'AUX');
        save([epsiDIR 'lastreadfile.mat'],'file','posi','f');
    end

    
end
end