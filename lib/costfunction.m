function cost = costfunction(x,inputs,methode)    
    R = x(1); 
    C = x(2);
    T_meas = inputs.T_meas;
    T_amb_meas = inputs.T_amb_meas;
    Q_solar_meas = inputs.Q_solar_meas;
    Q_intern = inputs.Q_intern;
    Q_heat = inputs.Q_heatpump.*4 + inputs.Q_gas;
    t = inputs.t;
    
    %solve differential equation (numerical) --> 1 zone
    if strcmp(methode, 'systeemidentificatie_1zone')
        T_cal = zeros(length(T_meas),1);
        T_cal(1)   = T_meas(1);
        for i = 1:length(T_meas)-1
            T_cal(i+1) = T_cal(i) + ((Q_solar_meas(i)+Q_heat(i)-(T_cal(i)-T_amb_meas(i))./R)./C) .*(t(i+1)-t(i)); 
        end
    end
    
    %solve differential equation (numerical) --> 1 zone met UFH
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH')
        R_v = x(3);
        C_v = x(4);
        T_cal = zeros(length(T_meas),1);
        T_floor = zeros(length(T_meas),1);
        T_floor(1) = 35;
        T_cal(1) = T_meas(1);
        for i = 1:length(T_meas)-1
            T_cal(i+1) = T_cal(i) + ((Q_solar_meas(i)+((T_floor(i)-T_cal(i))./R_v)-((T_cal(i)-T_amb_meas(i))./R))./C).*(t(i+1)-t(i));
            T_floor(i+1) = T_floor(i) + ((Q_heat(i)-((T_floor(i)-T_cal(i))./R_v))./C_v).*(t(i+1)-t(i));
        end
    end
    
    %solve differential equation (numerical) -->1 zone met Q_intern
    %splitsing oppervlak_UFH en kern_UFH
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH_opp_kern')
        R_v = x(3);
        C_v = x(4);
        R_opp = x(5);
        C_opp = x(6);
        T_cal = zeros(length(T_meas),1);
        T_floor = zeros(length(T_meas),1);
        T_opp = zeros(length(T_meas),1);
        T_floor(1) = 50;
        T_opp(1) = 35;
        T_cal(1) = T_meas(1);
        for i = 1:length(T_meas)-1
            T_cal(i+1) = T_cal(i) + ((Q_intern(i)+((T_opp(i)-T_cal(i))./R_opp)-((T_cal(i)-T_amb_meas(i))./R))./C).*(t(i+1)-t(i));
            T_opp(i+1) = T_opp(i) + ((Q_solar_meas(i)+((T_floor(i)-T_opp(i))./R_v)-((T_opp(i)-T_cal(i))./R_opp))./C_opp).*(t(i+1)-t(i));
            T_floor(i+1) = T_floor(i) + ((Q_heat(i)-((T_floor(i)-T_opp(i))./R_v))./C_v).*(t(i+1)-t(i));
        end
    end

    cost = sum((T_cal - T_meas).^2);
end
