function cast = get_cast_epsiWW(Epsi,CTDProfiles)
if isfield(Epsi,'EPSItime')
    indcast=cellfun( @(x) find(Epsi.EPSItime>=x.time(1) & Epsi.EPSItime<=x.time(end)),CTDProfiles,'un',0);
    cast=cellfun(@(x) structfun(@(y) y(x),Epsi,'un',0),indcast,'un',0);
end
if isfield(Epsi,'epsitime')
    indcast=cellfun( @(x) find(Epsi.epsitime>=x.time(1) & Epsi.epsitime<=x.time(end)),CTDProfiles(1:end-1),'un',0);
    cast=cellfun(@(x) structfun(@(y) y(x),Epsi,'un',0),indcast,'un',0);
    
%     for i=1:length(CTDProfiles)
%         test{i}=find(Epsi.epsitime>=CTDProfiles{i}.time(1) & Epsi.epsitime<=CTDProfiles{i}.time(end));
%         test1{i}=structfun(@(y) Epsi{i}(x),Epsi,
%     end
    
end
