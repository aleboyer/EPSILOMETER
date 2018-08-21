%file=input('Paste the path to the Meta_Data file \n','s');
file='/Users/aleboyer/ARNAUD/SCRIPPS/DEV/GRANITE/august-epsi4/raw/Meta_DEV_august-epsi4.dat';


Meta_Data=create_Meta_Data(file);
Meta_Data=EPSI_MakeMatFromRaw(Meta_Data);
EPSI_concatanateMat(Meta_Data);

choice=input('plot raw (yes/no)?\n','s');
end_choice=0;
while end_choice==0
    switch choice
        case 'yes'
            EPSI_plot_raw(Meta_Data)
            end_choice=1;
        case 'no'
            end_choice=1;
    end
end


choice=input('create profile and batchprocess (yes/no)?\n','s');
end_choice=0;
while end_choice==0
    switch choice
        case 'yes'
            EPSI_create_profiles(Meta_Data)
            EPSI_batchprocess_epsifish(Meta_Data);
            end_choice=1;
        case 'no'
            end_choice=1;
    end
end

