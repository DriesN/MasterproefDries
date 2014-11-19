



x0 = [3,1000000];

inp = struct();
inp.T_meas = [0 1 2 3 4]';
inp.Q_sol_meas = [0 1 2 3 4]';
inp.Q_hea_meas = [0 1 2 3 4]';
inp.T_amb_meas = [0 1 2 3 4]';

x = fminsearch(@(x) costfunction(x,inp),x0,optimset('Display','iter'));