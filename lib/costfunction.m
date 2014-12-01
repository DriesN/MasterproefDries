function cost = costfunction(x,inputs)
    R = x(1); 
    C = x(2);
    
    T_meas = inputs.T_meas;
    T_amb_meas = inputs.T_amb_meas;
    Q_solar_meas = inputs.Q_solar_meas;
    Q_heat_meas = inputs.Q_heat_meas;
    t = inputs.t;
    
    % solve differential equation (numerical)
    T_cal(1)   = T_meas(1);
    for i = 1:length(T_meas)-1
       T_cal(i+1) = T_cal(i) + (Q_solar_meas(i)+Q_heat_meas(i)-(T_cal(i)-T_amb_meas(i))./R)./C .*(t(i+1)-t(i)); 
    end
    
    %rotate T_cal matrix to the right order
    for i = 1:3
        T_cal = rot90(T_cal);
    end

    cost = sum((T_cal - T_meas).^2);
end
