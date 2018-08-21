function Quality_check_profile(Profile,MS,Meta_Data,Fcut_epsilon,flag_vehicle,id_profile)

% plot quality check plots
% pressure, speed, frequency spectra, coherence,
% flag_vehicle -1 for WW and 1 for epsifish
tscan=15;
Sv=[str2double(Meta_Data.epsi.s1.Sv), ...
    str2double(Meta_Data.epsi.s2.Sv) ];

%% get channels
channels=strsplit(Meta_Data.PROCESS.channels,',');
nb_channels=length(channels);


try
    clear data
    
    % for WW
    f=1/15:1/15:325/2;
    
    % Gravity  ... of the situation :)
    G       = 9.81;
    
    % Length of the Profile
    T       = length(Profile.epsitime);
    df      = f(1);
    % define number of scan in the profile
    Lscan   = tscan*2*f(end);
    nbscan  = floor(T/Lscan);
    
    % we compute spectra on scan with 50% overlap
    nbscan=2*nbscan-1;
    
    % define the fall rate of the Profile.
    %  Add Profile.w with w the vertical vel.
    %  We are using the pressure from other sensors (CTD);
    Profile = compute_fallrate_downcast(Profile);
    Profile.w=flag_vehicle*Profile.w;
    if nanmedian(Profile.w)>10
        Profile.w=Profile.w/100;
    end
    
    % on line calibration of the FPO7s
    if isfield(Profile,'t1')
        ind_nonan1=find(~isnan(Profile.t1));
        CALFPO7_1=polyfit(Profile.t1(ind_nonan1),Profile.T(ind_nonan1),3);
    end
    if isfield(Profile,'t2')
        ind_nonan2=find(~isnan(Profile.t2));
        CALFPO7_2=polyfit(Profile.t2(ind_nonan2),Profile.T(ind_nonan2),3);
    end
    
    All_channels=fields(Profile);
    for c=1:length(All_channels)
        wh_channels=All_channels{c};
        Profile.(wh_channels)=fillmissing(Profile.(wh_channels),'linear');
        Profile.(wh_channels)=filloutliers(Profile.(wh_channels),'linear');
    end
    
    
    %% define the index in the profile for each scan
    total_indscan = arrayfun(@(x) (1+floor(Lscan/2)*(x-1):1+floor(Lscan/2)*(x-1)+Lscan-1),1:nbscan,'un',0);
    total_w       = cellfun(@(x) nanmean(Profile.w(x)),total_indscan);
    
    ind_downcast = find((total_w)>.20);
    nbscan=length(ind_downcast);
    
    MS1.indscan    = total_indscan(ind_downcast);
    MS1.nbscan    = nbscan;
    MS1.fmax      = Fcut_epsilon; % arbitrary cut off frequency usually extract from coherence spectra shear/accel
    MS1.nbchannel = nbscan;
    
    MS1.w       = cellfun(@(x) nanmean(Profile.w(x)),total_indscan(ind_downcast));
    MS1.t       = cellfun(@(x) nanmean(Profile.T(x)),total_indscan(ind_downcast)); % needed to compute Kvis
    MS1.s       = cellfun(@(x) nanmean(Profile.S(x)),total_indscan(ind_downcast)); % needed to compute Kvis
    MS1.pr      = cellfun(@(x) nanmean(Profile.P(x)),total_indscan(ind_downcast)); % needed to compute Kvis
    MS1.time    = cellfun(@(x) nanmean(Profile.epsitime(x)),total_indscan(ind_downcast)); % needed to compute Kvis
    
    
    
    data=zeros(nb_channels,nbscan,Lscan);
    for c=1:length(All_channels)
        wh_channels=All_channels{c};
        ind=find(cellfun(@(x) strcmp(x,wh_channels),channels));
        switch wh_channels
            case 't1'
                data(ind,:,:) = cell2mat(cellfun(@(x) ...
                    polyval(CALFPO7_1,Profile.t1(x)),MS1.indscan,'un',0).');
            case 't2'
                data(ind,:,:) = cell2mat(cellfun(@(x) ...
                    polyval(CALFPO7_2,Profile.t2(x)),MS1.indscan,'un',0).');
            case {'s1','s2'}
                data(ind,:,:) = cell2mat(cellfun(@(x) Profile.(wh_channels)(x),MS1.indscan,'un',0).');
            case {'a1','a2','a3'}
                data(ind,:,:) = cell2mat(cellfun(@(x,y) Profile.(wh_channels)(x)./y,MS1.indscan,num2cell(MS1.w),'un',0).');
        end
    end
    
    % Profile Power and Co spectrum and Coherence. (Coherence still needs to be averaged over few scans afterwork)
    [f1,P1,P11,Co12]=get_profile_spectrum(data,f);
    %TODO comment on the Co12 sturcutre and think about reducing the size of
    %the Coherence spectra (doublon)
    
    indf1=find(f1>=0);
    indf1=indf1(1:end-1);
    f1=f1(indf1);
    Lf1=length(indf1);
    
    P11=2*P11(:,:,indf1);
    %% get MADRE filters
    h_freq=get_filters_MADRE(Meta_Data,f1);
    
    %% correct transfert functions for accel spectra
    P11(5:7,:,:)=P11(5:7,:,:)./...
        shiftdim(repmat(ones(nbscan,1)*h_freq.electAccel,[1,1,3]),2).^2;
    
    %% correct transfert functions for shear spectra
    
    TF1 =@(x) (Sv.'.*x/(2*G)).^2 .* h_freq.shear .* haf_oakey(f1,x);     % should add epsi filter
    TFshear=cell2mat(cellfun(@(x) TF1(x),num2cell(MS1.w),'un',0).');
    TFshear=reshape(TFshear,[2,nbscan,Lf1]);
    P11(3:4,:,:) = P11(3:4,:,:) ./ TFshear;      % vel frequency spectra m^2/s^-2 Hz^-1
    
    %% correct transfert functions for temperature spectra
    Emp_Corr_fac=1;
    TFtemp=cell2mat(cellfun(@(x) h_freq.FPO7(x),num2cell(MS1.w),'un',0).');
    TFtemp=shiftdim(repmat(TFtemp,[1,1,2]),2);
    P11(1:2,:,:) = Emp_Corr_fac * P11(1:2,:,:)./TFtemp;
    
    %f=1/3:1/3:320/2;
    %Epsilon_corrected=calc_eps_epsi_accel_corrected(Profile,3,f,Sv);
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    ax(1)=subplot('Position',[.48 .62 .5 .3]);
    loglog(f(1:end-1),smoothdata(nanmedian(squeeze(P11(3,:,:)))),'linewidth',2)
    hold on
    loglog(f(1:end-1),smoothdata(nanmedian(squeeze(P11(4,:,:)))),'linewidth',2)
    loglog(f(1:end-1),smoothdata(nanmedian(squeeze(P11(5,:,:)))),'linewidth',2)
    loglog(f(1:end-1),smoothdata(nanmedian(squeeze(P11(6,:,:)))),'linewidth',2)
    loglog(f(1:end-1),smoothdata(nanmedian(squeeze(P11(7,:,:)))),'linewidth',2)
    
    minY=min(smoothdata(nanmedian(squeeze(P11(3,:,:)))));
    maxY=max(smoothdata(nanmedian(squeeze(P11(3,:,:)))));
    minY=min([minY min(smoothdata(nanmedian(squeeze(P11(4,:,:)))))]);
    maxY=max([maxY max(smoothdata(nanmedian(squeeze(P11(4,:,:)))))]);
    minY=min([minY min(smoothdata(nanmedian(squeeze(P11(5,:,:)))))]);
    maxY=max([maxY max(smoothdata(nanmedian(squeeze(P11(5,:,:)))))]);
    minY=min([minY min(smoothdata(nanmedian(squeeze(P11(6,:,:)))))]);
    maxY=max([maxY max(smoothdata(nanmedian(squeeze(P11(6,:,:)))))]);
    
    hold off
    legend('Shear1','Shear2','Accel X/speed','Accel Y/speed','Accel Z/speed','location','eastoutside')
    %        legend('Shear1','Shear2','Accel X/speed','Accel Y/speed','location','eastoutside')
    ylabel('s^{-2}/Hz','fontsize',20)
    xlabel('Hz','fontsize',20)
    grid on
    xlim(f([1 end]))
    ylim([minY maxY])
    set(ax(1),'fontsize',15)
    
    ax(2)=subplot('Position',[.48 .3 .5 .2]);
    semilogx(f(1:end-1),smoothdata(abs(mean(squeeze(Co12(3,4,:,indf1))))),'linewidth',2)
    hold on
    semilogx(f(1:end-1),smoothdata(abs(mean(squeeze(Co12(3,5,:,indf1))))),'linewidth',2)
    semilogx(f(1:end-1),smoothdata(abs(mean(squeeze(Co12(3,6,:,indf1))))),'linewidth',2)
    hold off
    legend('Sh1-AccelX','Sh1-AccelY','Sh1-AccelZ','location','eastoutside')
    %        legend('Sh1-AccelX','Sh1-AccelY','location','eastoutside')
    title('Coherence','fontsize',20)
    xlim(f([1 end]))
    set(gca,'XtickLabel',[])
    set(ax(2),'fontsize',15)
    grid on
    
    ax(3)=subplot('Position',[.48 .08 .5 .2]);
    semilogx(f(1:end-1),smoothdata(abs(mean(squeeze(Co12(4,4,:,indf1))))),'linewidth',2)
    hold on
    semilogx(f(1:end-1),smoothdata(abs(mean(squeeze(Co12(4,5,:,indf1))))),'linewidth',2)
    semilogx(f(1:end-1),smoothdata(abs(mean(squeeze(Co12(4,6,:,indf1))))),'linewidth',2)
    hold off
    %        legend('Sh2-AccelX','Sh2-AccelY','location','eastoutside')
    legend('Sh2-AccelX','Sh2-AccelY','Sh2-AccelZ','location','eastoutside')
    xlim(f([1 end]))
    set(ax(3),'fontsize',15)
    xlabel('Hz','fontsize',20)
    grid on
    
    
    ax(4)=subplot('Position',[.1 .57 .15 .35]);
    semilogx(smoothdata(MS{1}.epsilon(:,1)),MS{1}.pr,'linewidth',2)
    hold(ax(4),'on')
    semilogx(smoothdata(MS{1}.epsilon(:,2)),MS{1}.pr,'linewidth',2)
    hold(ax(4),'off')
    legend('epsilon1','epsilon2','location','southeast')
    axis ij
    ylim(sort(MS{1}.pr([1 end])))
    xlim([min(MS{1}.epsilon(:)) ...
        max(MS{1}.epsilon(:))])
    xlabel('\epsilon W.kg^{-1}','fontsize',15)
    ylabel('Depth (m)','fontsize',15)
    grid on
    
    ax(5)=subplot('Position',[.3 .57 .1 .35]);
    semilogx(MS{1}.w,MS{1}.pr,'linewidth',2)
    axis ij
    ylim(sort(MS{1}.pr([1 end])))
    xlim([min(MS{1}.w(:)) max(MS{1}.w(:))])
    xlabel('speed (m s^{-1})','fontsize',15)
    ylabel('Depth (m)','fontsize',15)
    grid on
    
    Epsilon_class=calc_binned_epsi(MS);
    
    ax(6)=subplot('Position',[.08 .3 .37 .2]);
    ax(7)=subplot('Position',[.08 .1 .37 .2]);
    
    plot_binned_epsilon_sanity_profile(Epsilon_class,' ',ax(6),ax(7))
    
    fig=gcf;
    fig.PaperPosition=[0 0 15 10];
    print(sprintf('%sSanity_Profile_%i',Meta_Data.L1path,id_profile),'-dpng2')
    pause(.1)
    cla(ax(1));
    cla(ax(2));
    cla(ax(3));
    cla(ax(4));
    cla(ax(5));
    cla(ax(6));
    cla(ax(7));
catch
    fprintf('issue with profile %i\n',id_profile);
end

