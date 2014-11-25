function cost = costfunction(x,inputs)
    R = vpa(x(1)); 
    C = vpa(x(2));
    
    T_meas = inputs.T_meas;
    T_amb_meas = inputs.T_amb_meas;
    Q_solar_meas = inputs.Q_solar_meas;
    Q_heat_meas = inputs.Q_heat_meas;
    
    % solve differential equation
    sys = (Q_solar_meas+Q_heat_meas-(T_meas-T_amb_meas)./R)./C;
    eq = char(sys(1));
    T_cal = dsolve(strcat('DT_meas=',eq));
    cost = sum((T_cal - T_meas).^2);
end
