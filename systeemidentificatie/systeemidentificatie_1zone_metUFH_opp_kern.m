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
totale_zon = data.signal(signal_zon(1)).data(range) + data.signal(signal_zon(2)).data(range) + data.signal(signal_zon(3)).data(range);

%calculate average internal heatflow in the 3 zones
gemiddelde_intern = mean([data.signal(signal_intern(1)).data(range) data.signal(signal_intern(2)).data(range) data.signal(signal_intern(3)).data(range)],2); 

%calculate heating
warmtepomp = data.signal(signal_warmtepomp(1)).data(range).*0.9;
verw_gas_origineel = data.signal(signal_gas).data(range).*0.8;
verw_gas = warmtewinsten(verw_gas_origineel,15);

%smooth datasignals
buitentemp = smooth(buitentemp,'rlowess');
gemiddelde_temp = smooth(gemiddelde_temp,'rlowess');

%create inputstructure
inp = struct('T_gem',{gemiddelde_temp},'T_buiten',{buitentemp},'Q_zon',{totale_zon},'warmtepomp',{warmtepomp},'Q_gas',{verw_gas}, 'Q_intern',{gemiddelde_intern},'t',{data.time(range)});


%optimalisatie ��n zone met vloerverwarming (splitsing oppervlakte, kern)
x0 = [0.003, 10e6, 0.000008, 2e8, 0.0145, -0.1726, 0.7, 0.00004 , 3e7, 21, 21, 6 ];
lb = [0.001, 1e7 , 0.000007, 9e7, 0.0135, -0.175 , 0.5, 0.000007, 1e7, 20, 20, 5 ];
ub = [0.004, 9e7 , 0.00005 , 1e9, 0.015 , -0.16  , 1  , 0.00005 , 9e7, 26, 26, 10];

[x,fval] = fminsearchbound(@(x) costfunction(x,inp,'systeemidentificatie_1zone_metUFH_opp_kern'),x0,lb,ub,optimset('Display','iter','MaxFunEvals',100000,'MaxIter',100000));
T_kern = zeros(length(gemiddelde_temp),1);
T_opp = zeros(length(gemiddelde_temp),1);

R = x(1)
C = x(2)
R_kern = x(3)
C_kern = x(4)
A = x(5)
B = x(6)
cf_sol = x(7)
R_opp = x(8)
C_opp = x(9)
T_kern(1) = x(10);
T_opp(1) = x(11);
COPmax = x(12)
cf_WP = 1;

T_berekend = zeros(length(gemiddelde_temp),1);
T_berekend(1) = gemiddelde_temp(1);
Q_verw = warmtepomp.*min(COPmax,abs(1./(A.*(35-buitentemp)+B))).*cf_WP + verw_gas;
Q_zon = totale_zon.*cf_sol;
Q_intern = gemiddelde_intern;

for i = 1:length(gemiddelde_temp)-1        
    T_berekend(i+1) = T_berekend(i) + ((Q_intern(i)+((T_opp(i)-T_berekend(i))./R_opp)-((T_berekend(i)-buitentemp(i))./R))./C).*(inp.t(i+1)-inp.t(i));
    T_opp(i+1) = T_opp(i) + ((Q_zon(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_berekend(i))./R_opp))./C_opp).*(inp.t(i+1)-inp.t(i));
    T_kern(i+1) = T_kern(i) + ((Q_verw(i)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(inp.t(i+1)-inp.t(i));
end


figure;
subplot(2,1,1);
plot(localtime(range),Q_verw,'r',localtime(range),Q_zon,'g',localtime(range),Q_intern,'b');
legend('verw','zon','int','Location','northwest','Orientation','Horizontal');
title 'Warmtewinsten';
datetick('x','dd')
ylabel('Q (W)')
xlabel('tijd (day of the month)')
grid on


subplot(2,1,2);
plot(localtime(range),gemiddelde_temp,'g',localtime(range),T_berekend,'k',localtime(range),T_opp,'b',localtime(range),T_kern,'r')
legend('Gemeten','Berekende','Opp','Kern','Location','southwest','Orientation','Horizontal');
title 'Systeemidentificatie';
datetick('x','dd')
ylabel('temperatuur (degC)')
xlabel('tijd (day of the month)')
grid on


%crossvalidation
crossvalidation_1zone_metUFH_opp_kern;
