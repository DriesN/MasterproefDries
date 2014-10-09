data = 'data.dat';
Matrix = csvread(data,3,1);


Temperatuur = Matrix(:,1);  %-----°C
Azimut = Matrix(:,2);   %---------°
Altitude = Matrix(:,3); %---------°
Direct = Matrix(:,4);   %---------W/m2
Diffuse = Matrix(:,5);  %---------W/m2
Cloudfactor = Matrix(:,6);  %-----/
Windsnelheid = Matrix(:,7); %-----/
Regen = Matrix(:,8);    %---------/
Elektriciteit = Matrix(:,9);    %-W
Verwarming = Matrix(:,10);  %-----W
Gas = Matrix(:,11); %-------------W
Water = Matrix(:,12);   %---------l/min
Toperationeel = Matrix(:,13);   %-°C
Transmissie = Matrix(:,14); %-----W
Ventilatie = Matrix(:,15);  %-----W
Intern = Matrix(:,16);  %---------W
Irradiatie = Matrix(:,17);  %-----W
Verwarming2 = Matrix(:,18); %-----W
Koeling = Matrix(:,19); %---------W
Toperationeel2 = Matrix(:,20);  %-°C
Transmissie2 = Matrix(:,21);    %-W
Ventilatie2 = Matrix(:,22); %-----W
Intern2 = Matrix(:,23); %---------W
Irradiatie2 = Matrix(:,24); %-----W
Verwarming3 = Matrix(:,25); %-----W
Koeling2 = Matrix(:,26);    %-----W
Toperationeel3 = Matrix(:,27);  %-°C
Transmissie3 = Matrix(:,28);    %-W
Ventilatie3 = Matrix(:,29); %-----W
Intern3 = Matrix(:,30); %---------W
Irradiatie3 = Matrix(:,31); %-----W
Verwarming4 = Matrix(:,32); %-----W
Koeling3 = Matrix(:,33);    %-----W
Lichtsterkte = Matrix(:,34);    %-lux
Livingdeur = Matrix (:,35); %-----°C
Livingraam = Matrix (:,36); %-----°C
Bureau = Matrix(:,37);  %---------°C
Hal = Matrix(:,38); %-------------°C
Badkamer = Matrix(:,39);    %-----°C
Slaapkamer = Matrix(:,40);  %-----°C
Egon = Matrix(:,41);    %---------°C
Slaapkamer3 = Matrix(:,42); %-----°C
Horizontal = Matrix(:,43);  %-----W/m2


% Totale energieverbruik = 105,99 kWh

kWh = Elektriciteit * 1/60;  % Vermogensmatrix omzetten naar arbeidsmatrix
Totaalverbruik = sum(kWh);  % De som van de matrix geeft het totale verbruik
Correctiefactor = 105990/Totaalverbruik;    % Verhouding tussen beide getallen geeft de correctiefactor
Elektriciteit = Elektriciteit*Correctiefactor;
kWhCor = Elektriciteit * 1/60;  % Gecorrigeerde arbeidsmatrix
TotaalverbruikCor = sum(kWhCor);    % Gecorrigeerd totaalverbruik
