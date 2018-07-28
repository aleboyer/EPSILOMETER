function EPSIchannels=EPSI_count2volt(EPSIchannels,Meta_Data)
channel_array=strsplit(Meta_Data.PROCESS.channels,',');
Full_Range=2.5;
Gain=1;
N=24;
EPSIchannels=double(EPSIchannels);
for cha=1:length(channel_array)
    switch Meta_Data.epsi.(channel_array{cha}).ADCconf
        case 'unipolar'
            EPSIchannels(:,cha)=Full_Range*double(EPSIchannels(:,cha))/2^N/Gain;
        case 'bipolar'
            EPSIchannels(:,cha)=Full_Range/Gain* ...
                (double(EPSIchannels(:,cha))/2^(N-1)-1);
        case 'count'
            EPSIchannels(:,cha)=EPSIchannels(:,cha);
    end

end
    
    