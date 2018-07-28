function EPSIchannels=EPSI_volt2g(EPSIchannels,Meta_Data)
    offset=1.65;
    channel_array=strsplit(Meta_Data.PROCESS.channels,',');
    for cha=1:length(channel_array)
        switch channel_array{cha}
            case {'a1','a2','a3'}
                EPSIchannels(:,cha)=(EPSIchannels(:,cha)-offset)/.66;
        end
    end
end
    