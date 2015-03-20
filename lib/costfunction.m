function cost = costfunction(x,inputs,methode)    
    R = x(1); 
    C = x(2);
    
    T_gem = inputs.T_gem;
    T_buiten = inputs.T_buiten;
    t = inputs.t;
    
    %solve differential equation (numerical) --> 1 zone
    if strcmp(methode, 'systeemidentificatie_1zone')
        Q_zon = inputs.Q_zon;
        Q_verw = inputs.warmtepomp + inputs.Q_gas;
        T_berekend = zeros(length(T_gem),1);
        T_berekend(1)   = T_gem(1);
        for i = 1:length(T_gem)-1
            T_berekend(i+1) = T_berekend(i) + ((Q_zon(i)+Q_verw(i)-(T_berekend(i)-T_buiten(i))./R)./C) .*(t(i+1)-t(i)); 
        end
    end
    
    %solve differential equation (numerical) --> 1 zone met UFH
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH')
        R_v = x(3);
        C_v = x(4);
        cf_COP = x(5);
        cf_sol = x(6);
        Q_zon = inputs.Q_zon.*cf_sol;
        Q_verw = inputs.warmtepomp.*((308.15./(35-T_buiten)).*cf_COP) + inputs.Q_gas;
        T_berekend = zeros(length(T_gem),1);
        T_vloer = zeros(length(T_gem),1);
        T_vloer(1) = 35;
        T_berekend(1) = T_gem(1);
        for i = 1:length(T_gem)-1
            T_berekend(i+1) = T_berekend(i) + ((Q_zon(i)+((T_vloer(i)-T_berekend(i))./R_v)-((T_berekend(i)-T_buiten(i))./R))./C).*(t(i+1)-t(i));
            T_vloer(i+1) = T_vloer(i) + ((Q_verw(i)-((T_vloer(i)-T_berekend(i))./R_v))./C_v).*(t(i+1)-t(i));
        end
    end
    
    %solve differential equation (numerical) -->1 zone met Q_intern
    %splitsing oppervlak_UFH en kern_UFH
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH_opp_kern')
        T_kern = zeros(length(T_gem),1);
        T_opp = zeros(length(T_gem),1);
        T_kern(1) = x(9);
        T_opp(1) = x(10);
        R_kern = x(3);
        C_kern = x(4);
        cf_COP = x(5);
        cf_sol = x(6);
        R_opp = x(7);
        C_opp = x(8);
        Q_intern = inputs.Q_intern;
        Q_zon = inputs.Q_zon.*cf_sol;
        Q_verw = inputs.warmtepomp.*((308.15./(35-T_buiten)).*cf_COP) + inputs.Q_gas;
        
        T_berekend = zeros(length(T_gem),1);

        T_berekend(1) = T_gem(1);
        
        for i = 1:length(T_gem)-1
            T_berekend(i+1) = T_berekend(i) + ((Q_intern(i)+((T_opp(i)-T_berekend(i))./R_opp)-((T_berekend(i)-T_buiten(i))./R))./C).*(t(i+1)-t(i));
            T_opp(i+1) = T_opp(i) + ((Q_zon(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_berekend(i))./R_opp))./C_opp).*(t(i+1)-t(i));
            T_kern(i+1) = T_kern(i) + ((Q_verw(i)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(t(i+1)-t(i));
        end
    end

    %solve differential equation (numerical) -->1 zone met Q_intern
    %splitsing oppervlak_UFH en kern_UFH en water
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH_opp_kern_water')
        R_kern = x(3);
        C_kern = x(4);
        cf_COP = x(5);
        cf_sol = x(6);
        R_opp = x(7);
        C_opp = x(8);
        R_water = x(9);
        C_water = x(10);
        Q_intern = inputs.Q_intern;
        Q_zon = inputs.Q_zon.*cf_sol;
        Q_verw = inputs.warmtepomp.*((308.15./(35-T_buiten)).*cf_COP) + inputs.Q_gas;
        
        T_berekend = zeros(length(T_gem),1);
        T_water = zeros(length(T_gem),1);
        T_kern = zeros(length(T_gem),1);
        T_opp = zeros(length(T_gem),1);
        T_water(1) = 35;
        T_kern(1) = 30;
        T_opp(1) = 25;
        T_berekend(1) = T_gem(1);
        
        for i = 1:length(T_gem)-1
            T_berekend(i+1) = T_berekend(i) + ((Q_intern(i)+((T_opp(i)-T_berekend(i))./R_opp)-((T_berekend(i)-T_buiten(i))./R))./C).*(t(i+1)-t(i));
            T_opp(i+1) = T_opp(i) + ((Q_zon(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_berekend(i))./R_opp))./C_opp).*(t(i+1)-t(i));
            T_kern(i+1) = T_kern(i) + ((((T_water(i)-T_kern(i))./R_water)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(t(i+1)-t(i));
            T_water(i+1) = T_water(i) + ((Q_verw(i)-((T_water(i)-T_kern(i))./R_water))./C_water).*(t(i+1)-t(i));
        end
    end
    %solve differential equation (numerical) -->1 zone met Q_intern
    %splitsing oppervlak_UFH en kern_UFH en water en warmtepompwater
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH_opp_kern_water_WP')
        R_kern = x(3);
        C_kern = x(4);
        cf_COP = x(5);
        cf_sol = x(6);
        R_opp = x(7);
        C_opp = x(8);
        R_water = x(9);
        C_water = x(10);
        R_cond = x(11);
        C_cond = x(12);
        Q_intern = inputs.Q_intern;
        Q_zon = inputs.Q_zon.*cf_sol;
        Q_warmtepomp = inputs.warmtepomp.*((308.15./(35-T_buiten)).*cf_COP);
        Q_gas = inputs.Q_gas;
        T_berekend = zeros(length(T_gem),1);
        T_cond = zeros(length(T_gem),1);
        T_water = zeros(length(T_gem),1);
        T_kern = zeros(length(T_gem),1);
        T_opp = zeros(length(T_gem),1);
        T_cond(1) = 35;
        T_water(1) = 30;
        T_kern(1) = 28;
        T_opp(1) = 25;
        T_berekend(1) = T_gem(1);
        
        for i = 1:length(T_gem)-1
            T_berekend(i+1) = T_berekend(i) + ((Q_intern(i)+((T_opp(i)-T_berekend(i))./R_opp)-((T_berekend(i)-T_buiten(i))./R))./C).*(t(i+1)-t(i));
            T_opp(i+1) = T_opp(i) + ((Q_zon(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_berekend(i))./R_opp))./C_opp).*(t(i+1)-t(i));
            T_kern(i+1) = T_kern(i) + ((((T_water(i)-T_kern(i))./R_water)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(t(i+1)-t(i));
            T_water(i+1) = T_water(i) + ((Q_gas(i)+((T_cond(i)-T_water(i))./R_cond)-((T_water(i)-T_kern(i))./R_water))./C_water).*(t(i+1)-t(i));
            T_cond(i+1) = T_cond(i) + ((Q_warmtepomp(i)-((T_cond(i)-T_water(i))./R_cond))./C_cond).*(t(i+1)-t(i));
        end
    end
    
    cost = sum((T_berekend - T_gem).^2);
end
