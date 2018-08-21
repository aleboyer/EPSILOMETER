function [index,timestamp,sderror,chsum1,alti,chsumepsi,...
          AUX1index,T,C,P,S,sig,...
          EPSIchannels]=parse_epsiblock(Madreblock,Meta_Data)

% . parse 1 epsi block. 
% . read the Header: the epsi sample index, a time stamp, the SD error
% . flag, the AUX1 check sum, the AUX2 check sum or the altimeter and the 
% . EPSI block check sum.
% . if needed read the AUX1 block convert SBE data into celsius, psu, and db 
% . read the epsi block, convert t1,t2,s1,s2 counts into volts and a1,a2,a3
% . into m.s^{-2} (g units) 
      
% . Created by Arnaud Le Boyer on 7/28/18.
      
      
% Madreblock=Madreblocks{1};
% nb_channels = 8;
nb_channels = str2double(Meta_Data.PROCESS.nb_channels);
adcword     = 3; %3 bytes
Nepsisample = 160; % 160 espisample per block
Lepsisample = nb_channels*adcword;
Lepsiblock  = Nepsisample*Lepsisample;

if ~isempty(Meta_Data.SBEcal)
    ind_AUX1   = strfind(Madreblock,'$AUX1');
else
    ind_AUX1   = 62;
end
ind_EPSI   = strfind(Madreblock,'$EPSI');

% exemple Header
% $MADRE   71e80,58da55d9,       9,       0,  229a15,      15
Headerraw = Madreblock(8:ind_AUX1-3); 
if ~isempty(Meta_Data.SBEcal)
    AUX1raw   = Madreblock(ind_AUX1+5:ind_EPSI-2);
end
EPSIraw   = uint8(Madreblock(ind_EPSI+5:end));

%% parse Header
ParsHeader = strsplit(Headerraw,',');
index      = hex2dec(ParsHeader{1});
timestamp  = hex2dec(ParsHeader{2});
sderror    = hex2dec(ParsHeader{3});
chsum1     = hex2dec(ParsHeader{4});
alti       = hex2dec(ParsHeader{5});
chsumepsi  = hex2dec(ParsHeader{6});

%% parse AUXblock
if ~isempty(Meta_Data.SBEcal)
    parse_aux1=arrayfun(@(x) AUX1raw(x:x+24+7-1),1:24+7+2:296,'un',0);
    parse_index=@(x) (hex2dec(x(1:8)));
    parse_sample=@(x) (SBE_interpet(Meta_Data.SBEcal,x(10:end)));
    T=zeros(1,length(parse_aux1))*nan;
    C=zeros(1,length(parse_aux1))*nan;
    P=zeros(1,length(parse_aux1))*nan;
    AUX1index=zeros(1,length(parse_aux1))*nan;
    for j=1:length(parse_aux1)
        if parse_index(parse_aux1{j})>0
            try
                AUX1index(j)=parse_index(parse_aux1{j});
                [T(j),C(j),P(j)]=parse_sample(parse_aux1{j});
            catch
                AUX1index(j)=parse_index(parse_aux1{j-1});
                [T(j),C(j),P(j)]=parse_sample(parse_aux1{j-1});
            end
        end
    end
    T=real(T);C=real(C);
    S=sw_salt(C*10./sw_c3515,T,P);
    sig=sw_pden(S,T,P,0);
else
    AUX1index=(1:9)*nan;T=(1:9)*nan;S=(1:9)*nan;sig=(1:9)*nan;P=(1:9)*nan;C=(1:9)*nan;
end

%% parse EPSIblock
% parse all 160 epsi sample from epsi raw
EPSIblock=arrayfun(@(x) EPSIraw(x:x+Lepsisample-1), ...
                          1:Lepsisample:Lepsiblock,'un',0);
% convert all ADC samples (3 bytes) to a uint32 number of counts 
channel_count=@(x) (cell2mat(arrayfun(@(y)  ...
           (typecast([fliplr(x(y:y+adcword-1)) 0],'uint32')),...
           1:adcword:Lepsisample,'un',0)));
% 
EPSIchannels=cell2mat(cellfun(@(x) channel_count(x),EPSIblock,'un',0).');
EPSIchannels=EPSI_count2volt(EPSIchannels,Meta_Data);
EPSIchannels=EPSI_volt2g(EPSIchannels,Meta_Data);
