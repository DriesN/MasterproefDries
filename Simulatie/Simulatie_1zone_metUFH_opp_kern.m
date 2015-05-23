clc;clear;close all;
addpath('../lib');

%Ingeven welke csv-file, begin- en einddatum simulatie
filename = '../data/knxcontrol_measurements_20140901_20150512.csv';
start_date = '01/10/2014  17:42:35';
stop_date = '01/05/2015 17:58:37';

% load data
data = load_database_measurements(filename);

% start en stop
ref_time = datenum('01/01/1970   00:00:00','dd/mm/yyyy   HH:MM:SS')*3600*24;
start_utc = datenum(start_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
stop_utc = datenum(stop_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
start_ind = find(data.time>=start_utc,1);
stop_ind = find(data.time>=stop_utc,1);

% tijd in uren
timezone = +2;
localtime = datenum(1970, 1, 1, 0, 0, data.time) + timezone/24;
range = start_ind:stop_ind;
time_in_hours = hour(localtime(range));

%verzamelen van de benodigde data
if strcmp(filename,'../data/knxcontrol_measurements_20140915_20141001.csv')
    %temperatuur
    signalname = 'Temperatuur';
    signal_buitentemp = find_signal(data,signalname);
    buitentemp = data.signal(signal_buitentemp).data(range);

    %search irradiatie (invallende zonne-energie)
    signalname = 'Irradiatie';
    signal_zon = find_signal(data,signalname);
    
    %search internal heatflow
    signalname = 'Intern';
    signal_intern = find_signal(data,signalname);
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
end

%berekenen gemiddelde zonne-instraling in de 3 zones
totale_zon = data.signal(signal_zon(1)).data(range) + data.signal(signal_zon(2)).data(range) + data.signal(signal_zon(3)).data(range);

%berekenen gemiddelde interne warmtewinsten in de 3 zones
gemiddelde_intern = mean([data.signal(signal_intern(1)).data(range) data.signal(signal_intern(2)).data(range) data.signal(signal_intern(3)).data(range)],2); 

%smooth datasignals
%buitentemp = smooth(buitentemp,'rlowess');

%% Definiëren van de modelparameters

R = 0.0028;         %K/W
C = 5.8434e+07;     %J/K
R_kern = 2.4927e-05; %K/W
C_kern = 9.5212e+07;%J/K
A = 0.0128;
B = -0.1776;
COPmax = 6.0698;
cf_sol =0.7217;
R_opp =2.9494e-06;  %K/W
C_opp =3.8065e+07;  %J/K
cf_WP = 0.9953;


T_berekend = zeros(length(range),1);
T_opp = zeros(length(range),1);
T_kern = zeros(length(range),1);
T_berekend(1) = 22;  
T_opp(1) = 22;
T_kern(1) = 22;
Q_zon = totale_zon.*cf_sol;
Q_intern = gemiddelde_intern;


% Gewenste temperatuur
T_gewenst = zeros(length(range),1);
for i=1:length(range)
    if time_in_hours(i)>=7 && time_in_hours(i)<22
        T_gewenst(i) = 21;
    else
        T_gewenst(i) = 16;
    end
end

Q_verw = zeros(length(range),1);
Q_gas = zeros(length(range),1);
W_hp = zeros(length(range),1);
Q_hp = zeros(length(range),1);

%% Berekening T_berekend uit het model
for i = 1:length(range)-1
    [Q_gas(i),W_hp(i),Q_hp(i)] = warmtevraag_berekening(buitentemp(i),T_berekend(i),T_gewenst(i),A,B,COPmax,cf_WP,'hybride');
    Q_verw(i) = Q_gas(i) + Q_hp(i);
    
    T_berekend(i+1) = T_berekend(i) + ((Q_intern(i)+((T_opp(i)-T_berekend(i))./R_opp)-((T_berekend(i)-buitentemp(i))./R))./C).*(data.time(i+1)-data.time(i));
    T_opp(i+1) = T_opp(i) + ((Q_zon(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_berekend(i))./R_opp))./C_opp).*(data.time(i+1)-data.time(i));
    T_kern(i+1) = T_kern(i) + ((Q_verw(i)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(data.time(i+1)-data.time(i));
end


% Elektriciteitsverbruik warmtepomp en gasverbruik gascondensatieketel
disp('Elektriciteitsverbruik warmtepomp [kWh]')
disp(sum(W_hp.*60)/(3600*1000))   %compressorverbruik in kWh
disp('Gasverbruik gascondensatieketel [kWh]')
disp((sum(Q_gas.*60)/(3600*1000))/0.9)  %gasverbruik in kWh

% Seasonal Performance Factor
disp('SPF')
disp(sum(Q_hp.*60)/sum(W_hp.*60))

% Plot
figure;
subplot(2,1,1);
plot(localtime(range),Q_gas,'r',localtime(range),Q_hp,'g',localtime(range),Q_zon,'y',localtime(range),Q_intern,'b');
legend('gas','hp','zon','int','Location','southwest','Orientation','Horizontal');
title 'Warmtewinsten';
datetick('x','dd')
ylabel('Q (W)')
xlabel('tijd (day of the month)')
grid on

subplot(2,1,2);
plot(localtime(range),T_berekend,'g',localtime(range),T_opp,'b',localtime(range),T_kern,'r',localtime(range),T_gewenst,'k--')
legend('Berekende','Opp','Kern','Gewenste','Location','southwest','Orientation','Horizontal');
title 'Simulatie';
datetick('x','dd')
ylabel('temperatuur (degC)')
xlabel('tijd (day of the month)')
grid on