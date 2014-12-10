function cost = costfunction(x,inputs,methode)    
    R = x(1); 
    C = x(2);

    T_meas = inputs.T_meas;
    T_amb_meas = inputs.T_amb_meas;
    Q_solar_meas = inputs.Q_solar_meas;
    Q_heat = inputs.Q_heatpump.*4 + inputs.Q_gas;
    t = inputs.t;
    
    %solve differential equation (numerical) --> 1 zone
    if strcmp(methode, 'systeemidentificatie_1zone')
        T_cal(1)   = T_meas(1);
        for i = 1:length(T_meas)-1
            T_cal(i+1) = T_cal(i) + (Q_solar_meas(i)+Q_heat(i)-(T_cal(i)-T_amb_meas(i))./R)./C .*(t(i+1)-t(i)); 
        end
    end
    
    %solve differential equation (numerical) --> 1 zone met UFH
    if strcmp(methode, 'systeemidentificatie_1zone_metUFH')
        R_v = x(3);
        C_v = x(4);
        T_floor = inputs.T_floor;
        T_cal(1) = T_meas(1);
        
        for i = 1:length(T_meas)-1
            T_cal(i+1) = T_cal(i) + (Q_solar_meas(i)+Q_heat(i)-C_v.*((T_floor(i+1)-T_floor(i))./(t(i+1)-t(i)))-(T_cal(i)-T_amb_meas(i))./R)./C .*(t(i+1)-t(i));
            Q_heat(i) = ((T_floor(i)-T_cal(i))./R_v)+C_v.*(T_floor(i+1)-T_floor(i))./(t(i+1)-t(i));
        end
    end
    
    %rotate T_cal matrix to the right order
    for i = 1:3
        T_cal = rot90(T_cal);
    end

    cost = sum((T_cal - T_meas).^2);
end
