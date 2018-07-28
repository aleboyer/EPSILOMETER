function EPSI_Readbin(file)
    global posi
    
    %file='/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/epsi_raw.dat';
    %posi=0; % embryon of read loop
    fprintf('Posi=%i \n',posi);
    fid=fopen(file,'r');
    fseek(fid,posi,'bof'); % start where previous read stopped
    Allblocks=fread(fid,10*4210,'uint8=>char').';
    posi=ftell(fid);
    fclose(fid);
    ind_Madreblock=strfind(Allblocks,'$MADRE');
    L_Madreblock=diff(ind_Madreblock);
    uL_Madreblock=unique(L_Madreblock);
    % Hardcoded good length for a Madre block. it depends on the number of
    % channel, if we send binary or ascii, if we have a sea bird or not.
    % TODO: This can be computed/automatized using Meta_data.dat in raw/
    L_goodMadreblock=4210;
    if length(uL_Madreblock)>1
        warning('Blocks are not all the same size, issue in streaming')
        badL=uL_Madreblock(uL_Madreblock~=L_goodMadreblock);
        for i=1:length(badL)
            warning(' % i  bad block',find(L_Madreblock==badL(i)))
        end
    end
    N_goodMadreblock=sum(L_Madreblock==L_goodMadreblock);
    %N_goodMadreblock=1000;

    fprintf('%i blocks to process \n',N_goodMadreblock);
    ind1_Madreblock=ind_Madreblock(L_Madreblock==L_goodMadreblock);
    % split the data in Madre blocks
    Madreblocks=arrayfun(@(x) Allblocks(x:x+L_goodMadreblock-3),ind1_Madreblock,'un',0);
    % Handle the last block. The lasdt block length is L_goodMadreblock - 2 bytes
    % because \r\n come at the begining of the next header. This choice is made
    % in the firmware. Do not be upset, it is no biggy ...
    nb_channels=8;
    index=zeros(1,N_goodMadreblock);
    timestamp=zeros(1,N_goodMadreblock);
    sderror=zeros(1,N_goodMadreblock);
    chsum1=zeros(1,N_goodMadreblock);
    alti=zeros(1,N_goodMadreblock);
    chsumepsi=zeros(1,N_goodMadreblock);
    AUX1index=zeros(N_goodMadreblock);
    AUX1sample=char(zeros(9*N_goodMadreblock,22));
    EPSIchannels=zeros(160*N_goodMadreblock,nb_channels);

    tic
    for i=1:N_goodMadreblock
        if mod(i,100)==0
            toc
            fprintf('%i over %i\n',i,length(Madreblocks))
            tic
        end
        [index(i),timestamp(i),sderror(i),chsum1(i),alti(i),chsumepsi(i),...
            AUX1index(1+(i-1)*9:i*9),AUX1sample(1+(i-1)*9:i*9,:),...
            EPSIchannels(1+(i-1)*160:i*160,:)]=parse_epsiblock(Madreblocks{i},nb_channels);
    end
end

    




