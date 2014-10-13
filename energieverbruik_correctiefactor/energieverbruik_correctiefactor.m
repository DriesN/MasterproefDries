
addpath('../lib');


filename = '../data/knxcontrol_measurements_20140915_20141001.csv';
start_date = '15/09/2014  17:42:35';
stop_date = '30/09/2014 17:58:37';
meter_reading = [];


% load data
data = load_database_measurements(filename);


% start en stop
ref_time = datenum('01/01/1970   00:00:00','dd/mm/yyyy   HH:MM:SS')*3600*24;
start_utc = datenum(start_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
stop_utc = datenum(stop_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
start_ind = find(data.time>=start_utc,1);
stop_ind = find(data.time>=stop_utc,1);


% calculate integral
signal_electriciteit = 10;
signal_gas = 12;

range = start_ind:stop_ind;
exclude = ones(size(data.time(range)));

timeinhours = 0;
exclude(timeinhours>7&timeinhours<22) = 0; % nachttarief 


sum(data.signal(signal_electriciteit).data(range).*diff(data.time([range(1)-1 , range])).*exclude)