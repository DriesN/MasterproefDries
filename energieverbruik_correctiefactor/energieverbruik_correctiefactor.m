
addpath('../lib');


filename = '../data/knxcontrol_measurements_20140915_20141001.csv';
start_date = '15/09/2014  17:42:35';
stop_date = '30/09/2014 17:58:37';
meter_reading_start = [2654.82  2593.14 10];  % meterstanden    [dag nacht gas] in [kWh kWh m3]
meter_reading_stop  = [2696.55  2657.40 15];

meter_reading_conversion [ 1  1   22];     % conversie factoren voor meter reading

meter_difference = (meter_reading_stop-meter_reading_start).*meter_reading_conversion  % energieverbruik in kWh


% load data
data = load_database_measurements(filename);


% start en stop
ref_time = datenum('01/01/1970   00:00:00','dd/mm/yyyy   HH:MM:SS')*3600*24;
start_utc = datenum(start_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
stop_utc = datenum(stop_date,'dd/mm/yyyy   HH:MM:SS')*3600*24-ref_time;
start_ind = find(data.time>=start_utc,1);
stop_ind = find(data.time>=stop_utc,1);


% >>>>>>>>>>>>>>>>>>>>
% search 'Electriciteit' data
for i=1:50     % een iets meer matlab manier van loops
    if strcmp(data.signal(1,i).name, 'Electriciteit')
        signal_electriciteit = i;
        break;
	end
end
% >>>>>>>>>>>>>>>>>>>>

% aangezien je dit blok code al 2 keer gebruikt hebt is het misschien handig het als een externe functie te schrijven
% function index = find_signal(data,signalname)
% % function returns signal index from a data structure for a given signal name
%
% 	for i=1:length(data.signal)             % een iets meer matlab manier van loops en no magic numbers
%    	if strcmp(data.signal(i).name, signalname)
%        	index = i;
%        	break;
% 		end
% 	end
% end



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

% determine time in hours (local time)
timezone = +2;
% test                     vul hier de huidige utc tijd in en de output moet de huidige tijd zijn in een leesbaar formaat
disp('timezone test');
disp(datestr(datenum(1970, 1, 1, 0, 0, 1413445400)+timezone/24));
disp(' ');

localtime = datenum(1970, 1, 1, 0, 0, data.time) + timezone/24;
range = start_ind:stop_ind;
time_in_hours = hour((data.time(range) - ref_time)/(3600*24));   % ik ben er niet zeker van of dit klopt met tijdzones en zo, het moet in elk geval - zijn ipv +
time_in_hours = hour(localtime(range));


% totaal elektriciteitsverbruik
electriciteit_totaal = sum(data.signal(signal_electriciteit).data(range).*diff(data.time([range(1)-1, range])))/(1000*3600)   % verbruik + omzetting van Ws naar kWh

% nachttarief
exclude = ones(size(data.time(range)));
exclude(time_in_hours>7&time_in_hours<22) = 0; 
electriciteit_nacht = sum(data.signal(signal_electriciteit).data(range).*diff(data.time([range(1)-1, range])).*exclude)/(1000*3600)   % verbruik + omzetting van Ws naar kWh

% dagtarief
electriciteit_dag = electriciteit_totaal - electriciteit_nacht

% gas
gas = 100;

% calculate electriciteitsverbruik_correctiefactor
correctie_factor = meter_difference./[electriciteit_dag electriciteit_nacht gas];
disp(correctie_factor);

