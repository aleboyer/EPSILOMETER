%Epsi onboard processing worksheet.
%4/2020 MHA
% 1. Determine the normalization factor for the sine taper we use
data=randn(200,1);
tap=triang(200);
tap=sin(pi/200*(1:200)') *1.4;

plot(tap)
std(data)./std(data.*tap)


%% 2. Get a few coefficients for a polynomial fit to the transfer function.
%
%The total transfer function from measured spectrum at the ADCs in V^2/Hz
%to velocity spectrum in (m/s)^2/Hz is 
%(2g/Sv/w)^2 * [H^2_sinc4 H^2_oakey H^2_elec]^-1

%We include the electronics transfer function measured by Sean and also the
%sinc^4.  The calibration and Ninnis wavenumber response correction are applied elsewhere.
ca_filter = load('/Users/malford/GoogleDrive/Work/Projects/SSTP/chiometer_epsilometer/EPSILOMETER/EPSILON/toolbox/FILTER/charge_coeffilt.mat'); %from network analysis

%% We transfer function for the spectrum is the square of the above function times sinc^4. See getfileters_MADRE.
f=ca_filter.freq;
Hs1filter=(sinc(f/(325))).^4;

loglog(f,Hs1filter.^2,f,abs(ca_filter.coef_filt).^2)
ylim([1e-2 1])

grid
shg

%%
%Total
h2elec=Hs1filter'.^2.*abs(ca_filter.coef_filt).^2;

logf=-1:.1:log10(325/2);
h2out=interp1(f,h2elec,10.^logf);
logh2out=log10(h2out);


semilogy(log10(f),h2elec,logf,h2out,'r*')

%% Now make a plot of log H2 versus log f

P=polyfit(logf,logh2out,10);

plot(logf,logh2out,logf,polyval(P,logf))
plot(logf,10.^logh2out,logf,10.^polyval(P,logf))

%This is a little too wiggly doing the charge amp plus sinc4.  I'll do the polyfit to only the electronics
%transfer function.

%% Attempt 2
%ca gain only - not sinc4.
h2elec=abs(ca_filter.coef_filt).^2;

logf=-1:.1:log10(10); %only fit up to a bit into the flat region

h2out=interp1(f,h2elec,10.^logf);
logh2out=log10(h2out);

P=polyfit(logf,logh2out,10);

plot(logf,logh2out,logf,polyval(P,logf))
plot(logf,10.^logh2out,logf,10.^polyval(P,logf))

%So this starts with x^9 and goes to the mean.
%P =
%   -3.5443    3.0229    6.0838   -4.5679   -3.9923    2.6482    0.8149   -0.3498   -0.1710    0.0621   -0.0840

%This is pretty good.  So the recipe is 
%1) use the 10th-order polynomial fit up to 10 Hz
%2) use the last value after that up to 325/2 Hz
%3) multiply the whole thing by sinc^8.

%%
%So now try to make the transfer function with our algorithm
h2elec_onboard=nan*f;
ind=find(f<10);
h2elec_onboard(ind)=polyval(P,log10(f(ind)));
h2elec_onboard(ind(end)+1:end)=h2elec_onboard(ind(end));

h2elec_onboard=10.^h2elec_onboard;

plot(logf,10.^logh2out,logf,10.^polyval(P,logf))
hold on
plot(log10(f),h2elec_onboard,'g-')
hold off


%%
loglog(f,h2elec,f,h2elec_onboard)
loglog(f,h2elec)

%% Maybe it's simpler to just use the actual values up to 10 Hz and output values for a few choices of N.
N=4096;
f1=(0:(N/2-1))/(N) * 325;
h2out=interp1(f,h2elec,f1);
h2out(1:30)


%% 3. 
%Get some sample data from PISTON for processing
load('/Users/malford/GoogleDrive/Data/epsi/PISTON/Cruises/sr1914/data/epsi/PC2/d10/L1/Turbulence_Profiles0.mat')

whz=56;
wh=4;