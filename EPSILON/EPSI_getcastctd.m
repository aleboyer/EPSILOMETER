function [up,down,dataup,datadown] = EPSI_getcastctd(data,crit_speed,crit_filt)

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


% rename variable to make it easy, only for epsiWW
if isfield(data,'info')
    info=data.info;
    data=rmfield(data,'info');
end

% inverse pressure and remove outliers above the std deviation of a sliding window of 20 points
pdata=filloutliers(-data.P,'center','movmedian',20);
tdata=data.ctdtime;

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
                %Start_ind=End_ind;
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

end
