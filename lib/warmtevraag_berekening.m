function [Q_gas,W_hp] = warmtevraag_berekening(T_buiten,T_binnen,T_gewenst,cf_COP)

    % berekening warmtevraag
    T1 = -10;
    Q1 = 15000; % deze moet getuned worden
    T2 = 20;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = 10000;   % deze moet getuned worden
    Q_corr = max(0,Q_verw + dQdT*(T_gewenst-T_binnen));
    
    
    % verdeling van de warmtevraag
    W_hp_max = 1800;
    
    if T_buiten > 0
        W_hp  = min(W_hp_max,Q_corr/((308.15/(35-T_buiten))*cf_COP));
        Q_gas = min(10000,Q_corr-(W_hp*(308.15/(35-T_buiten))*cf_COP));
    else
        W_hp = 0;
        Q_gas = min(10000,Q_corr);
    end
end