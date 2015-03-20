clear; clc; close all;
% input signalen
inp.t = (0:60:7*24*3600)';


inp.avg.Q_int = 0*ones(size(inp.t));
inp.avg.T_amb = 5*ones(size(inp.t));
inp.avg.Q_sol = 0*ones(size(inp.t));
inp.avg.W_hp  = 1000*ones(size(inp.t));
inp.avg.Q_gas = 0*ones(size(inp.t));


% parameters
T_kern = zeros(size(inp.t));
T_opp = zeros(size(inp.t));
T_zone = zeros(size(inp.t));


R      = 0.001
C      = 100e6
R_kern = 0.001
C_kern = 100e6
cf_COP = 0.5
cf_sol = 1
R_opp  = 0.001
C_opp  = 10e6

T_kern(1) = 25;
T_opp(1)  = 25;
T_zone(1) = 25;

% simulatie
COP = (273.15+35)./(35-inp.avg.T_amb).*cf_COP;
Q_hea = inp.avg.W_hp.*COP + inp.avg.Q_gas;    % Kelvin!!!
Q_sol = inp.avg.Q_sol.*cf_sol;
Q_int = inp.avg.Q_int;

for i = 1:length(inp.t)-1        
    T_zone(i+1) = T_zone(i) + ((Q_int(i)+((T_opp(i)-T_zone(i))./R_opp)-((T_zone(i)-inp.avg.T_amb(i))./R))./C).*(inp.t(i+1)-inp.t(i));
    T_opp(i+1)  = T_opp(i)  + ((Q_sol(i)+((T_kern(i)-T_opp(i))./R_kern)-((T_opp(i)-T_zone(i))./R_opp))./C_opp).*(inp.t(i+1)-inp.t(i));
    T_kern(i+1) = T_kern(i) + ((Q_hea(i)-((T_kern(i)-T_opp(i))./R_kern))./C_kern).*(inp.t(i+1)-inp.t(i));
end


% plotten
figure

subplot(3,1,1);
plot(inp.t,inp.avg.Q_sol,'r',inp.t,inp.avg.W_hp,'g',inp.t,inp.avg.Q_gas,'k',inp.t,inp.avg.Q_int,'b')
ylabel('heat flow (W)')
xlabel('tijd (min)')
legend({'sol','hp','gas','int'});
grid on

subplot(3,1,2);
plot(inp.t,COP,'r');
ylabel('COP')
xlabel('tijd  (min)')
grid on

subplot(3,1,3);
plot(inp.t,T_zone,'r',inp.t,T_opp,'g',inp.t,T_kern,'b',inp.t,inp.avg.T_amb,'k')
ylabel('temperatuur (degC)')
xlabel('tijd  (min)')
legend({'zone','opp','kern','amb'});
grid on










