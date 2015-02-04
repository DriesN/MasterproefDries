clc;
addpath('../lib');
addpath('../energieverbruik_correctiefactor')

%energieverbruik_correctiefactor uitvoeren
energieverbruik_correctiefactor;

%search data
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    %temperatuur
    signalname = 'Temperatuur';
    signal_temp_ambient = find_signal(data,signalname);
    temp_ambient = data.signal(signal_temp_ambient).data(range);

    %search Toperationeel
    signalname = 'Toperationeel';
    signal_temp = find_signal(data,signalname);

    %search irradiatie (invallende zonne-energie)
    signalname = 'Irradiatie';
    signal_solar = find_signal(data,signalname);
    
    %search internal heatflow
    signalname = 'Intern';
    signal_intern = find_signal(data,signalname);

    %search Verwarming
    signalname = 'Verwarming';
    signal_verw_heatpump = find_signal(data,signalname);
    signalname = 'Gas';
    signal_verw_gas = find_signal(data,signalname);
else
    %temperatuur
    signalname = 'Temperature';
    signal_temp = find_signal(data,signalname);
    temp_ambient = data.signal(signal_temp(1)).data(range);

    %search irradiatie (invallende zonne-energie)
    signalname = 'Irradiation';
    signal_solar = find_signal(data,signalname);
    
    %search internal heatflow
    signalname = 'Internal';
    signal_intern = find_signal(data,signalname);

    %search Verwarming
    signalname = 'elektriciteit_verwarming';
    signal_verw_heatpump = find_signal(data,signalname);
    signalname = 'gas';
    signal_verw_gas = find_signal(data,signalname);
end

%calculate average temp in the 3 zones
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    temp_average = mean([data.signal(signal_temp(1)).data(range) data.signal(signal_temp(2)).data(range) data.signal(signal_temp(3)).data(range)],2);
else
    temp_average = mean([data.signal(signal_temp(2)).data(range) data.signal(signal_temp(3)).data(range) data.signal(signal_temp(4)).data(range)],2);
end

%calculate average solarenergy in the 3 zones
solar_average = mean([data.signal(signal_solar(1)).data(range) data.signal(signal_solar(2)).data(range) data.signal(signal_solar(3)).data(range)],2);

%calculate average internal heatflow in the 3 zones
intern_average = mean([data.signal(signal_intern(1)).data(range) data.signal(signal_intern(2)).data(range) data.signal(signal_intern(3)).data(range)],2); 

%calculate heating
verw_heatpump = data.signal(signal_verw_heatpump(1)).data(range);
verw_gas = data.signal(signal_verw_gas).data(range).*0.8;

%smooth datasignals
temp_ambient = smooth(temp_ambient,'rlowess');
temp_average = smooth(temp_average,'rlowess');

%create inputstructure
inp = struct('T_meas',{temp_average},'T_amb_meas',{temp_ambient},'Q_solar_meas',{solar_average},'Q_heatpump',{verw_heatpump},'Q_gas',{verw_gas}, 'Q_intern',{intern_average},'t',{data.time(range)});


%optimalisatie één zone met vloerverwarming (splitsing oppervlakte, kern)
x0 = [0.0058,8.0563e+07,3,1000000,3,1000000];
[x,fval] = fminsearch(@(x) costfunction(x,inp,'systeemidentificatie_1zone_metUFH_opp_kern'),x0,optimset('Display','iter'));
R = x(1)
C = x(2)
R_v = x(3)
C_v = x(4)
R_opp = x(5)
C_opp = x(6)
T_cal = zeros(length(inp.T_meas),1);
T_cal(1) = inp.T_meas(1);
T_floor = zeros(length(inp.T_meas),1);
T_floor(1) = 50;
T_opp = zeros(length(inp.T_meas),1);
T_opp(1) = 35;
Q_heat = inp.Q_heatpump.*4 + inp.Q_gas;
    
for i = 1:length(inp.T_meas)-1        
    T_cal(i+1) = T_cal(i) + ((inp.Q_intern(i)+((T_opp(i)-T_cal(i))./R_opp)-((T_cal(i)-inp.T_amb_meas(i))./R))./C).*(inp.t(i+1)-inp.t(i));
    T_opp(i+1) = T_opp(i) + ((inp.Q_solar_meas(i)+((T_floor(i)-T_opp(i))./R_v)-((T_opp(i)-T_cal(i))./R_opp))./C_opp).*(inp.t(i+1)-inp.t(i));
    T_floor(i+1) = T_floor(i) + ((Q_heat(i)-((T_floor(i)-T_opp(i))./R_v))./C_v).*(inp.t(i+1)-inp.t(i));
end

subplot(1,1,1)
plot(localtime(range),temp_average,'b',localtime(range),T_cal,'r')
legend('Gemeten','Berekende');
legend('boxoff');
title 'Gemeten en berekende temperatuur';
datetick('x','dd')
grid on