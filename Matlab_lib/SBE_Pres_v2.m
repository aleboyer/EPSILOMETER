function pressure=SBE_Pres_v2(SBEcal,rawP,rawPT)
%  reads and apply calibration to the pressure data
    pa0     = SBEcal.pa0;
    pa1     = SBEcal.pa1;
    pa2     = SBEcal.pa2;
    ptempa0 = SBEcal.ptempa0;
    ptempa1 = SBEcal.ptempa1;
    ptempa2 = SBEcal.ptempa2;
    ptca0   = SBEcal.ptca0;
    ptca1   = SBEcal.ptca1;
    ptca2   = SBEcal.ptca2;
    ptcb0   = SBEcal.ptcb0;
    ptcb1   = SBEcal.ptcb1;
    ptcb2   = SBEcal.ptcb2;
    
    y    = rawPT/13107;
 
    t = ptempa0+ptempa1.*y+ptempa2.*y.^2;
    x = rawP-ptca0-ptca1*t-ptca2.*t.^2;
    n = x.*ptcb0./(ptcb0+ptcb1.*t+ptcb2.*t.^2);
     
    pressure = (pa0+pa1.*n+pa2.*n.^2-14.7).*0.689476;
end
