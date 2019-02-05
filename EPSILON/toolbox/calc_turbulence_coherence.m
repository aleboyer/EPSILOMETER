function [Profile]=calc_turbulence_coherence(Profile,Meta_Data)

%  fUse the already computed Profile structure to correct shear spectra using
%  Coherence with acceleration
%  input: 
% .    Profile structure for 1 profile

%  output:
% . Profile=


%
%  Created by Arnaud Le Boyer on 7/28/18.


% convert frequency to wavenumber


f1=Profile.f;
Lf1=length(f1);
nb_channels=Profile.nbchannel;
inds1=3;
inds2=4;

% inds1=find(cellfun(@(x) strcmp(x,'s1'),channels));
% inds2=find(cellfun(@(x) strcmp(x,'s2'),channels));
% inda1=find(cellfun(@(x) strcmp(x,'a1'),channels));
% inda2=find(cellfun(@(x) strcmp(x,'a2'),channels));
% inda3=find(cellfun(@(x) strcmp(x,'a3'),channels));

s1=squeeze(Profile.Pf(3,:,:));
s2=squeeze(Profile.Pf(4,:,:));

Cos1a3=squeeze(Profile.Co12(3,7,:,:));
Cos1a2=squeeze(Profile.Co12(3,6,:,:));
Cos1a1=squeeze(Profile.Co12(3,5,:,:));

Cos1a3=abs(smoothdata(Cos1a3,'movmean',10));
Cos1a2=abs(smoothdata(Cos1a2,'movmean',10));
Cos1a1=abs(smoothdata(Cos1a1,'movmean',10));

Cotot=sqrt(Cos1a3.^2+Cos1a2.^2+Cos1a1.^2);

s1c=s1.*(1-Cotot);
s2c=s2.*(1-Cotot);

s1c(Cotot>.65)=nan;
s2c(Cotot>.65)=nan;

Profile.Pf(3,:,:)=s1c;
Profile.Pf(4,:,:)=s2c;



k=cell2mat(cellfun(@(x) f1/x, num2cell(Profile.w),'un',0).');

% create a common vertical wavenumber axis. 
dk_all=nanmin(nanmean(diff(k,1,2),2));
k_all=nanmin(k(:)):dk_all:nanmax(k(:));
Lk_all=length(k_all);

% temperature, vel and accell spec as function of k
P11k  = Profile.Pf.* shiftdim(repmat(ones(nb_channels,1)*Profile.w,[1,1,Lf1]),3);   


% calc epsilon by integrating to k with 90% variance of Panchev spec
% unless spectrum is noisy at lower k.
% Check that data window > 0.5 m, as needed for initial estimate
Profile.Pshear_k=zeros(Profile.nbscan,Lk_all,2).*nan;

% % movie stuff
% compute shear and temperature gradient. Get chi and epsilon values
% TODO: we do not need kall. 
for j=1:Profile.nbscan
    fprintf('scan %i over %i \n',j,Profile.nbscan)
    if ~isempty(inds1)
        indnan=~isnan(squeeze(P11k(inds1,j,:)));
        Profile.Pshear_k(j,:,1) = (2*pi*k_all).^2 .* interp1(k(j,indnan),squeeze(P11k(inds1,j,indnan)),k_all);        % shear spec  as function of k
    end
    if ~isempty(inds2)
        indnan=~isnan(squeeze(P11k(inds2,j,:)));
        Profile.Pshear_k(j,:,2) = (2*pi*k_all).^2 .* interp1(k(j,indnan),squeeze(P11k(inds2,j,indnan)),k_all);        % shear spec  as function of k
    end
    % compute epsilon 1 in eps1_mmp
    if ~isempty(inds1) % if spectrum is all nan
        if all(isnan(squeeze(P11k(inds1,j,:))))
            Profile.Ppan(j,:,1)=nan.*k_all;
            Profile.epsilon(j,1)=nan;
            Profile.kc(j,1)=nan;
        else
            [Profile.epsilon(j,1),Profile.kc(j,1)]=eps1_mmp(k_all,Profile.Pshear_k(j,:,1),Profile.kvis(j),dk_all,Profile.kmax(j)); 
            [kpan,Ppan] = panchev(Profile.epsilon(j,1),Profile.kvis(j));
            Profile.Ppan(j,:,1)=interp1(kpan,Ppan,k_all);
        end
    end
    % compute epsilon 2 in eps1_mmp
    if ~isempty(inds2) % if spectrum is all nan
        if all(isnan(squeeze(P11k(inds2,j,:))))
            Profile.Ppan(j,:,1)=nan.*k_all;
            Profile.epsilon(j,2)=nan;
            Profile.kc(j,2)=nan;
        else
            [Profile.epsilon(j,2),Profile.kc(j,2)]=eps1_mmp(k_all,Profile.Pshear_k(j,:,2),Profile.kvis(j),dk_all,Profile.kmax(j));
            [kpan,Ppan] = panchev(Profile.epsilon(j,2),Profile.kvis(j));
            Profile.Ppan(j,:,2)=interp1(kpan,Ppan,k_all);
        end
    end
end       

