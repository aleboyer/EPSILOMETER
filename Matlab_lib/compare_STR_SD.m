SD=load('/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/epsifish1/d1/epsi/epsi_ep_test_20170101_000000_3_EPSI.mat')
STR=load('/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/epsifish1/d1/epsi/drop1_EPSI.mat')

STRtime=0.*STR.Sensor2;
for i=1:length(STR.EPSItime)
    if mod(i,100)==0
        fprintf('%i over %i\n',i,length(STR.EPSItime))
    end
    ind=find(SD.nbsample==STR.EPSItime(i));
    STRtime(i:i+160-1)=SD.nbsample(ind):SD.nbsample(ind+160-1);
end


