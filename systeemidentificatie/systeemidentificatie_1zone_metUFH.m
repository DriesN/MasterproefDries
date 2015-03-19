clc;
addpath('../lib');
addpath('../energieverbruik_correctiefactor')

%energieverbruik_correctiefactor uitvoeren
energieverbruik_correctiefactor;

%zoeken naar de juiste data
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    %temperatuur
    signalname = 'Temperatuur';
    signal_buitentemp = find_signal(data,signalname);
    buitentemp = data.signal(signal_buitentemp).data(range);

    %zoek Toperationeel
    signalname = 'Toperationeel';
    signal_temp = find_signal(data,signalname);

    %zoek irradiatie (invallende zonne-energie)
    signalname = 'Irradiatie';
    signal_zon = find_signal(data,signalname);
    
    %zoek Verwarming
    signalname = 'Verwarming';
    signal_warmtepomp = find_signal(data,signalname);
    signalname = 'Gas';
    signal_gas = find_signal(data,signalname);
else
    %temperatuur
    signalname = 'Temperature';
    signal_temp = find_signal(data,signalname);
    buitentemp = data.signal(signal_temp(1)).data(range);

    %zoek irradiatie (invallende zonne-energie)
    signalname = 'Irradiation';
    signal_zon = find_signal(data,signalname);

    %zoek Verwarming
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

%berekent gemiddelde zonne-instraling in de 3 zones
gemiddelde_zon = mean([data.signal(signal_zon(1)).data(range) data.signal(signal_zon(2)).data(range) data.signal(signal_zon(3)).data(range)],2);

 
%berekent verwarming
warmtepomp = data.signal(signal_warmtepomp(1)).data(range);
verw_gas_origineel = data.signal(signal_gas).data(range);
verw_gas = warmtewinsten(verw_gas_origineel,15);

%smooth datasignalen
buitentemp = smooth(buitentemp,'rlowess');
gemiddelde_temp = smooth(gemiddelde_temp,'rlowess');

%create inputstructure
inp = struct('T_gem',{gemiddelde_temp},'T_buiten',{buitentemp},'Q_zon',{gemiddelde_zon},'warmtepomp',{warmtepomp},'Q_gas',{verw_gas},'t',{data.time(range)});


%optimalisatie één zone met vloerverwarming
x0 = [0.001,100000000,0.001,1000000,4,1];
[x,fval] = fminsearch(@(x) costfunction(x,inp,'systeemidentificatie_1zone_metUFH'),x0,optimset('Display','iter','MaxFunEvals',10000,'MaxIter',10000));
R = x(1)
C = x(2)
R_v = x(3)
C_v = x(4)
cf_COP = x(5)
cf_sol = x(6)

T_berekend = zeros(length(inp.T_gem),1);
T_vloer = zeros(length(inp.T_gem),1);
T_berekend(1) = inp.T_gem(1);
T_vloer(1) = 35;
Q_verw = inp.warmtepomp.*((35./(35-inp.T_buiten)).*cf_COP) + inp.Q_gas;
Q_zon = inp.Q_zon.*cf_sol;

for i = 1:length(inp.T_gem)-1        
    T_berekend(i+1) = T_berekend(i) + ((Q_zon(i)+((T_vloer(i)-T_berekend(i))./R_v)-((T_berekend(i)-inp.T_buiten(i))./R))./C).*(inp.t(i+1)-inp.t(i));
    T_vloer(i+1) = T_vloer(i) + ((Q_verw(i)-((T_vloer(i)-T_berekend(i))./R_v))./C_v).*(inp.t(i+1)-inp.t(i));
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
crossvalidation_1zone_metUFH;
