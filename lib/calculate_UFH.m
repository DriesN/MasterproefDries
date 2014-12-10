function temp_floor = calculate_UFH(Q, time)

    Q_heat_meas = Q;
    t = time;
    T(1) = 35;
    m = 100;
    
    %calculate temperatuur of underfloor heating with: Q = m*c*dT
    for i = 1:length(Q_heat_meas)-1
        T(i+1) = 50; 
    end
 
    %rotate T matrix
    for i = 1:3
        T = rot90(T);
    end
    
    temp_floor = T;
end

