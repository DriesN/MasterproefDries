clc;
addpath('../lib');
addpath('../energieverbruik_correctiefactor')

%energieverbruik_correctiefactor uitvoeren
energieverbruik_correctiefactor;

%search data
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
warmtepomp = data.signal(signal_warmtepomp(1)).data(range).*0.9;
verw_gas_origineel = data.signal(signal_gas).data(range).*0.8;
verw_gas = warmtewinsten(verw_gas_origineel,15);

%smooth datasignals
buitentemp = smooth(buitentemp,'rlowess');
gemiddelde_temp = smooth(gemiddelde_temp,'rlowess');

%create inputstructure
inp = struct('T_gem',{gemiddelde_temp},'T_buiten',{buitentemp},'Q_zon',{gemiddelde_zon},'warmtepomp',{warmtepomp},'Q_gas',{verw_gas}, 'Q_intern',{gemiddelde_intern},'t',{data.time(range)});


%optimalisatie één zone
x0 = [0.001,1e7,0.5,1];
lb = [0    ,1e6,0.1,0.5];
ub = [0.01 ,1e8,0.8,1.5];
[x,fval] = fminsearchbound(@(x) costfunction(x,inp,'systeemidentificatie_1zone'),x0,lb,ub,optimset('Display','iter','MaxFunEvals',10000,'MaxIter',10000));
R = x(1)
C = x(2)
cf_COP = x(3)
cf_sol = x(4)

T_berekend = zeros(length(gemiddelde_temp),1);
T_berekend(1) = gemiddelde_temp(1);
Q_zon = gemiddelde_zon.*cf_sol;
Q_verw = warmtepomp.*((308.15./(35-buitentemp)).*cf_COP) + verw_gas;
 
for i = 1:length(gemiddelde_temp)-1
    T_berekend(i+1)=T_berekend(i)+((Q_zon(i)+Q_verw(i)-(T_berekend(i)-buitentemp(i))./R)./C).*(inp.t(i+1)-inp.t(i)); 
end
    
figure;
subplot(2,1,1);
plot(localtime(range),Q_verw,'r',localtime(range),Q_zon,'g');
legend('verw','zon');
legend('boxoff');
title 'Warmtewinsten';
datetick('x','dd')
ylabel('Q (W)')
xlabel('tijd (day of the month)')
grid on


subplot(2,1,2);
plot(localtime(range),gemiddelde_temp,'g--',localtime(range),T_berekend,'k')
legend('Gemeten','Berekende');
legend('boxoff');
title 'Gemeten en berekende temperatuur';
datetick('x','dd')
ylabel('temperatuur (degC)')
xlabel('tijd (day of the month)')
grid on

%crossvalidation
crossvalidation_1zone;