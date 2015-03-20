%crossvalidation
startdate_crossval = '02/11/2014  17:42:35';
stopdate_crossval = '14/11/2014 17:58:37';

start_utc_crossval = datenum(startdate_crossval,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
stop_utc_crossval = datenum(stopdate_crossval,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
start_ind_crossval = find(data.time>=start_utc_crossval,1);
stop_ind_crossval = find(data.time>=stop_utc_crossval,1);
range_crossval = start_ind_crossval:stop_ind_crossval;

buitentemp_crossval = data.signal(signal_temp(1)).data(range_crossval);

%berekent gemiddelde temperatuur, crossvalidation period
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    gemiddelde_temp_crossval = mean([data.signal(signal_temp(1)).data(range_crossval) data.signal(signal_temp(2)).data(range_crossval) data.signal(signal_temp(3)).data(range_crossval)],2);
else
    gemiddelde_temp_crossval = mean([data.signal(signal_temp(2)).data(range_crossval) data.signal(signal_temp(3)).data(range_crossval) data.signal(signal_temp(4)).data(range_crossval)],2);
end

%Berekent gemiddelde interne warmtewinsten, crossvalidation period
gemiddelde_intern_crossval = mean([data.signal(signal_intern(1)).data(range_crossval) data.signal(signal_intern(2)).data(range_crossval) data.signal(signal_intern(3)).data(range_crossval)],2); 

%berekent gemiddelde zonne-instraling, crossvalidation period
gemiddelde_zon_crossval = mean([data.signal(signal_zon(1)).data(range_crossval) data.signal(signal_zon(2)).data(range_crossval) data.signal(signal_zon(3)).data(range_crossval)],2);

%berekent verwarming
warmtepomp_crossval = data.signal(signal_warmtepomp(1)).data(range_crossval);
verw_gas_origineel_crossval = data.signal(signal_gas).data(range_crossval);
verw_gas_crossval = warmtewinsten(verw_gas_origineel_crossval,15);

%smooth datasignalen
buitentemp_crossval = smooth(buitentemp_crossval,'rlowess');
gemiddelde_temp_crossval = smooth(gemiddelde_temp_crossval,'rlowess');


%differentiaalberekening
T_berekend_crossval = zeros(length(gemiddelde_temp_crossval),1);
T_berekend_crossval(1) = gemiddelde_temp_crossval(1);
T_water_crossval = zeros(length(gemiddelde_temp_crossval),1);
T_water_crossval(1) = 35;
T_kern_crossval = zeros(length(gemiddelde_temp_crossval),1);
T_kern_crossval(1) = 30;
T_opp_crossval = zeros(length(gemiddelde_temp_crossval),1);
T_opp_crossval(1) = 25;
Q_verw_crossval = warmtepomp_crossval.*((35./(35-buitentemp_crossval)).*cf_COP) + verw_gas_crossval;
Q_zon_crossval = gemiddelde_zon_crossval.*cf_sol;
Q_intern_crossval = gemiddelde_intern_crossval;
t_crossval = data.time(range_crossval);
    
for i = 1:length(gemiddelde_temp_crossval)-1        
    T_berekend_crossval(i+1) = T_berekend_crossval(i) + ((Q_intern_crossval(i)+((T_opp_crossval(i)-T_berekend_crossval(i))./R_opp)-((T_berekend_crossval(i)-buitentemp_crossval(i))./R))./C).*(t_crossval(i+1)-t_crossval(i));
    T_opp_crossval(i+1) = T_opp_crossval(i) + ((gemiddelde_zon_crossval(i)+((T_kern_crossval(i)-T_opp_crossval(i))./R_kern)-((T_opp_crossval(i)-T_berekend_crossval(i))./R_opp))./C_opp).*(t_crossval(i+1)-t_crossval(i));
    T_kern_crossval(i+1) = T_kern_crossval(i) + ((((T_water_crossval(i)-T_kern_crossval(i))./R_water)-((T_kern_crossval(i)-T_opp_crossval(i))./R_kern))./C_kern).*(t_crossval(i+1)-t_crossval(i));
    T_water_crossval(i+1) = T_water_crossval(i) + ((Q_verw_crossval(i)-((T_water_crossval(i)-T_kern_crossval(i))./R_water))./C_water).*(t_crossval(i+1)-t_crossval(i));
end


figure
subplot(1,1,1)
plot(localtime(range_crossval),gemiddelde_temp_crossval,'b',localtime(range_crossval),T_berekend_crossval,'r')
legend('Gemeten','Berekende');
legend('boxoff');
title 'Crossvalidation';
datetick('x','dd')
ylabel('temperatuur (degC)')
xlabel('tijd (day of the month)')
grid on