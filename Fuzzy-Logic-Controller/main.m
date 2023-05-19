%initialize all the parameters
wmax=150;
Va=200;

%formulas of kp and ki
kp = Va/wmax;
m=15;
ki=kp*m;

%implement Hc(s) function
Hc1 = 18.69*[kp,ki];
Hc2 = [1 12.064+18.69*kp 18.69*ki];
%Continuous-time transfer function 
Hc=tf(Hc1,Hc2);
info=stepinfo(Hc);
%we have rise time 0.0736 or 73,6ms
%so we are below 160msec



%about Fuzzy PI controller
a = 1 / m;
Ke = 1;
Kd = a*Ke;
K1 = kp / (a * Ke);

%new values of Fuzzy PI Controller
Ke_new = 1.237;
K1_new = 26.7;
a_new = 0.0352;
Kd_new = 0.0435;
gensurf('FLC07.fis');
%new values on case 2
Ke_new2 = 1.45;
a_new2 = 0.046;
Kd_new2 = 0.07;
Ki_new2 = 31;
