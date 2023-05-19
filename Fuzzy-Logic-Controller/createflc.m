flc =  mamfis;
flc.andMethod = 'min';
flc.defuzzMethod = 'centroid';
flc.orMethod = 'max';
flc.ImplicationMethod = "prod";

%trimf: stands for triangular membership function
A = 1;
flc = addvar(flc,'input', 'e',[-A,A]);
flc = addmf(flc, 'input', 1, 'NL', 'trimf', [-4*A/3 -A -2*A/3]);
flc = addmf(flc, 'input', 1, 'NM', 'trimf', [-A -2*A/3 -A/3]);
flc = addmf(flc, 'input', 1, 'NS', 'trimf', [-2*A/3 -A/3 0]);
flc = addmf(flc, 'input', 1, 'ZR', 'trimf', [-A/3 0 A/3]);
flc = addmf(flc, 'input', 1, 'PS', 'trimf', [0 A/3 2*A/3]);
flc = addmf(flc, 'input', 1, 'PM', 'trimf', [A/3 2*A/3 A]);
flc = addmf(flc, 'input', 1, 'PL', 'trimf', [2*A/3 A 4*A/3]);


flc = addvar(flc,'input', 'De',[-A,A]);
flc = addmf(flc, 'input', 2, 'NL', 'trimf', [-4*A/3 -A -2*A/3]);
flc = addmf(flc, 'input', 2, 'NM', 'trimf', [-A -2*A/3 -A/3]);
flc = addmf(flc, 'input', 2, 'NS', 'trimf', [-2*A/3 -A/3 0]);
flc = addmf(flc, 'input', 2, 'ZR', 'trimf', [-A/3 0 A/3]);
flc = addmf(flc, 'input', 2, 'PS', 'trimf', [0 A/3 2*A/3]);
flc = addmf(flc, 'input', 2, 'PM', 'trimf', [A/3 2*A/3 A]);
flc = addmf(flc, 'input', 2, 'PL', 'trimf', [2*A/3 A 4*A/3]);

flc = addvar(flc, 'output', 'Du', [-A A]);
flc = addmf(flc, 'output', 1, 'NV', 'trimf', [-5*A/4 -A -3*A/4]);
flc = addmf(flc, 'output', 1, 'NL', 'trimf', [-A -3*A/4 -A/2]);
flc = addmf(flc, 'output', 1, 'NM', 'trimf', [-3*A/4 -A/2 -A/4]);
flc = addmf(flc, 'output', 1, 'NS', 'trimf', [-A/2 -A/4 0]);
flc = addmf(flc, 'output', 1, 'ZR', 'trimf', [-A/4 0 A/4]);
flc = addmf(flc, 'output', 1, 'PS', 'trimf', [0 A/4 A/2]);
flc = addmf(flc, 'output', 1, 'PM', 'trimf', [A/4 A/2 3*A/4]);
flc = addmf(flc, 'output', 1, 'PL', 'trimf', [A/2 3*A/4 A]);
flc = addmf(flc, 'output', 1, 'PV', 'trimf', [3*A/4 A 5*A/4]);


%define rulebase based on figures 2a and 2b
rulebase =[
        'If (e is NL) and (De is NL) then (Du is NL) (1)';
        'If (e is NL) and (De is NM) then (Du is NL) (1)';
        'If (e is NL) and (De is NS) then (Du is NL) (1)';
        'If (e is NL) and (De is ZR) then (Du is NL) (1)';
        'If (e is NL) and (De is PS) then (Du is NM) (1)';
        'If (e is NL) and (De is PM) then (Du is NS) (1)';
        'If (e is NL) and (De is PL) then (Du is ZR) (1)';
        'If (e is NM) and (De is NL) then (Du is NL) (1)';
        'If (e is NM) and (De is NM) then (Du is NL) (1)';
        'If (e is NM) and (De is NS) then (Du is NL) (1)';
        'If (e is NM) and (De is ZR) then (Du is NM) (1)';
        'If (e is NM) and (De is PS) then (Du is NS) (1)';
        'If (e is NM) and (De is PM) then (Du is ZR) (1)';
        'If (e is NM) and (De is PL) then (Du is PS) (1)';
        'If (e is NS) and (De is NL) then (Du is NL) (1)';
        'If (e is NS) and (De is NM) then (Du is NL) (1)';
        'If (e is NS) and (De is NS) then (Du is NM) (1)';
        'If (e is NS) and (De is ZR) then (Du is NS) (1)';
        'If (e is NS) and (De is PS) then (Du is ZR) (1)';
        'If (e is NS) and (De is PM) then (Du is PS) (1)';
        'If (e is NS) and (De is PL) then (Du is PM) (1)';
        'If (e is ZR) and (De is NL) then (Du is NL) (1)';
        'If (e is ZR) and (De is NM) then (Du is NM) (1)';
        'If (e is ZR) and (De is NS) then (Du is NS) (1)';
        'If (e is ZR) and (De is ZR) then (Du is ZR) (1)';
        'If (e is ZR) and (De is PS) then (Du is PS) (1)';
        'If (e is ZR) and (De is PM) then (Du is PM) (1)';
        'If (e is ZR) and (De is PL) then (Du is PL) (1)';
        'If (e is PS) and (De is NL) then (Du is NM) (1)';
        'If (e is PS) and (De is NM) then (Du is NS) (1)';
        'If (e is PS) and (De is NS) then (Du is ZR) (1)';
        'If (e is PS) and (De is ZR) then (Du is PS) (1)';
        'If (e is PS) and (De is PS) then (Du is PM) (1)';
        'If (e is PS) and (De is PM) then (Du is PL) (1)';
        'If (e is PS) and (De is PL) then (Du is PL) (1)';
        'If (e is PM) and (De is NL) then (Du is NS) (1)';
        'If (e is PM) and (De is NM) then (Du is ZR) (1)';
        'If (e is PM) and (De is NS) then (Du is PS) (1)';
        'If (e is PM) and (De is ZR) then (Du is PM) (1)';
        'If (e is PM) and (De is PS) then (Du is PL) (1)';
        'If (e is PM) and (De is PM) then (Du is PL) (1)';
        'If (e is PM) and (De is PL) then (Du is PL) (1)';
        'If (e is PL) and (De is NL) then (Du is ZR) (1)';
        'If (e is PL) and (De is NM) then (Du is PS) (1)';
        'If (e is PL) and (De is NS) then (Du is PM) (1)';
        'If (e is PL) and (De is ZR) then (Du is PL) (1)';
        'If (e is PL) and (De is PS) then (Du is PL) (1)';
        'If (e is PL) and (De is PM) then (Du is PL) (1)';
        'If (e is PL) and (De is PL) then (Du is PL) (1)';];

flc = parsrule(flc, rulebase);
f = figure('pos',[10 10 800 600]);
subplot(3,1,1)
plotmf(flc,'input',1)
title('Fuzzy Set of the e variable')
subplot(3,1,2)
plotmf(flc,'input',2)
title('Fuzzy Set of the e variable')
subplot(3,1,3)
title('Fuzzy Set of the u variable')
plotmf(flc,'output',1)
saveas(f,'./img/Fuzzy_Sets.png','png')
showrule(flc)
writeFIS(flc,'DC_Motor_07.fis');