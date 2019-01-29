NOISE=load('/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/CALIBRATION/ELECTRONICS/comparison_temp_granite_sproul.mat');

logf=log10(NOISE.k_granite);
Empnoise=log10(NOISE.spec_granite);
Emp_FPO7noise=polyfit(logf(2:end),Empnoise(2:end),3)
%test_noise=polyval(Emp_FPO7noise,logf);
n3=Emp_FPO7noise(1);
n2=Emp_FPO7noise(2);
n1=Emp_FPO7noise(3);
n0=Emp_FPO7noise(4);

test_noise=n0+n1.*logf+n2.*logf.^2+n3.*logf.^3;

loglog(NOISE.k_granite,NOISE.spec_granite)
hold on
Emp=loglog(NOISE.k_granite,10.^test_noise,'m-','linewidth',2);


save([Meta_Data.CALIpath 'FPO7_notdiffnoise.mat'],'n0','n1','n2','n3')
