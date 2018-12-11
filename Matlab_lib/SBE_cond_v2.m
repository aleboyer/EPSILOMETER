function conductivity=SBE_cond_v2(SBEcal,rawC,T,P)
    g    = SBEcal.g;
    h    = SBEcal.h;
    i    = SBEcal.i;
    j    = SBEcal.j;
    tcor = SBEcal.tcor;
    pcor = SBEcal.pcor;
     
    f = rawC/256/1000;
    conductivity = (g+h.*f.^2+i.*f.^3+j.*f.^4)./(1+tcor.*T+pcor.*P);
end
