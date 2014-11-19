function cost = costfunction( x, inputs )

    R = x(1);
    C = x(2);
    
    T_meas = inputs.T_meas;
    Q_sol_meas = inputs.Q_sol_meas;
    Q_hea_meas = inputs.Q_hea_meas;
    T_amb_meas = inputs.T_amb_meas;

    
    % solve differenctial equation
    T_cal = R*Q_sol_meas + C*R*T_amb_meas;
    
    
    
    cost = sum((T_cal-T_meas).^2);
end

