function [gas_warmte] = warmtewinsten(data,pf)

%filter voor de pieken te "smoothen"
warmtetoevoer_gas = sgolayfilt(data,1,61);

for i=1:length(warmtetoevoer_gas)
    if warmtetoevoer_gas(i)>0
        beginpiek = i;
        while warmtetoevoer_gas(i)>0
            i=i+1;
            if i>length(warmtetoevoer_gas)
                break;
            end
        end
        eindpiek = i-1;
        piekrange = beginpiek:eindpiek;
        if length(piekrange)<pf
            warmtetoevoer_gas(piekrange) = 0;
        else
            warmtetoevoer_gas(piekrange) = max(data(piekrange));
        end
        if warmtetoevoer_gas(piekrange)>20000
            warmtetoevoer_gas(piekrange) = 0;
        end
    end
    
end

gas_warmte = warmtetoevoer_gas;

end

