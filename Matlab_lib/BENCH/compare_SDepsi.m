%% Comparison
M2=load('/Users/aleboyer/ARNAUD/SCRIPPS/DEVELLOPMENT/EPSILOMETER/CALIBRATION/MADREB.2_5-MAPC.0_8/Meta_DEV_power_supply2.mat');
M1=load('/Users/aleboyer/ARNAUD/SCRIPPS/DEVELLOPMENT/EPSILOMETER/CALIBRATION/MADREB.2_5-MAPC.0_8/Meta_DEV_power_supply1.mat');

compare_MADREMAP(M1.Meta_Data,M2.Meta_Data)

