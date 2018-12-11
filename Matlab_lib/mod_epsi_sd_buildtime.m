function SD=mod_epsi_sd_buildtime(Meta_Data,a)

% a is the product of San's code for exemple see read_10_files_SODA_WW_d2.m)
% Meta_data is the the meta_data of the deployement
% 


SD.madre=a.madre;
% epsi time

name_channels=strsplit(Meta_Data.PROCESS.channels,',');
nbchannels=str2double(Meta_Data.PROCESS.nb_channels);

starttime=Meta_Data.starttime;
timeheader=a.madre.TimeStamp/86400+datenum(1970,1,1);
timeheader=starttime+(timeheader-timeheader(1));

dtimeheader=diff(timeheader);
SD.epsi.epsitime=zeros(1,160*numel(timeheader));
last_t=0;
count=0;
flag_timebug=0;
for t=1:numel(dtimeheader)
    dT=dtimeheader(t);
    if dT==0
        count=count+1;
    end
    if dT>0
        if t==1
            SD.epsi.epsitime(1:160)=timeheader(1)-fliplr(linspace(1/325/86400,.5/86400,160));
        else
            if flag_timebug==0 % normal case
                SD.epsi.epsitime((last_t+1)*160+1:(t+1)*160)=linspace(timeheader(last_t+1)+1/325/86400,timeheader(t+1),160+count*160);
            else   % if the timestamp bug and are decreasing
                SD.epsi.epsitime((last_t+1)*160+1:(t+1)*160)=linspace(timeheader(t+1)-.5/86400,timeheader(t+1),160+count*160);
            end
        end
        last_t=t;
        count=0;
        flag_timebug=0;
    end
    if dT<0
        SD.epsi.epsitime((last_t+1)*160:(t+1)*160)=nan;
        last_t=t;
        count=0;
        flag_timebug=1;
        disp(t)
    end
end

if dtimeheader(1)==0
    SD.epsi.epsitime(1:160)=SD.epsi.epsitime(161) - fliplr(linspace(1/325/86400,.5/86400,160));
end
if dtimeheader(end)==0
    SD.epsi.epsitime(end-(160+count*160)+1:end)=timeheader(end)- fliplr(linspace(1/325/86400,(.5+count*.5)/86400,160+count*160));
end

for n=1:nbchannels
    eval(sprintf('SD.epsi.%s=a.epsi.%s;',name_channels{n},name_channels{n}));
end


ind_OK=find(SD.epsi.epsitime>=SD.epsi.epsitime(1) & SD.epsi.epsitime<max(SD.epsi.epsitime));
epsitime=SD.epsi.epsitime;
SD.epsi.epsitime=SD.epsi.epsitime(ind_OK);
%epsitime=epsitime-epsitime(1);
for n=1:nbchannels
    eval(sprintf('SD.epsi.%s=SD.epsi.%s(ind_OK);',name_channels{n},name_channels{n}));
end
SD.epsi.flagSDSTR=SD.epsi.epsitime*0;


% aux1 time

% because aux1 block has fixed length we may reapted sample from previous
% blocks. or zeros depending on the firmware version
% get the unique samples
[Aux1Stamp,IA]=unique(a.aux1.Aux1Stamp);
% find the aux samples that matches the epsinbsample
[stamp1,iepsi1,iaux1] = intersect(a.epsi.EPSInbsample,Aux1Stamp);
indStamp=IA(iaux1);
% Currently the sample are not monotonicaly increasing. 
% TODO figure out why 
[~,IA]=sort(stamp1);
indStamp=indStamp(IA);

mask=IA*0+1;
mask(epsitime(iepsi1(IA))<datenum('01-01-1970'))=nan;

SD.aux1.T=SBE_temp_v2(Meta_Data.SBEcal,a.aux1.T_raw(indStamp)).*mask;
SD.aux1.P=SBE_Pres_v2(Meta_Data.SBEcal,a.aux1.P_raw(indStamp),a.aux1.PT_raw(indStamp)).*mask;
SD.aux1.C=SBE_cond_v2(Meta_Data.SBEcal,a.aux1.C_raw(indStamp),SD.aux1.T,SD.aux1.P).*mask;
SD.aux1.S=sw_salt(SD.aux1.C*10./sw_c3515,SD.aux1.T,SD.aux1.P);
SD.aux1.sig=sw_pden(SD.aux1.S,SD.aux1.T,SD.aux1.P,0);
SD.aux1.aux1time=epsitime(iepsi1(IA));






