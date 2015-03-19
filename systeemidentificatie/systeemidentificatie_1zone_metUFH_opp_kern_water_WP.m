clc;
addpath('../lib');
addpath('../energieverbruik_correctiefactor')

%energieverbruik_correctiefactor uitvoeren
energieverbruik_correctiefactor;

%search data
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    %temperatuur
    signalname = 'Temperatuur';
    signal_buitentemp = find_signal(data,signalname);
    buitentemp = data.signal(signal_buitentemp).data(range);

    %search Toperationeel
    signalname = 'Toperationeel';
    signal_temp = find_signal(data,signalname);

    %search irradiatie (invallende zonne-energie)
    signalname = 'Irradiatie';
    signal_zon = find_signal(data,signalname);
    
    %search internal heatflow
    signalname = 'Intern';
    signal_intern = find_signal(data,signalname);

    %search Verwarming
    signalname = 'Verwarming';
    signal_warmtepomp = find_signal(data,signalname);
    signalname = 'Gas';
    signal_gas = find_signal(data,signalname);
else
    %temperatuur
    signalname = 'Temperature';
    signal_temp = find_signal(data,signalname);
    buitentemp = data.signal(signal_temp(1)).data(range);

    %search irradiatie (invallende zonne-energie)
    signalname = 'Irradiation';
    signal_zon = find_signal(data,signalname);
    
    %search internal heatflow
    signalname = 'Internal';
    signal_intern = find_signal(data,signalname);

    %search Verwarming
    signalname = 'elektriciteit_verwarming';
    signal_warmtepomp = find_signal(data,signalname);
    signalname = 'gas';
    signal_gas = find_signal(data,signalname);
end

%berekent gemiddelde temperatuur in de 3 zones
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    gemiddelde_temp = mean([data.signal(signal_temp(1)).data(range) data.signal(signal_temp(2)).data(range) data.signal(signal_temp(3)).data(range)],2);
else
    gemiddelde_temp = mean([data.signal(signal_temp(2)).data(range) data.signal(signal_temp(3)).data(range) data.signal(signal_temp(4)).data(range)],2);
end

%calculate average solarenergy in the 3 zones
gemiddelde_zon = mean([data.signal(signal_zon(1)).data(range) data.signal(signal_zon(2)).data(range) data.signal(signal_zon(3)).data(range)],2);

%calculate average internal heatflow in the 3 zones
gemiddelde_intern = mean([data.signal(signal_intern(1)).data(range) data.signal(signal_intern(2)).data(range) data.signal(signal_intern(3)).data(range)],2); 

%calculate heating
warmtepomp = data.signal(signal_warmtepomp(1)).data(range);
verw_gas_origineel = data.signal(signal_gas).data(range);
verw_gas = warmtewinsten(verw_gas_origineel,15);


%smooth datasignals
buitentemp = smooth(buitentemp,'rlowess');
gemiddelde_temp = smooth(gemiddelde_temp,'rlowess');

%create inputstructure
inp = struct('T_gem',{gemiddelde_temp},'T_buiten',{buitentemp},'Q_zon',{gemiddelde_zon},'warmtepomp',{warmtepomp},'Q_gas',{verw_gas}, 'Q_intern',{gemiddelde_intern},'t',{data.time(range)});


%optimalisatie één zone met vloerverwarming (splitsing oppervlakte, kern)
x0 = [0.001,100000000,0.0001,1000000,4,1,0.001,1000000,0.001,100000,0.001,100000];

[x,fval] = fminsearch(@(x) costfunction(x,inp,'systeemidentificatie_1zone_metUFH_opp_kern_water_WP'),x0,optimset('Display','iter','MaxFunEvals',10000,'MaxIter',10000));
R = x(1)
C = x(2)
R_kern = x(3)
C_kern = x(4)
cf_COP = x(5)
cf_sol = x(6)
R_opp = x(7)
C_opp = x(8)
R_water = x(9)
C_water = x(10)
R_cond = x(11)
C_cond = x(12)

T_berekend = zeros(length(gemiddelde_temp),1);
T_berekend(1) = gemiddelde_temp(1);
T_cond = zeros(length(gemiddelde_temp),1);
T_cond(1) = 35;
T_water = zeros(length(gemiddelde_temp),1);
T_water(1) = 30;
T_kern = zeros(length(gemiddelde_temp),1);
T_kern(1) = 30;
T_opp = zeros(length(gemiddelde_temp),1);
T_opp(1) = 30;
Q_warmtepomp = warmtepomp.*((35./(35-buitentemp)).*cf_COP);
Q_gas = inp.Q_gas;
Q_zon = gemiddelde_zon.*cf_sol;
Q_intern = gemiddelde_intern;

for i = 1:length(gemiddelde_temp)-1        
    T_berekend(i+1) = T_berekend(i) + ((Q_intern(i)+((T_opp(i)-T_berekend(i))./R_opp)-((T_berekend(i)-buitentemp(i))./R))./C).*(inp.t(i+1)-inp.t(i));
    T_opp(i+1) = T_opp(i) + ((gemiddelde_zon(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_berekend(i))./R_opp))./C_opp).*(inp.t(i+1)-inp.t(i));
    T_kern(i+1) = T_kern(i) + ((((T_water(i)-T_kern(i))./R_water)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(inp.t(i+1)-inp.t(i));
    T_water(i+1) = T_water(i) + ((Q_gas(i)+((T_cond(i)-T_water(i))./R_cond)-((T_water(i)-T_kern(i))./R_water))./C_water).*(inp.t(i+1)-inp.t(i));
    T_cond(i+1) = T_cond(i) + ((Q_warmtepomp(i)-((T_cond(i)-T_water(i))./R_cond))./C_cond).*(inp.t(i+1)-inp.t(i));
end

figure
subplot(1,1,1)
plot(localtime(range),gemiddelde_temp,'b',localtime(range),T_berekend,'r')
legend('Gemeten','Berekende');
legend('boxoff');
title 'Gemeten en berekende temperatuur';
datetick('x','dd')
ylabel('temperatuur (degC)')
xlabel('tijd (day of the month)')
grid on

%crossvalidation
crossvalidation_1zone_metUFH_opp_kern_water_WP;
