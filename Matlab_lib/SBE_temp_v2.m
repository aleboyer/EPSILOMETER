function temperature=SBE_temp_v2(SBEcal,T_raw)
    a0 = SBEcal.ta0;
    a1 = SBEcal.ta1;
    a2 = SBEcal.ta2;
    a3 = SBEcal.ta3;
    
    rawT = T_raw;
    mv = (rawT-524288)/1.6e7;
    r = (mv*2.295e10 + 9.216e8)./(6.144e4-mv*5.3e5);
    temperature = a0+a1*log(r)+a2*log(r).^2+a3*log(r).^3;
    temperature = 1./temperature - 273.15;
end

