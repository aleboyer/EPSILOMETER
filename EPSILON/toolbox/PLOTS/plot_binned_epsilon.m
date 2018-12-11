function [F1,F2]=plot_binned_epsilon(Epsilon_class,title_string,F1,F2)

%  input: 
%  Epsilon_class : averaged temperature gradiant spectra classified by epsilon value
%  title_string: title of the plot
%  indplot: index of the epsilon value you want to plot (TODO: directly the epsilon values instead of the indexes)
%
%  Created by Arnaud Le Boyer on 7/28/18.


figure(F1)
set(F1,'position',[100 50 1300 700])
ax1=axes('position',[.1 .1 .55 .82]);
cmap = parula(length(Epsilon_class.bin)+1);

pp = loglog(ax1,Epsilon_class.kpan.',Epsilon_class.Ppan.','color',[1 1 1]*.7,'linewidth',1);
ll=pp;

mink=Epsilon_class.k(find(~isnan(nansum(Epsilon_class.mPshear1,1)),1,'first'));
maxk=Epsilon_class.k(find(~isnan(nansum(Epsilon_class.mPshear1,1)),1,'last'));
minP=min(Epsilon_class.mPshear1(:));
maxP=max(Epsilon_class.mPshear1(:));

hold on
for i=1:length(Epsilon_class.bin)
    indk=find(~isnan(Epsilon_class.Ppan(i,:)),1,'first');
    if Epsilon_class.kpan(i,indk)<=mink
        text(mink, ...
            Epsilon_class.Ppan(i,indk),...
            sprintf('10^{%1.1f}',log10(Epsilon_class.bin(i))),...
            'fontsize',20,'Parent',ax1)
    else
        text(Epsilon_class.kpan(i,indk), ...
            Epsilon_class.Ppan(i,indk),...
            sprintf('10^{%1.1f}',log10(Epsilon_class.bin(i))),...
            'fontsize',20,'Parent',ax1)
    end
    ll(i)=loglog(ax1,Epsilon_class.k,Epsilon_class.mPshear1(i,:),'Color',cmap(i,:),'linewidth',2);
end

xlim(ax1,[mink maxk])
ylim(ax1,[minP maxP])
grid(ax1,'on')
xlabel(ax1,'k [cpm]')
ylabel(ax1,'[s^{-2} / cpm]')
set(ax1,'fontsize',20)
title(ax1,[title_string '- Shear1'])

nanind=find(nansum(Epsilon_class.mPshear1,2)>0);
legend_string=arrayfun(@(x) sprintf('log_{10}(\\epsilon)~%2.1f',x),log10(Epsilon_class.bin),'un',0);
hl=gridLegend(ll(nanind),2,legend_string{nanind},'location','northwest');
set(hl,'fontsize',10)

ax2=axes('position',[.7 .1 .25 .82]);

plot(ax2,log10(Epsilon_class.bin),Epsilon_class.nbin1,'-+k')
set(ax2,'fontsize',20)
xlabel(ax2,'log_{10} \epsilon')
xlim([min(log10(Epsilon_class.bin)) max(log10(Epsilon_class.bin))])
title(ax2,'PDF \epsilon_1')


figure(F2)

set(F2,'position',[100 50 1300 700])
ax3=axes('position',[.1 .1 .55 .82])
cmap = parula(length(Epsilon_class.bin)+1);

pp = loglog(ax3,Epsilon_class.kpan.',Epsilon_class.Ppan.','color',[1 1 1]*.7,'linewidth',1);
ll=pp;

mink=Epsilon_class.k(find(~isnan(nansum(Epsilon_class.mPshear2,1)),1,'first'));
maxk=Epsilon_class.k(find(~isnan(nansum(Epsilon_class.mPshear2,1)),1,'last'));
minP=min(Epsilon_class.mPshear2(:));
maxP=max(Epsilon_class.mPshear2(:));

hold on
for i=1:length(Epsilon_class.bin)
    indk=find(~isnan(Epsilon_class.Ppan(i,:)),1,'first');
    if Epsilon_class.kpan(i,indk)<=mink
        text(mink, ...
            Epsilon_class.Ppan(i,indk),...
            sprintf('10^{%1.1f}',log10(Epsilon_class.bin(i))),...
            'fontsize',20,'Parent',ax3)
    else
        text(Epsilon_class.kpan(i,indk), ...
            Epsilon_class.Ppan(i,indk),...
            sprintf('10^{%1.1f}',log10(Epsilon_class.bin(i))),...
            'fontsize',20,'Parent',ax3)
    end
    ll(i)=loglog(ax3,Epsilon_class.k,Epsilon_class.mPshear2(i,:),'Color',cmap(i,:),'linewidth',2);
end

xlim(ax3,[mink maxk])
ylim(ax3,[minP maxP])
grid(ax3,'on')
xlabel(ax3,'k [cpm]')
ylabel(ax3,'[s^{-2} / cpm]')
set(ax3,'fontsize',20)
title(ax3,[title_string '- Shear2'])

nanind=find(nansum(Epsilon_class.mPshear2,2)>0);
legend_string=arrayfun(@(x) sprintf('log_{10}(\\epsilon)~%2.1f',x),log10(Epsilon_class.bin),'un',0);
hl=gridLegend(ll(nanind),2,legend_string{nanind},'location','northwest');
set(hl,'fontsize',10)

ax4=axes('position',[.7 .1 .25 .82]);

plot(ax4,log10(Epsilon_class.bin),Epsilon_class.nbin2,'-+k')
set(ax4,'fontsize',20)
xlabel(ax4,'log_{10} \epsilon')
xlim(ax4,[min(log10(Epsilon_class.bin)) max(log10(Epsilon_class.bin))])
title(ax4,'PDF \epsilon_2')


