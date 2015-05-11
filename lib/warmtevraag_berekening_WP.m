function [warmtevraag] = warmtevraag_berekening_WP(verschil)

%berekening compressorvermogen van de warmtepomp    
<<<<<<< HEAD
if verschil < -0.5
    warmtevraag = 1600;
else
    warmtevraag = -1600.*verschil + 800;
end

if verschil > 0.5
    warmtevraag = 0;
end
=======
    if verschil < -0.5
        warmtevraag = 1100;
    else
        warmtevraag = -1100.*verschil + 550;
    end

    if verschil > 0.5
        warmtevraag = 0;
    end
>>>>>>> origin/master

end

