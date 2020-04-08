function Profile=mod_epsilometer_merge_profile(CTDProfile,EpsiProfile,Prmin,Prmax)

Profile=structfun(@(x) x(CTDProfile.P>=Prmin & CTDProfile.P<=Prmax),CTDProfile,'un',0);

for fields=fieldnames(EpsiProfile)'
    Profile.(fields{1})=EpsiProfile.(fields{1}) ...
         (EpsiProfile.epsitime>=CTDProfile.ctdtime(1) & ...
          EpsiProfile.epsitime<=CTDProfile.ctdtime(end));
end
