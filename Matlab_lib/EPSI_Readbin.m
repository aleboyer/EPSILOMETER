function [EPSI,AUX,posi]=EPSI_Readbin(file,posi,Meta_Data)
    
%  input:
%  output:
%
%  Created by Arnaud Le Boyer on 7/28/18.
%  Copyright © 2018 Arnaud Le Boyer. All rights reserved.

    fprintf('start reading file %s at position %i \n',file,posi);
    fid=fopen(file,'r');
    fseek(fid,posi,'bof'); % start where previous read stopped
    Allblocks=fread(fid,'uint8=>char').';
    posi=ftell(fid);
    fclose(fid);
    
    flagstream=strcmp(Meta_Data.PROCESS.recording_mode,'STREAMING');
    nb_channels=str2double(Meta_Data.PROCESS.nb_channels);
    if flagstream
        L_Header=78;
        ind_Madreblock=strfind(Allblocks,'$TIME');
        Start_time=datenum(datetime( str2double(Allblocks(6:15)), 'ConvertFrom', 'posixtime' ));
        index_startblock=17;
    else
        L_Header=63;
        ind_Madreblock=strfind(Allblocks,'$MADRE');
        Start_time=0;
        index_startblock=1;
    end
    L_Madreblock=diff(ind_Madreblock);
    uL_Madreblock=unique(L_Madreblock);
    % Hardcoded good length for a Madre block. it depends on the number of
    % channel, if we send binary or ascii, if we have a sea bird or not.
    % TODO: This can be computed/automatized using Meta_data.dat in raw/
    %L_epsiblock=160*3*nb_channels+5+2;
    L_epsiblock=160*3*nb_channels+5;
    if ~isempty(Meta_Data.SBEcal)
        L_AUXblock=301;
    else
        L_AUXblock=0;
    end
    L_goodMadreblock=L_Header+L_AUXblock+L_epsiblock+1;
    if length(uL_Madreblock)>1
        warning('Blocks are not all the same size, issue in streaming')
        badL=uL_Madreblock(uL_Madreblock~=L_goodMadreblock);
        for i=1:length(badL)
            warning(' % i is a bad block',find(L_Madreblock==badL(i)))
        end
    end
    N_goodMadreblock=sum(L_Madreblock==L_goodMadreblock)+1;

    fprintf('%i blocks to process \n',N_goodMadreblock);
    ind1_Madreblock=ind_Madreblock(L_Madreblock==L_goodMadreblock);
    % split the data in Madre blocks
    Madreblocks=arrayfun(@(x) Allblocks(x:x+L_goodMadreblock-3),ind1_Madreblock,'un',0);
    posi=ind1_Madreblock(end)+L_goodMadreblock-1;
    if length(Allblocks)-posi==L_goodMadreblock-2
        Madreblocks{N_goodMadreblock}=Allblocks(ind1_Madreblock(end)+L_goodMadreblock:ind1_Madreblock(end)+2*L_goodMadreblock-3);
        posi=ind1_Madreblock(end)+2*L_goodMadreblock-1;
    end
    % Handle the last block. The last block length is L_goodMadreblock - 2 bytes
    % because \r\n come at the begining of the next header. This choice is made
    % in the firmware. Do not be upset, it is no biggy ...
    %nb_channels=8;
    EPSI.index=zeros(1,N_goodMadreblock);
    EPSI.timestamp=zeros(1,N_goodMadreblock);
    EPSI.sderror=zeros(1,N_goodMadreblock);
    EPSI.chsum1=zeros(1,N_goodMadreblock);
    EPSI.alti=zeros(1,N_goodMadreblock);
    EPSI.chsumepsi=zeros(1,N_goodMadreblock);
    AUX.T=zeros(1,9*N_goodMadreblock);
    AUX.C=zeros(1,9*N_goodMadreblock);
    AUX.P=zeros(1,9*N_goodMadreblock);
    AUX.S=zeros(1,9*N_goodMadreblock);
    AUX.sig=zeros(1,9*N_goodMadreblock);
    EPSI.EPSIchannels=zeros(160*N_goodMadreblock,nb_channels);
    EPSI.epsitime    =zeros(1,160*N_goodMadreblock);
    index1    =zeros(1,160*N_goodMadreblock);

    Sampling_freq=str2double(Meta_Data.Firmware.sampling_frequency(1:3));
    tic
    for i=1:N_goodMadreblock
        if mod(i,100)==0
            toc
            fprintf('%i over %i\n',i,length(Madreblocks))
            tic
        end
        [EPSI.index(i),EPSI.timestamp(i),EPSI.sderror(i),EPSI.chsum1(i),EPSI.alti(i),EPSI.chsumepsi(i),...
            AUX1index(1+(i-1)*9:i*9),AUX.T(1+(i-1)*9:i*9),AUX.C(1+(i-1)*9:i*9),AUX.P(1+(i-1)*9:i*9),...
            AUX.S(1+(i-1)*9:i*9),AUX.sig(1+(i-1)*9:i*9),...
            EPSI.EPSIchannels(1+(i-1)*160:i*160,:)]=parse_epsiblock(Madreblocks{i}(index_startblock:end),Meta_Data);
        index1(1+(i-1)*160:i*160)=EPSI.index(i)+(1:160)-1; 
    end
    AUX.ctdtime=Start_time+(AUX1index-EPSI.index(1))/Sampling_freq/86400;
    EPSI.epsitime=double(Start_time+(index1-index1(1))/Sampling_freq/86400); 
end

    




