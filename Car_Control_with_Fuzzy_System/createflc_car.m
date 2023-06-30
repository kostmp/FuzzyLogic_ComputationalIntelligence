%create first flc
flc = mamfis;
flc.andMethod = 'min';
flc.defuzzMethod = 'centroid';
flc.orMethod = 'max';
flc.ImplicationMethod = 'min';
flc.AggregationMethod = 'max';
flc.DefuzzificationMethod = 'centroid';

flc = addvar(flc,'input','dh',[0 1]);
flc = addmf(flc,'input',1,'S','trimf',[-0.5 0 0.5]);
flc = addmf(flc,'input',1,'M','trimf',[0 0.5 1]);
flc = addmf(flc,'input',1,'L','trimf',[0.5 1 1.5]);

flc = addvar(flc,'input','dv',[0 1]);
flc = addmf(flc,'input',2,'S','trimf',[-0.5 0 0.5]);
flc = addmf(flc,'input',2,'M','trimf',[0 0.5 1]);
flc = addmf(flc,'input',2,'L','trimf',[0.5 1 1.5]);

flc = addvar(flc,'input','theta',[-180 180]);
flc = addmf(flc,'input',3,'N','trimf',[-360 -180 0]);
flc = addmf(flc,'input',3,'Z','trimf',[-180 0 180]);
flc = addmf(flc,'input',3,'P','trimf',[0 180 360]);

flc = addvar(flc,'output','dtheta',[-130 130]);
flc = addmf(flc,'output',1,'N','trimf',[-260 -130 0]);
flc = addmf(flc,'output',1,'Z','trimf',[-130 0 130]);
flc = addmf(flc,'output',1,'P','trimf',[0 130 260]);

rulebase = [
    'If (dh is S) and (dv is S) and (theta is N) then (dtheta is P) (1)';
    'If (dh is S) and (dv is M) and (theta is N) then (dtheta is P) (1)';
    'If (dh is S) and (dv is L) and (theta is N) then (dtheta is P) (1)';
    'If (dh is M) and (dv is S) and (theta is N) then (dtheta is P) (1)';
    'If (dh is M) and (dv is M) and (theta is N) then (dtheta is P) (1)';
    'If (dh is M) and (dv is L) and (theta is N) then (dtheta is P) (1)';
    'If (dh is L) and (dv is S) and (theta is N) then (dtheta is P) (1)';
    'If (dh is L) and (dv is M) and (theta is N) then (dtheta is P) (1)';
    'If (dh is L) and (dv is L) and (theta is N) then (dtheta is P) (1)';
    'If (dh is S) and (dv is S) and (theta is P) then (dtheta is P) (1)';
    'If (dh is S) and (dv is M) and (theta is P) then (dtheta is P) (1)';
    'If (dh is S) and (dv is L) and (theta is P) then (dtheta is P) (1)';
    'If (dh is M) and (dv is S) and (theta is P) then (dtheta is Z) (1)';
    'If (dh is M) and (dv is M) and (theta is P) then (dtheta is Z) (1)';
    'If (dh is M) and (dv is L) and (theta is P) then (dtheta is Z) (1)';
    'If (dh is L) and (dv is S) and (theta is P) then (dtheta is Z) (1)';
    'If (dh is L) and (dv is M) and (theta is P) then (dtheta is Z) (1)';
    'If (dh is L) and (dv is L) and (theta is P) then (dtheta is Z) (1)';
    'If (dh is S) and (dv is S) and (theta is Z) then (dtheta is Z) (1)';
    'If (dh is S) and (dv is M) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is S) and (dv is L) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is M) and (dv is S) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is M) and (dv is M) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is M) and (dv is L) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is L) and (dv is S) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is L) and (dv is M) and (theta is Z) then (dtheta is N) (1)';
    'If (dh is L) and (dv is L) and (theta is Z) then (dtheta is P) (1)';
];
flc = parsrule(flc,rulebase);
writeFIS(flc,'C_CarControl1.fis');
