Epsilometer processing library
User manual
Author: Arnaud Le Boyer
Date: 04/02/2020


##1. Brief description
The Epsilometer library processes the turbulent dissipation rate of kinetic energy (\epsilon) and temperature gradient (\chi) from data collected from the Epsilometer Front End (EFE) mounted on the system on module (SOM) developed at SIO by the multi-scale ocean dynamic (MOD) group.

The EFE has 2 shear probe channels (s1 and s2), 2 FPO7 channels (t1 and t2) and 3 acceleration channels (a1, a2, a3). The shear probes are mounted so their sensitive direction is parallel to a3. It is the user’s responsibility to mount the probes accordingly and confirm a-posteriori that s1 or s2 are highly correlated with a3.

EFE samples at 325 Hz and the data is collected on the SOM which can stream, process on-board (A/N: soon) or store internally the data.

The Epsilometer processing library is written in Matlab and is used when data are either streamed or internally stored on an SD card. This version of the epsilometer library focused on developing all the features requested by the users from the previous version. Given the current time frame, I did not  optimize the routines for time efficiency. It would be a great internship to merge some of the functions invoked in mod_epsilometer_calc_turbulence to optimize the cpu time. Currently a 100 meter profile with dz~25cm takes 12 sec.

\epsilon and \chi are computed from the shear and temperature gradient (TG) wavenumber spectra, respectively. These spectra are computed over N number of scans. N is a function of the length of a profile (not defined by the user) and the vertical resolution dz (defined by the user). The parameter tscan is the length of a scan in seconds (default is 6 sec). Each time series is converted into physical units. The following steps are then applied :
For a specific profile, we compute a coherence spectrum between s1, s2 and the acceleration channels. The range in pressure over which the coherence spectrum is computed is defined by the user in Meta_Data.PROCESS.Prmin, Meta_Data.PROCESS.Prmax.  
Compute each spectrum over NFFT samples (default is 3*325 ~ 3 sec).
Frequency spectra are corrected for the sampling filter (i.e., sinc4), the analog-circuit transfer functions (TFs, i.e., Tdiff, charge amp)  and the probes TFs (e.g., Oakey, FPO7 TF).
Frequency spectra are corrected for the coherence with a3: Ps1*(1-Co_{s1a3}).
Converted into wavenumber spectra assuming \omega=speed*k.
A cut-off wavenumber is defined. We assumed that above this wavenumber the data are either electrical noise or vehicle vibration.
\epsilon and \chi are inferred for the integration of shear/ TG spectrum over the wavenumber range previously defined.
Once \epsilon is computed for the whole deployment, we use the scans with low \epsilon to compute a vibration transfer function. Using P_{vibration}= TF*P_{a3}, we can estimate the expected “shear” level driven with vibration only and compare this estimate to the observed level.  


The details of these operations are described in the following.
TODO: describe the mission/vehicle/deployment organization

##2. Matlab library

**process_FOOBAR.m:** Define Meta_Data and run data processing steps.

The Meta_Data structure contains the exhaustive list of parameters necessary to process epsilon and chi for the epsilometer front end (EFE) data.

*I want to stress the importance of creating this Meta_Data structure before deployment. It will help the user to remember details if engineering notes are not sufficient. I am talking from experience here. Make a copy of this file for each deployment you want to process and name it accordingly (e.g. process_soda_wirewalker_epsi_d3.m)*

 The user needs to define all the following fields:

- Meta_Data.process_dir= path to the library.
- Meta_Data.path_mission= path to the data.
- Meta_Data.mission= name of the mission.
- Meta_Data.vehicle_name= name of the vehicle (The WW can use “singers” names).
- Meta_Data.deployment=name of the deployment, I usually call then d1, d2, …
- Meta_Data.vehicle=type of vehicle (WW,FISH,APEX,...)
-
- Meta_Data.PROCESS.nb_channels= number of EFE channels                                   
- Meta_Data.PROCESS.channels= name of the channels (e.g, {'t1','t2','s1','s2','c','a1','a2','a3'}
- Meta_Data.PROCESS.recording_mode=SD or FISH
- Meta_Data.PROCESS.df= sampling frequency.
- Meta_Data.PROCESS.nfft= the number of samples to perform the FFT.
- Meta_Data.PROCESS.tscan= the length in seconds of 1 scan (~ 1 epsilon, 1 chi estimate).
- Meta_Data.PROCESS.fc1=low frequency cut-off to compute the qc flag, Power spectra and Coherence estimate
- Meta_Data.PROCESS.fc2=high frequency cut-off to compute the qc flag, Power spectra and Coherence estimate
- Meta_Data.PROCESS.Prmin: min pressure for the Coherence estimate.
- Meta_Data.PROCESS.Prmax=min pressure for the Coherence estimate.
-
- Meta_Data.CTD.name= name of the CTD ’SBE49’
- Meta_Data.CTD.SN= serial number of the CTD
- Meta_Data.CTD.cal_file= path/to/CTDcalibration_file.
-
- Meta_Data.epsi.s?.SN= serial number of shear probe (?= 1 or 2)
- Meta_Data.epsi.s?.ADCconf= configuration of the ADC (Unipolar -Bipolar)
- Meta_Data.epsi.s?.ADCfilter= kind of filter used for the ADC sampling (sinc4)
- Meta_Data.epsi.s?.Sv= calibration coefficient of the shear probe. Probes are pre-calibrated in house (lab #213)
- Meta_Data.epsi.t?.SN= serial number of FPO7 probe ?
- Meta_Data.epsi.t?.ADCconf= configuration of the ADC (Unipolar - Bipolar)
- Meta_Data.epsi.t?.ADCfilter= kind of filter used for the ADC sampling (sinc4)
- Meta_Data.epsi.t?.dTdV= calibration coefficient of the FPO7 probe. Defined a-posteriori with CTD data. The “a posteriori” might change.
-
- Meta_Data.EFE.rev= EFE revision number
- Meta_Data.EFE.SN= EFE serial number.
- Meta_Data.EFE.temperature= ‘Tdiff’ or ‘’. It describes the analog-circuit before the ADC  
- Meta_Data.EFE.shear= It describes the analog-circuit before the ADC
-
- Meta_Data.SOM.rev= SOM revision
- Meta_Data.SOM.SN= system on module (SOM) serial number.
- Meta_Data.SOM.Firmware= version of the firmware on the SOM.

**mod_define_meta_data.m:** Defines paths to raw and to-be-processed data. If 'PROCESS', 'Hardware', and 'Firmware' structures within Meta_Data have not be defined yet, they are defined with defaults here.

**EPSI_matlab_path.m:** Add the paths defined in process_FOOBAR.m

**Mod_epsi_temperature_spectra:**
Calibrate the FPO7 for the deployment (mod_epsilometer_temperature_spectra). The user defines a segment>10s to compute both t1-t2 and CTD spectra.
The FPO7 raw spectrum is corrected from the ADC transfer functions (i.e., sinc4 and Tdiff)
and the corrected spectrum is then adjusted to the CTD spectrum with a dTdV scalar that converts the Volts from the FPO7 channel to Celcius. dTdV is in Celsius per Volt (C/V).
mod_epsilometer_batch_process:
Get the right cast (up or down) depending on the vehicle
Loop over each CTD and Epsi profiles to compute turbulence.
Once \espilon and \chi are computed, save the profile in a .mat file. We save 10 profiles per file. Turbulence_profiles0.mat contains profiles Profile001,Profile002, …, Profile010 (hoping that there will be no more than 999 profiles per deployment).
mod_epsilometer_calc_turbulence:
Append CTD and Epsi profiles to the same Profile structure. At the end of the process, Profile will have the epsilon, chi, vertical speed, and QC-flag profiles.
compute the vertical speed (dP/dt).
Define a pressure axis using dz in Meta_Data.PROCESS field.
Define the number of EFE and CTD samples for a scan at a specific depth z; scan(z), using tscan and Fs_epsi and Fs_ctd in the Meta_Data.PROCESS field.
Get the temperature analog transfer function (i.e., Tdiff).
Compute the average T, S, dnum, kvis, ktemp, w for scan(z).
Get the transfer function for shear and FPO7 probes. This TF requires w that is why we compute them here.
Convert the EFE time series in Volts in Physical units (a1, a2 and a3 in m s^{-2}, s1, and s2 in m s^{-1}, t1 and t2 in C˚).


**Mod_efe_scan_acceleration:**
Compute the power spectra with nfft samples (using pwelch).
Compute the coherence with nfftc sample (mscohere) between shear probes and a1, a2, a3.
Integrate acceleration and coherence over the frequency range Meta_Data.PROCESS.fc1 and  Meta_Data.PROCESS.fc2

**Mod_efe_scan_chi:**
compute the power spectra FPO7 scan (using pwelch).
Compare it to the bench electrical noise measured in the lab
Define the frequency/wavenumber where the observations are matching the electrical noise.
Transform the raw spectrum with the FPO7 and analog TF.
Integrate over the correct wavenumber range and compute \chi.
Flag the scan if the cut-off frequency is near the Nyquist frequency. It could be a sign of an electrical issue.
Mod_efe_scan_epsilon:
Compute the power spectra (using pwelch).
Compute the coherence (mscohere) between shear probes and a3 to correct the vibrations from the shear channel spectra (P_{s1}=P_{s1+vibration} (1-Co_{s1a3})).
transform P_{s1}  with the shear probe and analog TF.
Define a frequency cut-off and compute \espilon over this frequency range (eps1_mmp) (A/N: This is the core of the \epsilon computation, the user needs to spend some time there).
The obtained \espilon and \chi and flag profiles are added to Profile.


**create_velocity_transfer_function:**
Once we have the \epsilon for a whole deployment, we look for the low \epsilon scans and assume these are mainly electrical noise + vibration. We use these scans to compute a transfer function between a3 and the shear channels.
Get the lowest \epsilon for each profile
Select scans with \epsilon < mean(lowest \espilon)
Compute a transfer function TF_{noise}=(Cross spectrum s1-a3) ./ a3 for all the selected scans and average them
Assuming this TF_{noise} describes the epsilometer electrical noise+vibration, it gives an estimate of the level of the shear signal we should expect for the scan acceleration.
mod_epsilometer_add_sh_quality_flag:
Once we have the transfer function we get the ratio:
P_{shear} / (TF_{noise}*P_{a3}) for each scan.
And sum it between Meta_Data.PROCESS.fc1 and  Meta_Data.PROCESS.fc2
It gives a scalar informing the user if the shear signal is above (>0) or below (<0) the noise level.

**mod_epsilometer_grid_turbulence:** create depth-time map from the turbulence profiles. -

**mod_epsilometer_grid_plot:** plot the maps. (TODO: Currently missing a lot of necessary plots t,s,w, flags, coherence, accel)

**mod_epsilometer_binned_epsilon:** compute and plot the spectra averaged around discreta values of \epsilon.

**mod_epsilometer_binned_chi:** TODO compute and plot the spectra averaged around discreta values of \chi.

**mod_epsilometer_heat_flux:** TODO

**mod_epsilometer_thorpe scale:** TODO

**mod_epsilometer_epsi_from_chi:** TODO

##3. Data organization

**Meta_Data.CTDpath** points to the directory where CTD data are stored. They should be in a Matlab variable called ctd_d[deployment #].mat which contains a structure called ctd_d[deployment #]. The structure fields are [nx1] arrays.
