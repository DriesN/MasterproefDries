function [index] = find_signal(data,signalname)
j=0;
    for i=1:length(data.signal)        
            if strcmp(data.signal(1,i).name, signalname)             
                j = j + 1;
                index(:,j) = i;
            end       
    end
end
