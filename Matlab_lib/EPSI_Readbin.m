function [EPSI,AUX,posi]=EPSI_Readbin(file,posi,Meta_Data)
    
%  input: Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%         file
%  path to raw .bin file
%         posi
%  position of the last read of this file. not really usefull so far since
%  I always re-read from the beginning. It will be used if we use bigger
%  raw .bin files
%
%  Created by Arnaud Le Boyer on 7/28/18.

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
        L_Header=61;
        ind_Madreblock=strfind(Allblocks,'$MADRE');
        Start_time=0;
        index_startblock=1;
    end
    L_Madreblock=diff(ind_Madreblock);
    uL_Madreblock=unique(L_Madreblock);
    % Hardcoded good length for a Madre block. it depends on the number of
    % channel, if we send binary or ascii, if we have a sea bird or not.
    % TODO: This can be computed/automatized using Meta_data.dat in raw/
    if ~isempty(Meta_Data.SBEcal)
        L_AUXblock=302;
    else
        L_AUXblock=0;
    end
    
    switch Meta_Data.PROCESS.recording_mode
        case 'SD'
            L_epsiblock=160*3*nb_channels+5+2;
            L_goodMadreblock=L_Header+L_AUXblock+L_epsiblock;
        case 'STREAMING'
            L_epsiblock=160*3*nb_channels+5+2;
            L_goodMadreblock=L_Header+L_AUXblock+L_epsiblock;
    end

    if length(uL_Madreblock)>1
        warning('Blocks are not all the same size, issue in streaming')
        badL=uL_Madreblock(uL_Madreblock~=L_goodMadreblock);
        for i=1:length(badL)
            warning(' % i bad blocks',length(find(L_Madreblock==badL(i))))
        end
    end
    N_goodMadreblock=sum(L_Madreblock==L_goodMadreblock);
    
    ind1_Madreblock=ind_Madreblock(L_Madreblock==L_goodMadreblock);
    % split the data in Madre blocks
    Madreblocks=arrayfun(@(x) Allblocks(x:x+L_goodMadreblock-3),ind1_Madreblock,'un',0);
    posi=ind1_Madreblock(end)+L_goodMadreblock-1;
   % if length(Allblocks)-posi==L_goodMadreblock-2
   if length(Allblocks)-posi==L_goodMadreblock
       N_goodMadreblock=N_goodMadreblock+1;
       Madreblocks{N_goodMadreblock}=Allblocks(ind1_Madreblock(end)+L_goodMadreblock:ind1_Madreblock(end)+2*L_goodMadreblock-3);
       posi=ind1_Madreblock(end)+2*L_goodMadreblock-1;
   end
   fprintf('%i blocks to process \n',N_goodMadreblock);
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
    AUX.index=zeros(1,9*N_goodMadreblock);
    AUX.T=zeros(1,9*N_goodMadreblock);
    AUX.C=zeros(1,9*N_goodMadreblock);
    AUX.P=zeros(1,9*N_goodMadreblock);
    AUX.S=zeros(1,9*N_goodMadreblock);
    AUX.sig=zeros(1,9*N_goodMadreblock);
    EPSI.EPSIchannels=zeros(160*N_goodMadreblock,nb_channels);
    EPSI.epsitime    =zeros(1,160*N_goodMadreblock);
    index1    =zeros(1,160*N_goodMadreblock);

    tic
    for i=1:N_goodMadreblock
        if mod(i,100)==0
            toc
            fprintf('%i over %i\n',i,length(Madreblocks))
            tic
        end
        [EPSI.index(i),EPSI.timestamp(i),EPSI.sderror(i),EPSI.chsum1(i),EPSI.alti(i),EPSI.chsumepsi(i),...
            AUX.index(1+(i-1)*9:i*9),AUX.T(1+(i-1)*9:i*9),AUX.C(1+(i-1)*9:i*9),AUX.P(1+(i-1)*9:i*9),...
            AUX.S(1+(i-1)*9:i*9),AUX.sig(1+(i-1)*9:i*9),...
            EPSI.EPSIchannels(1+(i-1)*160:i*160,:)]=parse_epsiblock(Madreblocks{i}(index_startblock:end),Meta_Data);
        index1(1+(i-1)*160:i*160)=EPSI.index(i)+(1:160)-1; 
    end
end

    




