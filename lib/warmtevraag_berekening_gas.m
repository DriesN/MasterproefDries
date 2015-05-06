function [warmtevraag] = warmtevraag_berekening_gas(verschil)

%berekening van de warmtevraag bij te lage COP (gas)
    
if verschil < -0.5
    warmtevraag = 10000;
else
    warmtevraag = -10000.*verschil + 5000;
end

if verschil > 0.5
    warmtevraag = 0;
end
end

