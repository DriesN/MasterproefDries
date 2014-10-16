function index = find_signal(data,signalname)
    for i=1:length(data.signal)
        if strcmp(data.signal(1,i).name, signalname)
            index = i;
            break;
        end
    end
end
