addpath('../lib');

% zet hier misschien bij hoe je de data variabele aanmaakt want die is niet
% gedefinieerd als ik opstart

%search Temperatuur
signalname = 'Temperatuur';
signal_temp_ambient = find_signal(data,signalname);
temp_ambient = data.signal(signal_temp_ambient).data(range);

% search Toperationeel
signalname = 'Toperationeel';
signal_temp = find_signal(data,signalname);

% search Intern (invallende zonne-energie)
signalname = 'Intern';
signal_solar = find_signal(data,signalname);

%search Verwarming
signalname = 'Verwarming';
signal_verw = find_signal(data,signalname);

%calculate average temp in the 3 zones
temp_average = mean([data.signal(signal_temp(1)).data(range) data.signal(signal_temp(2)).data(range) data.signal(signal_temp(3)).data(range)],2);

%calculate average solarenergy in the 3 zones
solar_average = mean([data.signal(signal_solar(1)).data(range) data.signal(signal_solar(2)).data(range) data.signal(signal_solar(3)).data(range)],2);

%calculate average heating in the 3 zones
verw_average = mean([data.signal(signal_verw(2)).data(range) data.signal(signal_verw(3)).data(range) data.signal(signal_verw(4)).data(range)],2);

%calculate temperature underfloor heating
temp_floor = calculate_UFH(verw_average, data.time(range));

%create inputstructure
inp = struct('T_meas',{temp_average},'T_amb_meas',{temp_ambient},'T_floor',{temp_floor},'Q_solar_meas',{solar_average},'Q_heat_meas',{verw_average},'t',{data.time(range)});

%optimalisation
x0 = [3,1000000];
[x,fval] = fminsearch(@(x) costfunction(x,inp),x0,optimset('Display','iter'));


R = x(1)
C = x(2)
T_cal(1) = inp.T_meas(1);

for i = 1:length(inp.T_meas)-1
    T_cal(i+1) = T_cal(i) + (inp.Q_solar_meas(i)-(T_cal(i)-inp.T_amb_meas(i))./R)./C .*(inp.t(i+1)-inp.t(i)); 
end
for i = 1:3
    T_cal = rot90(T_cal);
end
