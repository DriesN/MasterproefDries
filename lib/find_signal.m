function index = find_signal(data,signalname,prev,prev2,prev3)
    for i=1:length(data.signal)
        if i~=prev & i~=prev2 & i~=prev3
            if strcmp(data.signal(1,i).name, signalname)
            index = i;
            break;
            end
        end
    end
end
