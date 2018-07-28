global posi; % embryon of read loop

file='/Users/aleboyer/ARNAUD/SCRIPPS//DEV/bench132/epsiauto/raw/Meta_DEV_epsiauto.dat';

posi=0;
Tim=timer;
Tim.StartFcn = ['disp(''Conversion of EPSI Data begins now!''); ' ...
                 ' Meta_Data=create_Meta_Data(file);'];
Tim.TimerFcn = 'Meta_Data=EPSI_MakeMatFromRaw(Meta_Data);';
Tim.Stop = 'disp(''end Conversion of EPSI Data!''); ';
Tim.Period = 30;
Tim.ExecutionMode = 'fixedSpacing';
start(Tim)

