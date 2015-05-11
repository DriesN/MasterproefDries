function [warmtevraag] = warmtevraag_berekening_WP(verschil)

%berekening compressorvermogen van de warmtepomp    
if verschil < -0.5
    warmtevraag = 1600;
else
    warmtevraag = -1600.*verschil + 800;
end

if verschil > 0.5
    warmtevraag = 0;
end

end

