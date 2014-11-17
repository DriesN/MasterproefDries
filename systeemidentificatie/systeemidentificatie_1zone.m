% search Toperationeel
signalname = 'Toperationeel';
signal_temp_zone1 = find_signal(data,signalname,0,0,0);
signal_temp_zone2 = find_signal(data,signalname,signal_temp_zone1,0,0);
signal_temp_zone3 = find_signal(data,signalname,signal_temp_zone1,signal_temp_zone2,0);

% search Intern (invallende zonne-energie)
signalname = 'Intern';
signal_solar_zone1 = find_signal(data,signalname,0,0,0);
signal_solar_zone2 = find_signal(data,signalname,signal_solar_zone1,0,0);
signal_solar_zone3 = find_signal(data,signalname,signal_solar_zone1,signal_solar_zone2,0);

%search Verwarming
signalname = 'Verwarming';
signal_verw_totaal = find_signal(data,signalname,0,0,0);
signal_verw_zone1 = find_signal(data,signalname,signal_verw_totaal,0,0);
signal_verw_zone2 = find_signal(data,signalname,signal_verw_totaal,signal_verw_zone1,0);
signal_verw_zone3 = find_signal(data,signalname,signal_verw_totaal,signal_verw_zone1,signal_verw_zone2);

%calculate average temp in the 3 zones
temp_average = mean([data.signal(signal_temp_zone1).data(range) data.signal(signal_temp_zone2).data(range) data.signal(signal_temp_zone3).data(range)],2);

%calculate average solarenergy in the 3 zones
solar_average = mean([data.signal(signal_solar_zone1).data(range) data.signal(signal_solar_zone2).data(range) data.signal(signal_solar_zone3).data(range)],2);

%calculate average heating in the 3 zones
verw_average = mean([data.signal(signal_verw_zone1).data(range) data.signal(signal_verw_zone2).data(range) data.signal(signal_verw_zone3).data(range)],2);
