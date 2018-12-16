function Meta_Data=create_Meta_Data(file)

% . input: file
% . path toward the Meta_Data .dat file you want to process
% . output: Meta_Data.
% . Meta_Data contain the path to calibration file and EPSI configuration
% . needed to process the epsi data

%  Created by Arnaud Le Boyer on 7/28/18.


fid=fopen(file,'r');
count=0;
while(count<10)
    l=fgetl(fid);
    spl=strsplit(l,':');
    Meta_Data.(strtrim(spl{1}))=strtrim(spl{2});
    count=count+1;
end
%% PROCESS
fgetl(fid); % empty line
l    = fgetl(fid); % PROCESS
spl  = strsplit(l,':');
count=0;
while(count<3)
    l    = fgetl(fid); % PROCESS fields
    spl1 = strsplit(l,':');
    Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1}))=strtrim(spl1{2});
    count=count+1;
end



%% MADRE
fgetl(fid); % empty line
l    = fgetl(fid); % MADRE
spl  = strsplit(l,':');
count=0;
while(count<2)
    l    = fgetl(fid); % MADRE fields
    spl1 = strsplit(l,':');
    Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1}))=strtrim(spl1{2});
    count=count+1;
end

%% MAP
fgetl(fid); % empty line
l    = fgetl(fid); % MAP
spl  = strsplit(l,':');
count=0;
while(count<2)
    l    = fgetl(fid); % MAP fields
    spl1 = strsplit(l,':');
    Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1}))=strtrim(spl1{2});
    count=count+1;
end
%% firmware
fgetl(fid); % empty line
l    = fgetl(fid); % firmware
spl  = strsplit(l,':');
count=0;
while(count<6)
    l    = fgetl(fid); % firmware fields
    spl1 = strsplit(l,':');
    Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1}))=strtrim(spl1{2});
    count=count+1;
end

%% aux1
fgetl(fid); % empty line
l    = fgetl(fid); % aux1
spl  = strsplit(l,':');
count=0;
while(count<3)
    l    = fgetl(fid); % aux1 fields 
    spl1 = strsplit(l,':');
    Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1}))=strtrim(spl1{2});
    count=count+1;
end

%% epsi
fgetl(fid); % empty line
l    = fgetl(fid); % epsi
spl  = strsplit(l,':');
count=0;

%s1 
l    = fgetl(fid); % epsi field s1
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  s1 field SN
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  s1 field Sv
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  s1 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  s1 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});


%s2 
l    = fgetl(fid); % epsi field s2
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  s2 field SN
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  s2 field Sv
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  s2 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  s2 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});


%t1 
l    = fgetl(fid); % epsi field t1
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  t1 field SN
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  t1 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  t1 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});


%t2 
l    = fgetl(fid); % epsi field t2
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  t2 field SN
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  t2 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  t2 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});

%c 
l    = fgetl(fid); % epsi field c
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  c field SN
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  c field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  c field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});

%a1 
l    = fgetl(fid); % epsi field a1
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  a1 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  a1 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});

%a2 
l    = fgetl(fid); % epsi field a2
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  a2 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  a2 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});

%a3 
l    = fgetl(fid); % epsi field a3
spl1 = strsplit(l,':');
l    =fgetl(fid);  %  a3 field ADCfilter
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});
l    =fgetl(fid);  %  a3 field ADCconf
spl2 = strsplit(l,':');
Meta_Data.(strtrim(spl{1})).(strtrim(spl1{1})).(strtrim(spl2{1}))=strtrim(spl2{2});


fclose(fid);

Meta_Data.CALIpath='CALIBRATION/ELECTRONICS/';

Meta_Data
save([Meta_Data.RAWpath ...
    'Meta_' Meta_Data.mission ...
    '_' Meta_Data.deployment '.mat'],'Meta_Data')
