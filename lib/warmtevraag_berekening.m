function [Q_gas,W_hp,Q_hp] = warmtevraag_berekening(T_buiten,T_binnen,T_gewenst,A,B,COPmax,cf_WP,systeem)
%% Warmtevraag berekening hybride warmtepompsysteem

if strcmp(systeem,'hybride')
    % berekening warmtevraag
    W_hp_max = 1800;
    Q_gas_max = 10000;
    T1 = -10;
	COP = min(COPmax,abs(1/(A*(35-T_buiten)+B)));
    Q1 = Q_gas_max + W_hp_max*COP*cf_WP; % deze moet getuned worden
    T2 = 17.15;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = Q_gas_max + W_hp_max*COP*cf_WP;   % deze moet getuned worden
    Q_corr = max(0,min(Q1,Q_verw + dQdT*(T_gewenst-T_binnen)));
    
    % verdeling van de warmtevraag
    if T_buiten > -1.5
        W_hp  = min(W_hp_max,Q_corr/(COP*cf_WP));
        Q_hp = W_hp*COP*cf_WP;
        Q_gas = Q_corr-(W_hp*COP*cf_WP);
    else
        % draai de verdeling om, misschien is er meer warmte nodig dan alleen de
        % gasketel kan leveren
        Q_gas = min(Q_gas_max,Q_corr);
        W_hp = min(W_hp_max,(Q_corr-Q_gas)/(COP*cf_WP));
        Q_hp = W_hp*COP*cf_WP;
    end
end

%% Warmtevraag berekening warmtepomp

if strcmp(systeem,'warmtepomp')
    % berekening warmtevraag
    W_hp_max = 5000;
    T1 = -10;
	COP = min(COPmax,abs(1/(A*(35-T_buiten)+B)));
    Q1 = W_hp_max*COP*cf_WP; % deze moet getuned worden
    T2 = 15;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = W_hp_max*COP*cf_WP;   % deze moet getuned worden
    Q_corr = max(0,min(Q1,Q_verw + dQdT*(T_gewenst-T_binnen)));
    
    % verdeling van de warmtevraag
    W_hp = min(W_hp_max,Q_corr/(COP*cf_WP));
    Q_gas = 0;
    Q_hp = W_hp*COP*cf_WP;
end

%% Warmtevraag berekening gascondensatieketel

if strcmp(systeem,'gascondensatieketel')
    % berekening warmtevraag
    Q_gas_max = 15000;
    T1 = -10;
    Q1 = Q_gas_max; % deze moet getuned worden
    T2 = 20.05;    % deze moet getuned worden
    Q2 = 0;
    
    Q_verw = max(0,min(Q1,Q1 + (Q2-Q1)/(T2-T1)*(T_buiten-T1)));
    
    % correctie voor het verschil tussen binnen en buiten temperatuur
    dQdT = Q_gas_max;   % deze moet getuned worden
    Q_corr = max(0,min(Q1,Q_verw + dQdT*(T_gewenst-T_binnen)));
    
    % verdeling van de warmtevraag
    W_hp = 0;
    Q_hp = 0;
    Q_gas = min(Q_gas_max,Q_corr);
end

end