function [up,down,dataup,datadown] = EPSI_getcastctd(Meta_Data,crit_speed,crit_filt,depth_min)

% extract upcast downcast.
% we filt pressure, and find positive and negative chuncks of the pressure
% derivative. Then we iteratively select casts with deltaP (difference between min and max pressure)
% higher the crit (define by user).

% input:
%   data: CTD structure loaded from CTD=load('ctd_deployement.mat'); 
%         It should contain CTD.ctdtime,CTD.P,CTD.T,CTD.S
%  crit_speed: speed criterium to to define starts and ends of a cast
%  crit_filt: number in sample for filter the fall rate (dP/dt) time serie
%  this use to filter out the small fluctuation in the fall rate. 
%  It should be changed when the deployment is not regular.  
% output: 
%   up:       upcasts indexes from the ctd
%   down:     downcasts indexes from the ctd
%   dataup:   data (P,S,T,C,sig,ctdtime) for the upcasts
%   datadown: data (P,S,T,C,sig,ctdtime) for the downcasts

%  Created by Arnaud Le Boyer on 7/28/18.

if nargin<4
    depth_min=10;
end
load(fullfile(Meta_Data.CTDpath,Meta_Data.name_ctd),Meta_Data.name_ctd);
eval(sprintf('data=%s;',Meta_Data.name_ctd));

% rename variable to make it easy, only for epsiWW
if isfield(data,'info')
    info=data.info;
    data=rmfield(data,'info');
end

% inverse pressure and remove outliers above the std deviation of a sliding window of 20 points
pdata=filloutliers(-data.P,'center','movmedian',20);

% if statement to handle EPSI and WW processing
if ~isfield(data,'ctdtime')
    tdata=data.time;
else
    tdata=data.ctdtime;
end

% get time resolution
dt=median(diff(tdata)); % sampling period

T=tdata(end)-tdata(1);  % length of the record
% compute the fall rate
speed=diff(pdata(:))./dt/86400 ;
% remove eventual outliers
speed=filloutliers(speed,'center','movmedian',500);
% remove nans
speed(isnan(speed))=0;

disp('check if time series is shorter than 3 hours')
if T<3/24  
    warning('time serie is less than 3 hours, very short for data processing, watch out the results')
end

% buid a filter
disp('smooth the speed to define up and down cast')
Nb  = 3; % filter order
fnb = 1/(2*dt); % Nyquist frequency
fc  = 1/crit_filt/dt; % 50 dt (give "large scale patern") 
[b,a]= butter(Nb,fc/fnb,'low');
% filt fall rate
filt_speed=filtfilt(b,a,speed);

% we start at the top when the fallrate is higher than the criterium
% and look for the next time the speed is lower than that criteria to end
% the cast.
% we iterate the process to define all the casts
Start_ind    =  find(filt_speed<=-crit_speed,1,'first');
nb_down   =  1;
nb_up     =  1;
do_it        =  0;
cast         = 'down';  

while (do_it==0)
    switch cast
        case 'down'
            End_ind=Start_ind+find(filt_speed(Start_ind+1:end)>-crit_speed,1,'first');
            if ~isempty(End_ind)
                down{nb_down}=Start_ind:End_ind;
                nb_down=nb_down+1;
                Start_ind=End_ind+find(filt_speed(End_ind+1:end)>crit_speed,1,'first');
                cast='up';
            else
                do_it=1;
            end
        case 'up'
            End_ind=Start_ind+find(filt_speed(Start_ind+1:end)<crit_speed,1,'first');
            if ~isempty(End_ind)
                up{nb_up}=Start_ind:End_ind;
                nb_up=nb_up+1;
                Start_ind=End_ind+find(filt_speed(End_ind+1:end)<-crit_speed,1,'first');
                cast='down';
            else
                do_it=1;
            end
    end
    if mod(nb_up,10)==0
        fprintf('Upcast %i\n',nb_up)
        fprintf('Downcast %i \n',nb_up)
    end
end



%once we have the index defining the casts we split the data
dataup=cellfun(@(x) structfun(@(y) y(x),data,'un',0),up,'un',0);
datadown=cellfun(@(x) structfun(@(y) y(x),data,'un',0),down,'un',0);


% select only cast with more than 10 points. 10 points is arbitrary
indPup=find(cellfun(@(x) x.P(1)-x.P(end),dataup)>depth_min);
indPdown=find(cellfun(@(x) x.P(end)-x.P(1),datadown)>depth_min);

datadown=datadown(indPdown);
dataup=dataup(indPup);
down=down(indPdown);
up=up(indPup);

% plot pressure and highlight up /down casts in red/green
close all
plot(tdata,-pdata)
hold on
for i=1:length(up)
    if isfield(data,'ctdtime')
        plot(dataup{i}.ctdtime,dataup{i}.P,'r')
    else
        plot(dataup{i}.time,dataup{i}.P,'r')
    end
end
for i=1:length(down)
    if isfield(data,'ctdtime')
       plot(datadown{i}.ctdtime,datadown{i}.P,'g')
    else
       plot(datadown{i}.time,datadown{i}.P,'g')
    end
end

%MHA: plot ocean style
axis ij

print('-dpng2',[Meta_Data.CTDpath 'Profiles_Pr.png'])


% do we wnat to save or change the speed and filter criteria
answer1=input('save? (yes,no)','s');

%save
switch answer1
    case 'yes'
        
        CTDProfiles.up=up;
        CTDProfiles.down=down;
        CTDProfiles.dataup=dataup;
        CTDProfiles.datadown=datadown;
        filepath=fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']);
        fprintf('Saving data in %s \n',filepath)
        save(filepath,'CTDProfile','-v7.3');
        
        Meta_Data.nbprofileup=numel(CTDProfiles.up);
        Meta_Data.nbprofiledown=numel(CTDProfiles.down);
        Meta_Data.maxdepth=max(cellfun(@(x) max(x.P),CTDProfiles.dataup));
        save(fullfile(Meta_Data.L1path,'Meta_Data.mat'),'Meta_Data')
end



 

end
