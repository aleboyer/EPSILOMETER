function H=get_filters_MADRE(Meta_Data,f)
%% Define the electronic filter, ADC filters.
%  The electronics filter Helec = charge amp filter (Hca) + Gain (Hg)
%  The ADC filter is a simple sinc^4 and the gain of the ADC is 2. Other options are available. 
%
%  TODO: enter argument to be able to change the ADC filter without hard
%  coding
%
switch Meta_Data.epsi.s1.ADCfilter
    case 'sinc4'
        Hs1filter=(sinc(f/(2*f(end)))).^4;
end
switch Meta_Data.epsi.t1.ADCfilter
    case 'sinc4'
        Ht1filter=(sinc(f/(2*f(end)))).^4;
end
switch Meta_Data.epsi.a1.ADCfilter
    case 'sinc4'
        Ha1filter=(sinc(f/(2*f(end)))).^4;
end

% shear channels
%charge amp filter

ca_filter = load('FILTER/charge_coeffilt.mat');
epsi_ca   = interp1(ca_filter.freq,ca_filter.coef_filt ,f);
gain_ca      = 1; %TODO check the charge amp gain with sean
H.electshear= epsi_ca*gain_ca;% charge amp from sean spec sheet
H.gainshear=1;
H.adcshear=H.gainshear.* Hs1filter;
H.shear=(H.electshear .* H.adcshear).^2;

%% FPO7 channels
Tdiff_filter = load('FILTER/Tdiff_filt.mat');

Tdiff_H = interp1(Tdiff_filter.freq,Tdiff_filter.coef_filt ,f);
H.gainFPO7=1;
H.electFPO7 = H.gainFPO7.*Ht1filter;
H.Tdiff=Tdiff_H;
%speed% convert to m/s
%tau=0.005 * speed^(-0.32); % thermistor time constant
H.magsq=@(speed)(1 ./ (1+((2*pi*(0.005 * speed^(-0.32))).*f).^2)); % magnitude-squared no units
H.phase=@(speed)(-2*atan( 2*pi*f*(0.005 * speed^(-0.32))));   % no units
H.FPO7=@(speed)(H.electFPO7.^2 .* H.magsq(speed) .* H.Tdiff.^2);

%% Accel channels
H.gainAccel  = 1;
H.electAccel = (H.gainAccel.*Ha1filter).^2;

end

