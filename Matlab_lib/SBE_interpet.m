function [T,C,Pr]=SBE_interpet(SBEcal,sample)
    SBEsample.raw=sample;
    SBEsample=SBE_temp(SBEcal,SBEsample);
    SBEsample=SBE_Pres(SBEcal,SBEsample);
    SBEsample=SBE_cond(SBEcal,SBEsample);
    C=SBEsample.conductivity;
    T=SBEsample.temperature;
    Pr=SBEsample.pressure;
end
    
    
    