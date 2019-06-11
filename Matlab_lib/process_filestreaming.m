%function process_filestreaming(datapath,toolpath)

close all

%% open the file
datapath='/Volumes/DataDrive/SODA/epsi_blue_fctd_ALB/fctd_deployment_1/raw/';
toolpath='/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/EPSILON/toolbox';
% open files
id=12;
listfiles=dir(fullfile(datapath,'FCTD_EPSI*.epsi'));
sprintf('read %s',listfiles(id).name)

fid=fopen(fullfile(listfiles(id).folder,listfiles(id).name));


%% plot stuff
addpath(genpath(toolpath));

figure('units','inch','position',[50,0,15,25]);
% Horizontal acceleration a1 a3
ax(1)=subplot('Position',[.3 .83 .6 .1]);
% Vertical acceleration a2
ax(2)=subplot('Position',[.3 .72 .6 .1]);
% shear s1 s2
ax(3)=subplot('Position',[.3 .61 .6 .1]);
% FPO7 t1 t2
ax(4)=subplot('Position',[.3 .5 .6 .1]);
% spectra
ax(5)=subplot('Position',[.3 .05 .6 .4]);
% CTD Temperature and Salinty profil
ax(6)=subplot('Position',[.1 .1 .1 .8]);

%Ylim of the plots
alimm=-1.1;alimp=1.1;
slimm=0;slimp=2.5;
tlimm=0;tlimp=2.5;
splimm=9e-17;splimp=1e-6;

%plot fontsize
fontsize=25;

% prep plott1
cmap=colormap(lines(8));
ylabel(ax(1),'g','FontSize',fontsize)
ylabel(ax(2),'V','FontSize',fontsize)
ylabel(ax(3),'V','FontSize',fontsize)
ylabel(ax(4),'sample','FontSize',fontsize)
ylabel(ax(5),'V^2/Hz','FontSize',fontsize)
for a=1:3
    ax(a).XTickLabel='';
    ax(a).FontSize=fontsize;
end
ax(4).FontSize=fontsize;
xlabel(ax(4),'(seconds)','fontsize',fontsize)

%% preparation of epsi data read and conversion 

% define some important and fixed variable
EPSI.bytes_per_channel=3; % ADC is 3 bytes
EPSI.nbsamples=160;% number of epsi blocks is 160 ~ 0.5 seconds
EPSI.nbblock_diag=10;% 10*.5sec blocks = 5 seconds
EPSI.name_length=5; % 5 bytes EPSI
EPSI.finishblock=2; % 2 bytes \r\n
namechannels={'t1','t2', ...
    's1','s2', ...
    'a1','a2','a3'};
%    'c', ...
countconversion={'Unipolar','Unipolar', ...
    'Unipolar','Unipolar', ...
    'Unipolar', ...
    'Unipolar','Unipolar','Unipolar'};

% to compute salinity
c3515 = 42.914; % from sw libary

% accelerometer Voltage into Accelereation units (in g).
full_range = 2.5;
bit_counts = 24;
gain = 1;
acc_offset = 1.65;
acc_factor = 0.66;


%% set the FFT computation
length_diag=(EPSI.nbblock_diag)*EPSI.nbsamples; % 1760 sample
timeaxis=linspace(0,length_diag/325,length_diag);

% spectrum stuff
% sample rate channels
nb_segment=5;
FS        = 325;
tscan=length_diag./nb_segment/FS;
% number of samples per scan (1s) in channels
df        = 1/tscan;
f=(df:df:FS/2)'; % frequency vector for spectra
data=nan(length(namechannels),nb_segment,length_diag./nb_segment);
Fn    = .5*FS;  % Nyquist frequency
FR    = 2.5;    % Full range in Volts



%% get bench and part noise
logf=log10(f(f>=1/3)); % the noise was a ployfit from spectra computed over 1/3 Hz to 160Hz
%FPO7noise=load(fullfile('..','CALIBRATION','ELECTRONICS','FPO7_noise.mat'),'n0','n1','n2','n3');
% FPO7noise = 
%   struct with fields:
%     n0: -11.7035
%     n1: 0.2758
%     n2: 1.4272
%     n3: -0.8244
n0=-11.7035; n1=0.2758; n2=1.4272; n3=-0.8244;
tnoise=10.^(n0+n1.*logf+n2.*logf.^2+n3.*logf.^3);

%shearnoise=load(fullfile('..','CALIBRATION','ELECTRONICS','shear_noise.mat'),'n0s','n1s','n2s','n3s');
% shearnoise = 
%   struct with fields:
%     n0s: -10.9598
%     n1s: -1.8625
%     n2s: 0.8334
%     n3s: -0.3674
n0s=-10.9598; n1s=-1.8625; n2s=0.8334; n3s=-0.3674;
snoise=10.^(n0s+n1s.*logf+n2s.*logf.^2+n3s.*logf.^3);


def_noise=@(x)((FR/2^x)^2 /Fn);
Accelnoise=45e-6^2+0*f;
set(ax(5),'fontsize',30)
ylabel(ax(5),'V^2 / Hz','fontsize',30)
xlabel(ax(5),'Hz','fontsize',30)
title(ax(1),'Mission whatever','fontsize',25)
grid(ax(5),'on')
% bit noise
n20=loglog(ax(5),f,f*0+def_noise(20),'--','Color',[.5 .5 .5],'linewidth',2);
hold(ax(5),'on')
n24=loglog(ax(5),f,f*0+def_noise(24),'--','Color',[.1 .1 .1],'linewidth',2);
n16=loglog(ax(5),f,f*0+def_noise(16),'.-','Color',[.3 .3 .3],'linewidth',2);
An=loglog(ax(5),f,Accelnoise,'--','Color',[.1 .1 .1],'linewidth',2);
Tnoise=loglog(ax(5),f(f>=1/3),tnoise,'m','linewidth',2);
Snoise=loglog(ax(5),f(f>=1/3),snoise,'c','linewidth',2);
hold(ax(5),'off')


%% Start reading data

% parse the global header-get the SBE cal number at the top of the file
header = epsi_ascii_parseheader(fid);
% EPSI is the main structure containing the data header, aux1, epsi.
% Also contains the length of the header and blocks to set the reading of the binary data
EPSI.header=header.header;

% if EPSI is not empty= we are in a streaming mode because the file have a
% global header
if ~isempty(EPSI)
    %convert time to MATLAB time
    if EPSI.header.offset_time < 0
        EPSI.header.offset_time = epsi_ascii_correct_negative_time(EPSI.header.offset_time)/86400+datenum(1970,1,1);
    else
        EPSI.header.offset_time = EPSI.header.offset_time/86400+datenum(1970,1,1);
    end
    if EPSI.header.system_time < 0
        EPSI.header.system_time = epsi_ascii_correct_negative_time(EPSI.header.system_time)/86400/100+EPSI.header.offset_time;
    else
        EPSI.header.system_time = EPSI.header.system_time/86400/100+EPSI.header.offset_time;
    end
    %length of the time stamp from the C reader during streaming
    EPSI.timestr_length=11;
else
    % no global header but still need SBE cal for EPSIfish mode
    % isfield(Meta_Data,'SBEcal')
    EPSI.header=Meta_Data.SBEcal;
    % deal with \r\n. It is not here when streaming.
    %That is why I set it to -2. Not checked yet 06/06/2019. 
    EPSI.timestr_length=-2;

end
frewind(fid); 

% now we want to open epsi_data.bin read and process the last 5 seconds
% we will plot time series and spectra with 5 seconds length.
begin=0;
while begin==0
    str = fscanf(fid,'%c');
    ind_madre1 = strfind(str,'$MADRE');
    if numel(ind_madre1)>=EPSI.nbblock_diag+1
        ind_aux1 = strfind(str,'$AUX1');
        is_aux1 = contains(str,'$AUX1');
        ind_epsi = strfind(str,'$EPSI');
        %get length of the header
        if is_aux1
            EPSI.headerlength=unique(ind_aux1-ind_madre1-3); %-3 because of $\r\n
            if numel(EPSI.headerlength)>1;warning('different size blocks');end
            %get length of the aux1/CTD block
            EPSI.aux1length=unique(ind_epsi-ind_aux1-2);
        else
            EPSI.headerlength=unique(ind_epsi-ind_madre1-3);%-3 because of $\r\n
            if numel(epsi.headerlength)>1;warning('different size blocks');end
            EPSI.aux1length=0;
        end
        %diagnostic the length of an epsi block. 
        EPSI.epsiblock_length=unique(ind_madre1(2:end)-ind_epsi(1:end-1))-EPSI.timestr_length-EPSI.name_length-2;
        EPSI.nchannels=EPSI.epsiblock_length/EPSI.bytes_per_channel/EPSI.nbsamples;
        if rem(EPSI.nchannels,1)>0
            warning('issue in the epsi blocks. They are not the same length')
        end
        if EPSI.nchannels<numel(namechannels)
              warning('There are only %i channels. What are the channels?',EPSI.nchannels)
              clear namechannels
              for nc=1:EPSI.nchannels
                namechannels{nc}=input(sprintf('Channel %i name \n',nc),'s');
              end
                  
        end
        EPSI.offset=unique(ind_epsi-ind_madre1-1);
        if numel(unique(diff(ind_madre1)))==1
            EPSI.blocksize=unique(diff(ind_madre1)-1);
        else
            EPSI.blocksize=unique(diff(ind_madre1)-1);
        end
    end
    fseek(fid,ind_madre1(end-100)-1,-1);
    begin=1;
end

% define offset if aux1 is present
if is_aux1
    EPSI.aux1.name_length  = 5;
    EPSI.aux1.stamp_length = 8; % length of epsi sample number linked to SBE sample.
    EPSI.aux1.sbe_length   = 22;  % length of SBE sample.
    EPSI.aux1.nbsample     = 9;
    EPSI.aux1_sample_length= EPSI.aux1.stamp_length + 1 + EPSI.aux1.sbe_length + 2;
    % e.g 00000F2E,052C2409E6F3080D7A4DAF
    EPSI.aux1.stamp_offset  = (0:EPSI.aux1.nbsample-1)*EPSI.aux1_sample_length+EPSI.aux1.name_length;
    EPSI.aux1.sbe_offset    = (0:EPSI.aux1.nbsample-1)*EPSI.aux1_sample_length+(EPSI.aux1.stamp_length + 1)+EPSI.aux1.name_length;

    EPSI.aux1.Aux1Stamp=NaN(EPSI.nbblock_diag*EPSI.aux1.nbsample,1);
    EPSI.aux1.T_raw=NaN(EPSI.nbblock_diag*EPSI.aux1.nbsample,1);
    EPSI.aux1.C_raw=NaN(EPSI.nbblock_diag*EPSI.aux1.nbsample,1);
    EPSI.aux1.P_raw=NaN(EPSI.nbblock_diag*EPSI.aux1.nbsample,1);
    EPSI.aux1.PT_raw=NaN(EPSI.nbblock_diag*EPSI.aux1.nbsample,1);
end

action=input('Actions? start read(s),quit(q)','s');
while ~strcmp(action,'q')
    % read 10 blocks
    str   = fscanf(fid,'%c',EPSI.nbblock_diag*EPSI.blocksize-1);
    %we need go after the time stamp added by the C reader
    str1 = fscanf(fid,'%c',EPSI.timestr_length);
    
    if length(str)==EPSI.nbblock_diag*EPSI.blocksize-1
        
        ind_madre = strfind(str,'$MADRE');
        ind_aux1 = strfind(str,'$AUX1');
        ind_epsi = strfind(str,'$EPSI');
        
        %convert 3 bytes ADC samples into 24 bits counts.
        epsi.raw = int32(zeros(EPSI.nbblock_diag,EPSI.epsiblock_length));
        %epsi.raw = cell2mat(arrayfun(@(x) int32(str(x+epsi.name_length-1+(1:epsi.total_length))),ind_epsi(end-epsi.nbblock_diag-1:end-1),'un',0).');
        epsi.raw = cell2mat(arrayfun(@(x) int32(str(x+EPSI.name_length-1+(1:EPSI.epsiblock_length))),ind_epsi,'un',0).');
        epsi.raw1 = epsi.raw(:,1:EPSI.bytes_per_channel:end)*256^2+ ...
            epsi.raw(:,2:EPSI.bytes_per_channel:end)*256+ ...
            epsi.raw(:,3:EPSI.bytes_per_channel:end);
        
        % convert count in volts
        for cha=1:EPSI.nchannels
            wh_channel=namechannels{cha};
            if ~strcmp(wh_channel,'c')
                switch countconversion{cha}
                    case 'Bipolar'
                        EPSI.epsi.(wh_channel)=full_range/gain* ...
                            (double(epsi.raw1(:,cha:EPSI.nchannels:end))/2.^(bit_counts-1)-1);
                    case 'Unipolar'
                        EPSI.epsi.(wh_channel)=full_range/gain* ...
                            double(epsi.raw1(:,cha:EPSI.nchannels:end))/2.^(bit_counts);
                end
                switch wh_channel
                    case {'a1','a2','a3'}
                        EPSI.epsi.(wh_channel) = (EPSI.epsi.(wh_channel)-acc_offset)/acc_factor;
                end
            else
                EPSI.epsi.(wh_channel)=double(epsi.raw1(:,cha:EPSI.nchannels:end));
            end
        end
        EPSI.epsi =structfun(@(x) reshape(x',[],1),EPSI.epsi,'un',0);
        
        if is_aux1
            ind_stamp  = arrayfun(@(x) x+EPSI.aux1.stamp_offset,ind_aux1,'un',0);
            ind_stamp  = [ind_stamp{:}];
            ind_sbe    = arrayfun(@(x) x+EPSI.aux1.sbe_offset,ind_aux1,'un',0);
            ind_sbe    = [ind_sbe{:}];
            
            aux1.stamp = cell2mat(arrayfun(@(x) str(x+(0:EPSI.aux1.stamp_length-1)),ind_stamp,'un',0).');
            aux1.sbe   = cell2mat(arrayfun(@(x) str(x+(0:EPSI.aux1.sbe_length-1)),ind_sbe,'un',0).');
            
            % issues with the SD write and some bytes are not hex. if issues we scan
            % the whole sbe time series to find the bad bytes and then use the average
            % increment from with the previous samples;
            % TO DO get rid of the nameam Tdiff over 10s.
            try
                EPSI.aux1.T_raw = hex2dec(aux1.sbe(:,1:6));
                EPSI.aux1.C_raw = hex2dec(aux1.sbe(:,(1:6)+6));
                EPSI.aux1.P_raw = hex2dec(aux1.sbe(:,(1:6)+12));
                EPSI.aux1.PT_raw = hex2dec(aux1.sbe(:,(1:4)+18));
            catch
                disp('bug in SBE hex bytes')
                for kk=1:size(aux1.stamp,1)
                    if mod(kk,5000)==0
                        fprintf('%u over %u \n',kk,size(aux1.stamp,1));
                    end
                    try
                        EPSI.aux1.T_raw(kk) = hex2dec(aux1.sbe(kk,1:6));
                        EPSI.aux1.C_raw(kk) = hex2dec(aux1.sbe(kk,(1:6)+6));
                        EPSI.aux1.P_raw(kk) = hex2dec(aux1.sbe(kk,(1:6)+12));
                        EPSI.aux1.PT_raw(kk) = hex2dec(aux1.sbe(kk,(1:4)+18));
                    catch
                        EPSI.aux1.T_raw(kk) = EPSI.aux1.T_raw(kk-1)+ ...
                            nanmean(diff(EPSI.aux1.T_raw(kk-10:kk-1)));
                        EPSI.aux1.C_raw(kk) = EPSI.aux1.C_raw(kk-1)+ ...
                            nanmean(diff(EPSI.aux1.C_raw(kk-10:kk-1)));
                        EPSI.aux1.P_raw(kk) = EPSI.aux1.P_raw(kk-1)+ ...
                            nanmean(diff(EPSI.aux1.C_raw(kk-10:kk-1)));
                        EPSI.aux1.PT_raw(kk) =EPSI.aux1.PT_raw(kk-1)+ ...
                            nanmean(diff(EPSI.aux1.PT_raw(kk-10:kk-1)));
                    end
                end
            end
            [EPSI.aux1.Aux1Stamp,ia0,~] =unique(hex2dec(aux1.stamp),'stable');
            %ALB reorder the stamps and samples because until now we kept the zeros
            % in the aux block
            [EPSI.aux1.Aux1Stamp,ia1]=sort(EPSI.aux1.Aux1Stamp);
            EPSI.aux1.T_raw  = EPSI.aux1.T_raw(ia0(ia1));
            EPSI.aux1.C_raw  = EPSI.aux1.C_raw(ia0(ia1));
            EPSI.aux1.P_raw  = EPSI.aux1.P_raw(ia0(ia1));
            EPSI.aux1.PT_raw = EPSI.aux1.PT_raw(ia0(ia1));
            
            EPSI = epsi_ascii_get_temperature(EPSI);
            EPSI = epsi_ascii_get_pressure(EPSI);
            EPSI = epsi_ascii_get_conductivity(EPSI);
            
            %compute salinity
            EPSI.aux1.S=sw_salt(EPSI.aux1.C*10./sw_c3515,EPSI.aux1.T,EPSI.aux1.P);

            % remove bad records for aux1
            ind = EPSI.aux1.Aux1Stamp == 0 & EPSI.aux1.T_raw == 0 & EPSI.aux1.C_raw == 0 & EPSI.aux1.P_raw == 0;
            aux1_fields = fieldnames(EPSI.aux1);
            
            for i  = 12:numel(aux1_fields)
                EPSI.aux1.(aux1_fields{i})(ind) = NaN;
            end

        end
        
        % compute spectra
        data=reshape(struct2array(EPSI.epsi).',[EPSI.nchannels nb_segment length_diag/nb_segment]);
        
        % compute spectra
        [f1,~,P11,~]=get_profile_spectrum(data,f);
        indf1=find(f1>=0);
        indf1=indf1(1:end-1);
        f1=f1(indf1);
        P11= 2*P11(:,:,indf1);
        
        
        % plot epsi time series
        hold(ax(1),'on')
        hold(ax(2),'on')
        hold(ax(3),'on')
        hold(ax(4),'on')
        % plot epsi spectra
        hold(ax(5),'on')

        %leg=zeros(1,EPSI.nchannels);
        leg=[];la;ls=[];lt=[];
        for cha=1:EPSI.nchannels
            wh_channel=namechannels{cha};
            switch wh_channel
                case{'a1','a2','a3'}
                    la1=plot(ax(1),timeaxis,EPSI.epsi.(wh_channel),'Color',cmap(cha,:));
                    la=[la la1];
                    leg(cha)=loglog(ax(5),f1,squeeze(nanmean(P11(cha,:,:),2)),'Color',cmap(cha,:));
                case{'s1','s2'}
                    ls1=plot(ax(2),timeaxis,EPSI.epsi.(wh_channel),'Color',cmap(cha,:));
                    ls=[ls ls1];
                    leg(cha)=loglog(ax(5),f1,squeeze(nanmean(P11(cha,:,:),2)),'Color',cmap(cha,:));
                case{'t1','t2'}
                    lt1=plot(ax(3),timeaxis,EPSI.epsi.(wh_channel),'Color',cmap(cha,:));
                    lt=[lt lt1];
                    leg(cha)=loglog(ax(5),f1,squeeze(nanmean(P11(cha,:,:),2)),'Color',cmap(cha,:));
            end
        end
        if isfield(EPSI.epsi,'c')
            cha=find(cellfun(@(x) strcmp(x,'c'),namechannels));
            plot(ax(4),timeaxis(1:end-1),diff(EPSI.epsi.c),'Color',cmap(cha,:))
        else
            plot(ax(4),timeaxis,nan.*EPSI.epsi.(namechannels{1}))
        end
        

        
        legend(ax(1),{'a1','a2','a3'})
        legend(ax(2),{'t1','t2'})
        legend(ax(3),{'s1','s2'})
        legend(ax(4),{'diff ramp'})
        
        
        set(ax(5),'Xscale','log','Yscale','log')
        legend(ax(5),[leg n24 n20 n16 An Tnoise Snoise],[namechannels,{'24 bit','20 bit','16 bit','Accel noise','Tbench','Sbench'}],'location','SouthWest')
        hold(ax(5),'off')
        ax(5).XLim=[df f(end)];
        grid(ax(5),'on')

        
%         ax(1).YLim=[alimm alimp];
%         ax(2).YLim=[slimm slimp];
%         ax(3).YLim=[tlimm tlimp];
%         ax(4).YLim=[0 2];
        ax(5).YLim=[splimm splimp];
        ax(1).XLim=[0 4];
        ax(2).XLim=[0 4];
        ax(3).XLim=[0 4];
        ax(4).XLim=[0 4];
        for p=1:5
            ax(p).FontSize=20;
        end
        
        ylabel(ax(1),'g','FontSize',20)
        ylabel(ax(2),'V','FontSize',20)
        ylabel(ax(3),'V','FontSize',20)
        ylabel(ax(4),'sample','FontSize',20)
        ylabel(ax(5),'V^2/Hz','FontSize',20)
        
        if is_aux1
            % plot CTD profils
            a=6;
            [ax1,hl1,hl2]=plotxx(EPSI.aux1.T,EPSI.aux1.P,EPSI.aux1.S,EPSI.aux1.P,{'',''},{'',''},ax(a));
            hl1.Marker='d';
            hl2.Marker='d';
            hold(ax1(1),'on')
            ax1(1).YDir='reverse';
            E=scatter(ax1(1),EPSI.aux1.T(end),EPSI.aux1.P(end),100,'k','d','filled');
            hold(ax1(1),'off')
            hold(ax1(2),'on')
            F=scatter(ax1(2),EPSI.aux1.S(end),EPSI.aux1.P(end),100,'k','p','filled');
            hold(ax1(2),'off')
            set(ax1(1),'Xscale','linear','Yscale','linear')
            ax1(1).XTickLabelRotation=25;
            set(ax1(1),'fontsize',15)
            xlabel(ax1(1),'SBE T (C) ','fontsize',fontsize)
            ylabel(ax1(1),'Pr (dBar)')
            grid(ax1(1),'on')
            set(ax1(2),'Xscale','linear','Yscale','linear')
            ax1(2).XTickLabelRotation=25;
            set(ax1(2),'fontsize',15)
            ax1(2).YDir='reverse';
            
            xlabel(ax1(2),'SBE S (psu) ','fontsize',fontsize)
        end
        
        
        
        pause(.0000001)
        % clear the plots
        for l=1:length(leg)
            delete(leg(l))
        end
        for l=1:length(la)
            delete(la(l));
        end
        for l=1:length(lt)
            delete(lt(l));
        end
        for l=1:length(ls)
            delete(ls(l));
        end
        if is_aux1
            delete(hl1)
            delete(hl2)
            cla(ax1(1))
            cla(ax1(2))
            ax1(1).YTickLabel='';
            ax1(2).YTickLabel='';
            ax1(1).XTickLabel='';
            ax1(2).XTickLabel='';
            
            xlabel(ax1(2),'')
        end

    else
        fseek(fid,ind_madre1(end-100)-1,-1);
    end
    if is_aux1
        fprintf('Pressure %3.2f \n',EPSI.aux1.P(end))
    end
    inputemu('key_normal','\ENTER')
    action=input('','s');

    
end

function [k,P1,P11,Co12]=get_profile_spectrum(data,k)
%
%  input: data
% . data : epsi data
% . k:  frequency array 
%  Created by Arnaud Le Boyer on 7/28/18.


    switch length(size(data))
        case 3 % reshape into 2D matrice for fft and then reshape
            [nb_sensor,nb_scan,Lscan]=size(data);
            data=reshape(data,[nb_sensor* nb_scan Lscan]);
            Lax1=nb_sensor* nb_scan;
            size_data=3;
        case 2
            [Lax1,Lscan]=size(data);
            size_data=2;
        otherwise
            warning('no valid size for data : get power spectrum')
    end
    
    dk=k(1);
    window = ones(Lax1,1)*hanning(Lscan).';
    wc2=1/mean(window(1,:).^2);            % window correction factor
    datap  = window.*(data- mean(data,2)* ones(1,Lscan));
    P1  = fft(datap,[],2);
    P11 = conj(P1).*P1./Lscan^2/dk*wc2;
    
    if size_data==3
        P1=reshape(P1,[nb_sensor,nb_scan,Lscan]);
        P11=reshape(P11,[nb_sensor,nb_scan,Lscan]);
        P12=zeros(nb_sensor,nb_sensor-1,nb_scan,Lscan);
        Co12=zeros(nb_sensor,nb_sensor-1,nb_scan,Lscan);
        ind_nbsensor=1:nb_sensor;
        for j=1:nb_sensor
            tempo=shiftdim(repmat(squeeze(P1(j,:,:)),[1,1,nb_sensor-1]),2);
            P12(j,:,:,:)=conj(tempo).*P1(ind_nbsensor~=j,:,:)./Lscan^2/dk*wc2;
            tempo=shiftdim(repmat(squeeze(P11(j,:,:)),[1,1,nb_sensor-1]),2);
            Co12(j,:,:,:)=squeeze(P12(j,:,:,:)).^2./(tempo.*P11(ind_nbsensor~=j,:,:));
        end
    end
    
    if rem(Lscan,2)==0
        k=-Lscan/2*dk:dk:Lscan/2*dk-dk;
    else
        kp=dk:dk:dk*floor(Lscan/2);
        k=[fliplr(-kp) 0 kp];
    end
    k=fftshift(k);



end

%  reads and apply calibration to the temperature data
function EPSI = epsi_ascii_get_temperature(EPSI)

a0 = EPSI.header.ta0;
a1 = EPSI.header.ta1;
a2 = EPSI.header.ta2;
a3 = EPSI.header.ta3;

mv = (EPSI.aux1.T_raw-524288)/1.6e7;
r = (mv*2.295e10 + 9.216e8)./(6.144e4-mv*5.3e5);
EPSI.aux1.T = a0+a1*log(r)+a2*log(r).^2+a3*log(r).^3;
EPSI.aux1.T = 1./EPSI.aux1.T - 273.15;
return;
end

%  reads and apply calibration to the conductivity data
function EPSI = epsi_ascii_get_conductivity(EPSI)
try 
g = EPSI.header.g;
h = EPSI.header.h;
i = EPSI.header.i;
j = EPSI.header.j;
tcor = EPSI.header.tcor;
pcor = EPSI.header.pcor;
catch
g = EPSI.header.cg;
h = EPSI.header.ch;
i = EPSI.header.ci;
j = EPSI.header.cj;
tcor = EPSI.header.ctcor;
pcor = EPSI.header.cpcor;
end

f = EPSI.aux1.C_raw/256/1000;

EPSI.aux1.C = (g+h*f.^2+i*f.^3+j*f.^4)./(1+tcor*EPSI.aux1.T+pcor*EPSI.aux1.P);

return;
end

%  reads and apply calibration to the pressure data
function EPSI = epsi_ascii_get_pressure(EPSI)
% ALB 04112019 Changed EPSI.header.SBEcal. to EPSI.header.
pa0 = EPSI.header.pa0;
pa1 = EPSI.header.pa1;
pa2 = EPSI.header.pa2;
ptempa0 = EPSI.header.ptempa0;
ptempa1 = EPSI.header.ptempa1;
ptempa2 = EPSI.header.ptempa2;
ptca0 = EPSI.header.ptca0;
ptca1 = EPSI.header.ptca1;
ptca2 = EPSI.header.ptca2;
ptcb0 = EPSI.header.ptcb0;
ptcb1 = EPSI.header.ptcb1;
ptcb2 = EPSI.header.ptcb2;


y = EPSI.aux1.PT_raw/13107;

t = ptempa0+ptempa1*y+ptempa2*y.^2;
x = EPSI.aux1.P_raw-ptca0-ptca1*t-ptca2*t.^2;
n = x*ptcb0./(ptcb0+ptcb1*t+ptcb2*t.^2);

EPSI.aux1.P = (pa0+pa1*n+pa2*n.^2-14.7)*0.689476;

return;
end

%  parse all the lines in the header of the file
function EPSI = epsi_ascii_parseheader(fid)
EPSI = [];
fgetl(fid);
s=fgetl(fid);
[v,val]=epsi_ascii_parseheadline(s);
if ~isempty(v)
    eval(['EPSI.header.' lower(v) '=' val ';']);
end
s=fgetl(fid);
if(~strncmp(s,'%*****START_FCTD',16))
    return;
end

s=fgetl(fid);
while ~strncmp(s,'%*****END_FCTD',14) && ~feof(fid)
    [v,val]=epsi_ascii_parseheadline(s);
    if ~isempty(v)
        try
            eval(['EPSI.header.' lower(v) '=' val ';']);
        catch obj
            if strncmp(v,'FCTD_VER',8)
                eval(['EPSI.header.' lower(v) '=''' val ''';']);
            else
                %                 disp(obj.message);
                %                 disp(['Error occured in string: ' s]);
            end
            
        end
    end
    s=fgetl(fid);
    %     strncmp(s,'%*****END_FCTD',14);
end
return;
end

%  parse each line in the header to detect comments
function [v,val]=epsi_ascii_parseheadline(s)
if(isempty(s))
    v = [];
    val = [];
    return;
end
if s(1)~='%'
    
    i = strfind(s,'=');
    v=s(1:i-1);
    val = s(i+1:end);
else
    v=[];
    val=[];
end

return;
end

% end





