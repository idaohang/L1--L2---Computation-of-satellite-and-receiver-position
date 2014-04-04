%% Computation of receiver's position
addpath('/Users/kevin/SkyDrive/KTH Work/Period 4 2014/GNSS/Labs/L1, L2 - Computation of satellite and receiver position')
clear all;
clc;
c = 299792458; % speed of light (m/s)
mu = 3.986005e14; % universal gravitational parameter (m/s)^3
omega_e_dot = 7.2921151467e-5; % earth rotation rate (rad/s)
F = -4.442807633e-10; % s/m^1/2
%% Compute signal propagation time by (13)
P1 = 23640467.92143; 
ta_nom = seconds_in_week(1,1,14,0); % 1 hour and 14 minutes
tAtoS = P1/c; % signal propagation time
%% Compute signal transmission time by (14)
ts_nom = ta_nom - tAtoS;
%% Compute satellite clock correction ?tsL1 
% by (24) and (25), neglect ?tr
af0 = -3.137718886140D-05;
af1 = 2.273736754430D-13;
af2 = 0.000000000000D+00;
tgd = -1.117587089540D-08;
t_oc = seconds_in_week(1,2,0,0); %
tsv = af0 + af1*(ts_nom-t_oc)+af2*(ts_nom-t_oc)^2; % (25)
dtsL1 = tsv - tgd; % (24)
%% Compute ts using the correction from the step 3.
ts = ts_nom - dtsL1;
%% Compute eccentric anomaly (Table 2)
% ek = mk + ec*sin(ek)
dn = 3.931235180300D-09;
m0 = 2.447144268100D+00;
A = (5.153726776120D+03)^2;
n0 = sqrt(mu/A^3); % Computed mean motion
n = n0 + dn;
ec = 2.003974630500D-03;
toe = 9.360000000000D+04;
tk = ts - toe;
tk = fixTk(tk); % if,then for table 2 of tk
mk = m0 + n*tk;
Ek = keplersEquation(mk,ec);
%% Compute ?tr by (26) and ts by (15).
dtr = F*ec*sqrt(A)*sin(Ek); %(26)
ts_new = ts - dtr;
%% Compute satellite coordinates Xs, Ys, Zs, for time ts - Table 2
% Calculate rk
crs = -9.471875000000D+01;
crc = 2.828437500000D+02;
vk = atan2((sqrt(1-ec^2)*sin(Ek)/(1-ec*cos(Ek))),((cos(Ek)-ec)/(1-ec*cos(Ek))));
w = 6.540136574710D-01;
Phik = vk + w;
drk = crs*sin(2*Phik) + crc*cos(2*Phik);
rk = A*(1-ec*cos(Ek)) + drk;  % Corrected radius
% Calculate uk
cus = 5.483627319340D-06;
cuc = -5.045905709270D-06;
duk = cus*sin(2*Phik) + cuc*cos(2*Phik);
uk = Phik + duk;
% Calculate ik
i0 = 9.816859369200D-01;
cis = -2.421438694000D-08;
cic = -4.284083843230D-08;
dik = cis*sin(2*Phik) + cic*cos(2*Phik);
idot = -1.489347751600D-10;
ik = i0 + dik + idot*tk;
% Calculate omega's
omega0 = -1.277163944970D+00;
omegadot = -7.829254691310D-09;
omegak = omega0 + (omegadot-omega_e_dot)*tk - omega_e_dot*toe;
% Calculate xkp and ykp
xkp = rk*cos(uk);
ykp = rk*sin(uk);
% Calculate xk,yk,zk -> Xs, Ys, Zs for time ts
xk = xkp*cos(omegak) - ykp*cos(ik)*sin(omegak);
yk = xkp*sin(omegak) + ykp*cos(ik)*cos(omegak);
zk = ykp*sin(ik);
