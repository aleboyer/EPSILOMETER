# EPSILOMETER

Pre-requisit:

- Matlab 2018.
- usb port.
- 422 to usb dongle.


- streaming: TODO

- Turbulence processing

    pre-requisit:
      Download the repository: The location of the repository will define as process_dir (processing directory). 
      Use the EPSI log (in log folder) during deployment.To process the data, you the probe, MADRE and MAP Serial numbers. Write down MADRE ON and MADRE OFF time in UTC. Do not save the Log in the you repository. Save it in your data/deployement folder.
      In your deployment folder copy process_deployment_Example.m (in Matlab_lib)
      Define your environment (Data path, processing path, Serial Numbers ...) in process_deployment_Example.m.
      They you can run it. It will: 
            read the binary files.
            split the total time series into Profile time series.
            compute the dT/d (Celsius/Volt) coefficient for the temperature channels.
            For each Profile: 
                  Split the time serie in scans of X seconds (X is define by the user).
                  compute the spectra and coherence of each channels.
                  compute the temperature gradient and shear.
                  compute epsilon and chi.
            
      
      
      
