
addpath('../lib');


filename = '../data/knxcontrol_measurements_20140915_20141001.csv';
start_date = '15/09/2014  17:42:35';
stop_date = '30/09/2014 17:58:37';
meter_reading = [2654.82 2696.55 2593.14 2657.40];  % meterstanden in kWh


% load data
data = load_database_measurements(filename);


% start en stop
ref_time = datenum('01/01/1970   00:00:00','dd/mm/yyyy   HH:MM:SS')*3600*24;
start_utc = datenum(start_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
stop_utc = datenum(stop_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
start_ind = find(data.time>=start_utc,1);
stop_ind = find(data.time>=stop_utc,1);


% search 'Electriciteit' data
i=1;
while i<50
    if strcmp(data.signal(1,i).name, 'Electriciteit')
        signal_electriciteit = i;
        break;
    else
        i = i + 1;
    end
end

% search 'Gas' data
j=1;
while j<50
    if strcmp(data.signal(1,j).name, 'Gas')
        signal_gas = j;
        break;
    else
        j = j + 1;
    end
end



% determine time in hours
range = start_ind:stop_ind;
time_in_hours = hour((data.time(range) + ref_time)/(3600*24));

% totaal electriciteitsverbruik
electriciteit_totaal = sum(data.signal(signal_electriciteit).data(range).*diff(data.time([range(1)-1, range])))/(1000*3600)   % verbruik + omzetting van Ws naar kWh

% nachttarief
exclude = ones(size(data.time(range)));
exclude(time_in_hours>7&time_in_hours<22) = 0; 
electriciteit_nacht = sum(data.signal(signal_electriciteit).data(range).*diff(data.time([range(1)-1, range])).*exclude)/(1000*3600)   % verbruik + omzetting van Ws naar kWh

% dagtarief
electriciteit_dag = electriciteit_totaal - electriciteit_nacht


% calculate electriciteitsverbruik_correctiefactor


