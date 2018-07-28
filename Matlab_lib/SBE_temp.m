function SBEsample=SBE_temp(SBEcal,SBEsample)
    a0 = SBEcal.ta0;
    a1 = SBEcal.ta1;
    a2 = SBEcal.ta2;
    a3 = SBEcal.ta3;
    
    rawT = hex2dec(SBEsample.raw(1:6));
    mv = (rawT-524288)/1.6e7;
    r = (mv*2.295e10 + 9.216e8)/(6.144e4-mv*5.3e5);
    SBEsample.temperature = a0+a1*log(r)+a2*log(r)^2+a3*log(r)^3;
    SBEsample.temperature = 1/SBEsample.temperature - 273.15;
end


