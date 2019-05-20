function [fig,ax]=mod_plot_epsi_timeseries(Meta_Data,EpsiProfile,CTDProfile,Pr,tscan)

% nbscan number of segment
% tscan length of a segment in second
% Pr: pressure around which the diagnostic is performed. Pr can be an
% array
% Epsi and CTD Profiles are the Epsi and CTD time series 

nb_Pr=numel(Pr);

if max(Pr)>max(CTDProfile.P)
    error('The profile does is not deep enough. Select a pressure within %3.2fm %3.2fm',min(CTDProfile.P),max(CTDProfile.P));
end
timeaxis=86400*(EpsiProfile.epsitime-EpsiProfile.epsitime(1));
if isfield(CTDProfile,'ctdtime')
    speed=diff(CTDProfile.P)./diff(CTDProfile.ctdtime*86400);
    CTDtimeaxis=86400*(CTDProfile.ctdtime(2:end)-CTDProfile.ctdtime(1));
else
    CTDtimeaxis=86400*(CTDProfile.time(2:end)-CTDProfile.time(1));
    speed=diff(CTDProfile.P)./diff(CTDProfile.time*86400);
end

%% spectra param

epsi_df = 1./nanmean(diff(EpsiProfile.epsitime*86400));
% define parameters to compute the spectra.
epsi_Lscan  = floor(tscan*epsi_df);  
epsi_T      = length(EpsiProfile.epsitime);
k=make_kaxis(tscan,epsi_df);
LK=numel(k);


%% depending on the casrt direction up or down
if sign(mean(speed))==1 % downcast
    % find the CTD time and epsi index of the defined Pr.
    time_Pr = arrayfun(@(x) (CTDtimeaxis(find(CTDProfile.P>=x,1,'first'))),Pr);
else % upcast
    % find the CTD time and epsi index of the defined Pr.
    time_Pr = arrayfun(@(x) (CTDtimeaxis(find(CTDProfile.P>=x,1,'last'))),Pr);
end
ind_Pr  = arrayfun(@(x) (find(timeaxis<=x,1,'last')),time_Pr);
    


% define frequnecy axis for ctd and epsi spectra.
epsi_indscan = arrayfun(@(x) (x+(-floor(epsi_Lscan/2):floor(epsi_Lscan/2))),ind_Pr,'un',0);
epsi_indscan = cellfun(@(x) (x(1:LK)),epsi_indscan,'un',0);
%% split data into segments for 1st time split
data_a1 = cell2mat(cellfun(@(x) filloutliers( ...
                EpsiProfile.a1(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_a2 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.a2(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_a3 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.a3(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';
data_s1 = cell2mat(cellfun(@(x) filloutliers( ...
                 EpsiProfile.s1(x),'center','movmedian',5), ...
                 epsi_indscan,'un',0)).';

Pa1=2*alb_power_spectrum(data_a1,1./tscan);
Pa2=2*alb_power_spectrum(data_a2,1./tscan);
Pa3=2*alb_power_spectrum(data_a3,1./tscan);
Ps1=2*alb_power_spectrum(data_s1,1./tscan);



%%
close all
cmap1=colormap(lines(11));
cmap2=gray(nb_Pr*3+5);

a1Col=cmap1(1,:);
a2Col=cmap1(3,:);
a3Col=cmap1(5,:);
s1Col=cmap1(7,:);
speedCol=cmap1(9,:);
prCol=cmap1(11,:);

for p=1:nb_Pr
    sp(p,:)=cmap2(p*3,:);
end


% first plots: time series
space1=.02;
height1=.06;
y_pos=.6 + [0 (height1+space1)*(1:4)];
for a=1:5
    ax(a)=subplot('Position',[.1 y_pos(6-a) .8 .06]);%accell horizontal
end

% second plots spectra. rows of 3 columns
nb_column=3;
nb_row=ceil(nb_Pr/nb_column);
width2=.80/nb_column;
space2=.02;
height2=.5/nb_row-(space2*nb_row)
% 
% for p=1:length(Pr) % create row of 3 columns plot
%     id_row=floor(p/(nb_column+1));
%      ax(p)=subplot('Position',[.08 .05+id_row*height2 width2 .33]);%spectra1
% end

ax(6)=subplot('Position',[.08 .05 width2 .33]);%spectra1
ax(7)=subplot('Position',[.38 .05 width2 .33]);%spectra2
ax(8)=subplot('Position',[.70 .05 width2 .33]);%spectra3

lpr=plot(ax(1),CTDtimeaxis,CTDProfile.P(1:end-1),'Color',prCol,'linewidth',2);
lspeed=plot(ax(2),CTDtimeaxis,smoothdata(speed,'movmedian',10),'Color',speedCol,'linewidth',2);
la1=plot(ax(3),timeaxis,EpsiProfile.a1,'Color',a1Col,'linewidth',2);
hold(ax(3),'on')
la3=plot(ax(3),timeaxis,EpsiProfile.a3,'Color',a3Col,'linewidth',2);
hold(ax(3),'off')
la2=plot(ax(4),timeaxis,EpsiProfile.a2,'Color',a2Col,'linewidth',2);
ls1=plot(ax(5),timeaxis,EpsiProfile.s1,'Color',s1Col,'linewidth',2);
linkaxes(ax(1:5),'x')


ylabel(ax(1),'db','fontsize',20)
ylabel(ax(2),'m/s','fontsize',20)
ylabel(ax(3),'g','fontsize',20)
ylabel(ax(4),'g','fontsize',20)
ylabel(ax(5),'Volt','fontsize',20)

ax(1).XTick=unique(floor(linspace(0,floor(timeaxis(end)),10)));
ax(2).XTick=ax(1).XTick;
ax(3).XTick=ax(1).XTick;
ax(4).XTick=ax(1).XTick;

ax(1).XTickLabel='';
ax(2).XTickLabel='';
ax(3).XTickLabel='';
ax(4).XTickLabel='';

for a=1:5
    hold(ax(a),'on')
    for p=1:nb_Pr
        h(p)=fill(ax(a),timeaxis(epsi_indscan{p}([1 1 end end])),[ax(a).YLim ax(a).YLim([2 1])],sp(p,:));
        h(p).FaceAlpha=.5;
    end
    hold(ax(a),'off')
    p1=get(ax(a),'Children');
    switch a
        case 3
            set(ax(a),'Children',[p1(nb_Pr+2); p1(nb_Pr+1);  p1(1:nb_Pr)])
        otherwise
            set(ax(a),'Children',[p1(nb_Pr+1); p1(1:nb_Pr)])
    end
    ax(a).FontSize=20;

end

xlabel(ax(a),[datestr(EpsiProfile.epsitime(1),'mm-dd HH:MM:SS') '  (seconds)'])

legend(ax(1),lpr,'Pr')
legend(ax(2),lspeed,'speed')
legend(ax(3),[la1 la3],'a1','a3')
legend(ax(4),la2,'a2')
legend(ax(5),ls1,'s1')


for a=6:6+(nb_Pr-1)
    p=a-5;
    ls1=loglog(ax(a),k,Ps1(p,:),'Color',s1Col,'linewidth',2);
    hold(ax(a),'on')
    loglog(ax(a),k,Pa1(p,:),'Color',a1Col,'linewidth',2)
    loglog(ax(a),k,Pa2(p,:),'Color',a2Col,'linewidth',2)
    loglog(ax(a),k,Pa3(p,:),'Color',a3Col,'linewidth',2)
    hold(ax(a),'off')
    grid(ax(a),'on')
    ax(a).Color=[sp(p,:) .5];
    ax(a).XScale='log';
    ax(a).YScale='log';
    ax(a).FontSize=20;
    ax(a).YLim=[1e-12 1e-2];
    xlabel(ax(a),'Hz','FontSize',20)
    ylabel(ax(a),'g^2/Hz','FontSize',20)
    switch a
        case 6
            lngd=legend(ax(a),ls1,'Volt^2/Hz','location','southwest');
            set(lngd,'Color','w')
    end
end

fig=gcf;fig.PaperPosition=[0 0 25 18];
fig.InvertHardcopy = 'off'; % to keep the background color of the spectra
print('-dpng2',fullfile(Meta_Data.L1path,...
    ['vehicle_behavior_' ...
    datestr(EpsiProfile.epsitime(1),'yyyymmddHHMMSS') ...
    '.png']))

% saveas(fig,'analyse_P107.png')

