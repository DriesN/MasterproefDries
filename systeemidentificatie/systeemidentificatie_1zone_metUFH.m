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
totale_zon = data.signal(signal_zon(1)).data(range) + data.signal(signal_zon(2)).data(range) + data.signal(signal_zon(3)).data(range);

 
%berekent verwarming
warmtepomp = data.signal(signal_warmtepomp(1)).data(range).*0.9;
verw_gas_origineel = data.signal(signal_gas).data(range).*0.8;
verw_gas = warmtewinsten(verw_gas_origineel,15);

%smooth datasignalen
buitentemp = smooth(buitentemp,'rlowess');
gemiddelde_temp = smooth(gemiddelde_temp,'rlowess');

%create inputstructure
inp = struct('T_gem',{gemiddelde_temp},'T_buiten',{buitentemp},'Q_zon',{totale_zon},'warmtepomp',{warmtepomp},'Q_gas',{verw_gas},'t',{data.time(range)});


%optimalisatie ��n zone met vloerverwarming
x0 = [0.001, 10e6, 0.00005 , 2e8, 0.01, -0.1, 1  , 21,6 ];
lb = [0    , 1e6 , 0       , 1e7, 0.01, -0.2, 0.5, 20,5 ];
ub = [0.01 , 1e8 , 0.0001  , 1e9, 0.1 , 0   , 1.1, 26,10];

[x,fval] = fminsearchbound(@(x) costfunction(x,inp,'systeemidentificatie_1zone_metUFH'),x0,lb,ub,optimset('Display','iter','MaxFunEvals',10000,'MaxIter',10000));

T_vloer = zeros(length(inp.T_gem),1);
T_vloer(1) = x(8);
R = x(1)
C = x(2)
R_v = x(3)
C_v = x(4)
A = x(5)
B = x(6)
cf_sol = x(7)
COPmax = x(9)
cf_WP = 1;

T_berekend = zeros(length(inp.T_gem),1);
T_berekend(1) = inp.T_gem(1);
Q_verw = inp.warmtepomp.*min(COPmax,abs(1./(A.*(35-buitentemp)+B))).*cf_WP + inp.Q_gas;
Q_zon = inp.Q_zon.*cf_sol;

for i = 1:length(inp.T_gem)-1        
    T_berekend(i+1) = T_berekend(i) + ((Q_zon(i)+((T_vloer(i)-T_berekend(i))./R_v)-((T_berekend(i)-inp.T_buiten(i))./R))./C).*(inp.t(i+1)-inp.t(i));
    T_vloer(i+1) = T_vloer(i) + ((Q_verw(i)-((T_vloer(i)-T_berekend(i))./R_v))./C_v).*(inp.t(i+1)-inp.t(i));
end
    
figure;
subplot(2,1,1);
plot(localtime(range),Q_verw,'r',localtime(range),Q_zon,'g');
legend('verw','zon', 'Location','northwest','Orientation','Horizontal');
title 'Warmtewinsten {verwarming, zon}';
datetick('x','dd')
ylabel('Q (W)')
xlabel('tijd (day of the month)')
grid on


subplot(2,1,2);
plot(localtime(range),gemiddelde_temp,'g',localtime(range),T_berekend,'k',localtime(range),T_vloer,'b')
legend('Gemeten','Berekende','Vloer','Location','southwest','Orientation','Horizontal');
title 'Gemeten en berekende temperatuur';
datetick('x','dd')
ylabel('temperatuur (degC)')
xlabel('tijd (day of the month)')
grid on

%crossvalidation
crossvalidation_1zone_metUFH;
