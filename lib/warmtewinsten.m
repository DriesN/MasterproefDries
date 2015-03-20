function [gas_warmte] = warmtewinsten(data,res)

%gasdata_verbeterd = sgolayfilt(data,1,61);

gasdata_verbeterd = zeros(length(data),1);

%Gemiddelde over een periode van 10 minuten
for i=1:res:length(data)-res
    resolution_range = i:i+res;
    gasdata_verbeterd(resolution_range) = mean(data(resolution_range));
end

%Maximum van 20 kW
for i=1:length(gasdata_verbeterd)
    if data(i)>20000
        treshold_range = i-10:i+10;
        gasdata_verbeterd(treshold_range) = 0;
    end
end

gas_warmte = smooth(gasdata_verbeterd);
end

