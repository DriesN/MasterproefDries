function [Q_gas,W_hp] = warmtevraag_berekening(T_buiten,T_binnen,T_gewenst,cf_COP,systeem)

%warmtevraag berekening hybride warmtepompsysteem
if strcmp(systeem,'hybride')
    % berekening warmtevraag
    W_hp_max = 1800;
    Q_gas_max = 10000;
    T1 = -10;
    Q1 = Q_gas_max + W_hp_max*((308.15/(35-T_buiten))*cf_COP); % deze moet getuned worden
    T2 = 20;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = 10000 + W_hp_max*((308.15/(35-T_buiten))*cf_COP);   % deze moet getuned worden
    Q_corr = max(0,min(Q1,Q_verw + dQdT*(T_gewenst-T_binnen)));
    
    % verdeling van de warmtevraag
    if T_buiten > 0
        W_hp  = min(W_hp_max,Q_corr/((308.15/(35-T_buiten))*cf_COP));
       Q_gas = Q_corr-(W_hp*(308.15/(35-T_buiten))*cf_COP);
    else
        W_hp = 0;
        Q_gas = min(Q_gas_max,Q_corr);
    end
end

%warmtevraag berekening warmtepompsysteem
if strcmp(systeem,'warmtepomp')
    % berekening warmtevraag
    W_hp_max = 5000;
    T1 = -10;
    Q1 = W_hp_max*((308.15/(35-T_buiten))*cf_COP); % deze moet getuned worden
    T2 = 20;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = (W_hp_max*((308.15/(35-T_buiten))*cf_COP))*0.5;   % deze moet getuned worden
    Q_corr = max(0,min(Q1,Q_verw + dQdT*(T_gewenst-T_binnen)));
    
    % verdeling van de warmtevraag
    W_hp = min(W_hp_max,Q_corr/((308.15/(35-T_buiten))*cf_COP));
    Q_gas = 0;
end

%warmtevraag berekening gascondensatieketel
if strcmp(systeem,'gascondensatieketel')
    % berekening warmtevraag
    T1 = -10;
    Q1 = 15000; % deze moet getuned worden
    T2 = 20;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = 15000;   % deze moet getuned worden
    Q_corr = max(0,min(Q1,Q_verw + dQdT*(T_gewenst-T_binnen)));
    
    % verdeling van de warmtevraag
    W_hp = 0;
    Q_gas = min(15000,Q_corr);
end

end