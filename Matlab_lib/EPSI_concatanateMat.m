function EPSI_concatanateMat(Meta_Data)



%  Created by Arnaud Le Boyer on 7/28/18.
%  Copyright © 2018 Arnaud Le Boyer. All rights reserved.

epsiDIR = Meta_Data.Epsipath;
ctdDIR  = Meta_Data.CTDpath;
name_channels=strsplit(Meta_Data.PROCESS.channels,',');


if exist([ctdDIR 'ctd_' Meta_Data.deployement '.mat'],'file')
    fprintf([ 'you already ran EPSI_concatanate \n remove ' ...
        '%sctd_%s.mat \n'],ctdDIR, Meta_Data.deployement)
    fprintf(' and %sepsi_%s.mat \n',epsiDIR, Meta_Data.deployement)
else
    tic
    disp('Start concatanate')

    nbchannels=str2double(Meta_Data.PROCESS.nb_channels);
    listepsi=dir([epsiDIR 'epsi*.mat']);
    listctd=dir([ctdDIR 'ctd*.mat']);
    [~,Iepsi]=sort(datenum(vertcat(listepsi.date)));
    [~,Ictd]=sort(datenum(vertcat(listctd.date)));
    listepsi=listepsi(Iepsi);
    listctd=listctd(Ictd);
    
    C=[];P=[];T=[];ctdtime=[];S=[];sig=[];
    index=[];epsitime=[];sderror=[];chsum1=[];alti=[];chsumepsi=[];
    for n=1:nbchannels
        eval(sprintf('%s=[];',name_channels{n}));
    end
    for f=1:length(listepsi)
        load([epsiDIR  listepsi(f).name],'EPSI');
        load([ctdDIR  listctd(f).name],'AUX');
        C=[C AUX.C];T=[T AUX.T];P=[P AUX.P];ctdtime=[ctdtime AUX.ctdtime];
        S=[S AUX.S];sig=[sig AUX.sig];
        index=[index EPSI.index];epsitime=[epsitime EPSI.epsitime];
        sderror=[sderror EPSI.sderror];chsum1=[chsum1 EPSI.chsum1];
        alti=[alti EPSI.alti];
        chsumepsi=[chsumepsi EPSI.chsumepsi];
        for n=1:nbchannels
            eval(sprintf('%s=[%s EPSI.EPSIchannels(:,n).''];',name_channels{n},name_channels{n}));
        end
        
    end
    
    T=T(~isnan(ctdtime));
    C=C(~isnan(ctdtime));
    S=S(~isnan(ctdtime));
    sig=sig(~isnan(ctdtime));
    P=P(~isnan(ctdtime));
    ctdtime=ctdtime(~isnan(ctdtime));
    
    [ctdtime,IA,~]=unique(ctdtime);
    T=T(IA);
    C=C(IA);
    P=P(IA);
    S=S(IA);
    sig=sig(IA);
    
    
    [ctdtime,Ictdtime]=sort(ctdtime);
    T=T(Ictdtime);
    C=C(Ictdtime);
    P=P(Ictdtime);
    S=S(Ictdtime);
    sig=sig(Ictdtime);
    
    
    
    
    save([ctdDIR 'ctd_' Meta_Data.deployement '.mat'],'ctdtime','C','T','P','S','sig')
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
end


