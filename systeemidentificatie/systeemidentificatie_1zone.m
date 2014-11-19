%search Temperatuur
signalname = 'Temperatuur';
signal_temp = find_signal(data,signalname);
temp = data.signal(signal_temp).data(range);

% search Toperationeel
signalname = 'Toperationeel';
signal_temp_ambient = find_signal(data,signalname);

% search Intern (invallende zonne-energie)
signalname = 'Intern';
signal_solar = find_signal(data,signalname);

%search Verwarming
signalname = 'Verwarming';
signal_verw = find_signal(data,signalname);

%calculate average temp in the 3 zones
temp_ambient_average = mean([data.signal(signal_temp_ambient(1)).data(range) data.signal(signal_temp_ambient(2)).data(range) data.signal(signal_temp_ambient(3)).data(range)],2);

%calculate average solarenergy in the 3 zones
solar_average = mean([data.signal(signal_solar(1)).data(range) data.signal(signal_solar(2)).data(range) data.signal(signal_solar(3)).data(range)],2);

%calculate average heating in the 3 zones
verw_average = mean([data.signal(signal_verw(2)).data(range) data.signal(signal_verw(3)).data(range) data.signal(signal_verw(4)).data(range)],2);


