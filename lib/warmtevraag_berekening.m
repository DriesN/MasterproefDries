function [Q_gas,Q_hp] = warmtevraag_berekening(T_buiten,T_binnen,T_gewenst)

    % berekening warmtevraag
    T1 = -10;
    Q1 = 25000; % deze moet getuned worden
    T2 = 15;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = 2000;   % deze moet getuned worden
    Q_corr = max(0,Q_verw + dQdT*(T_gewenst-T_binnen));
    
    
    % verdeling van de warmtevraag
    Q_hp_max = 5000;
    
    if T_buiten > -0.5
        Q_hp  = min(Q_hp_max,Q_corr);
        Q_gas = Q_corr-Q_hp;
    else
        Q_hp = 0;
        Q_gas = Q_corr;
    end
end

