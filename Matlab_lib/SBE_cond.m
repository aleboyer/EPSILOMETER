function SBEsample=SBE_cond(SBEcal,SBEsample)
    g    = SBEcal.g;
    h    = SBEcal.h;
    i    = SBEcal.i;
    j    = SBEcal.j;
    tcor = SBEcal.tcor;
    pcor = SBEcal.pcor;
     
    f = hex2dec(SBEsample.raw(7:12))/256/1000;
    SBEsample.conductivity = (g+h*f^2+i*f^3+j*f^4)/(1+tcor*SBEsample.temperature+pcor*SBEsample.pressure);
end
