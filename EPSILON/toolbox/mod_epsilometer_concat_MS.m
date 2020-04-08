function [MS,min_epsi,max_epsi]=mod_epsilometer_concat_MS(Meta_Data)


listfile=dir(fullfile(Meta_Data.L1path,'Turbulence_Profiles*.mat'));
listfilename=natsort({listfile.name});
count=1;
channels=Meta_Data.PROCESS.channels;
% for f=1:length(listfilename)
for f=1:10
    load(fullfile(listfile(f).folder,listfilename{f}),'nb_profile_perfile')
    for p=1:nb_profile_perfile
        load(fullfile(listfile(f).folder,listfilename{f}),sprintf('Profile%03i',count))
        fprintf('%s:%s\r\n',fullfile(listfile(f).folder,listfilename{f}),sprintf('Profile%03i',count));
        eval(sprintf('Profile=Profile%03i;',count));
        Fnames=fieldnames(Profile);
        for n=1:length(Fnames)
            wh_field=Fnames{n};
            switch wh_field
                case 'epsilon'
                    MS{count}.epsilon=Profile.epsilon;
                    minepsi1{count}=nanmin(log10(Profile.epsilon(:,1)));
                    minepsi2{count}=nanmin(log10(Profile.epsilon(:,2)));
                    maxepsi1{count}=nanmax(log10(Profile.epsilon(:,1)));
                    maxepsi2{count}=nanmax(log10(Profile.epsilon(:,2)));
                case 'chi'
                    MS{count}.chi=Profile.chi;
                case 't'
                    MS{count}.t=Profile.t;
                case 's'
                    MS{count}.s=Profile.s;
                case 'w'
                    MS{count}.w=Profile.w;
                case 'pr'
                    MS{count}.pr=Profile.pr;
                case 'dnum'
                    MS{count}.dnum=Profile.dnum;
                case 'sh_qcflag'
                    MS{count}.sh_qcflag=Profile.sh_qcflag;
                case 'tg_flag'
                    MS{count}.tg_flag=Profile.tg_flag;
                case 'Pc1c2'
                    for c=1:length(channels)
                        wh_channel=channels{c};
                        MS{count}.(sprintf('P%s',wh_channel))=Profile.Pc1c2.(wh_channel);
                    end
                case 'Cu1'
                    MS{count}.Cu1a1=Profile.Cu1.a1;
                    MS{count}.Cu1a2=Profile.Cu1.a2;
                    MS{count}.Cu1a3=Profile.Cu1.a3;
                case 'Cu2'
                    MS{count}.Cu2a1=Profile.Cu2.a1;
                    MS{count}.Cu2a2=Profile.Cu2.a2;
                    MS{count}.Cu2a3=Profile.Cu2.a3;
            end
        end
        clear Profile;
        eval(sprintf('clear Profile%03i;',count));
        count=count+1;
    end
end
min_epsi=[nanmean([minepsi1{:}]) nanmean([minepsi2{:}])];
max_epsi=[nanmean([maxepsi1{:}]) nanmean([maxepsi2{:}])];

