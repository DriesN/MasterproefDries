function cost = costfunction(x,inputs)
    R = vpa(x(1)); 
    C = vpa(x(2));
    
    T_meas = inputs.T_meas;
    T_amb_meas = inputs.T_amb_meas;
    Q_solar_meas = inputs.Q_solar_meas;
    Q_heat_meas = inputs.Q_heat_meas;
    
    % solve differential equation
    %sys = (Q_solar_meas+Q_heat_meas-(T_meas-T_amb_meas)./R)./C;
    %eq = char(sys(1));
    %T_cal = dsolve(strcat('DT_meas=',eq));          <- Hier probeer je de differentiaalvergelijking symbolisch op te lossen. Dit gaat uiteraard niet aangezien je een input signalen hebt die geen eenvoudige functie zijn. Je geeft trouwens ook geen beginvoorwaarde op.
    
    % Los de differentiaalvergelijking numeriek op:
    % dT_cal/dt = (Q_solar_meas+Q_heat_meas-(T_cal-T_amb_meas)./R)./C 
    % =>
    % ( T_cal(i+1)-T_cal(i) )/dt = (Q_solar_meas(i)+Q_heat_meas(i)-(T_cal(i)-T_amb_meas(i))./R)./C 
    % =>
    % T_cal(1)   = T_meas(1)
    % T_cal(i+1) = T_cal(i) + (Q_solar_meas(i)+Q_heat_meas(i)-(T_cal(i)-T_amb_meas(i))./R)./C *dt 
    
    T_cal(1)   = T_meas(1);
    for i = 1:xxx
       T_cal(i+1) = yyy; 
    end
    
    
    cost = sum((T_cal - T_meas).^2);
end
