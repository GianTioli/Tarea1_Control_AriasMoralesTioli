clear
clc
close all

G = tf(2.7157,[0.097505 1]);

C_Automatico = pid(0.52714,9.7994,0);
C_Ajustado = pid(0.59014,8.5172,0);

T_Automatico = feedback(C_Automatico*G,1);
T_Ajustado = feedback(C_Ajustado*G,1);

t = 0:0.0005:0.5;

y_Automatico = step(T_Automatico,t);
y_Ajustado = step(T_Ajustado,t);

figure('Color','w')
plot(t,ones(size(t)),':','Color',[0 0.4470 0.7410],'LineWidth',1.3)
hold on
plot(t,y_Automatico,'Color',[0.8500 0.3250 0.0980],'LineWidth',1.5)
plot(t,y_Ajustado,'Color',[0.4660 0.6740 0.1880],'LineWidth',1.5)
grid on
xlabel('Tiempo (s)')
ylabel('Amplitud')
title('Respuesta al escalón: sintonización automática y ajustada')
legend('Referencia','PID Tuner automático','PID Tuner ajustado','Location','southeast')
xlim([0 0.5])
ylim([0 1.1])
hold off

S_Automatico = stepinfo(T_Automatico);
S_Ajustado = stepinfo(T_Ajustado);

ess_Automatico = abs(1-dcgain(T_Automatico));
ess_Ajustado = abs(1-dcgain(T_Ajustado));

Resultados = table( ...
    [0.52714; 0.59014], ...
    [9.7994; 8.5172], ...
    [0; 0], ...
    [S_Automatico.RiseTime; S_Ajustado.RiseTime], ...
    [S_Automatico.SettlingTime; S_Ajustado.SettlingTime], ...
    [S_Automatico.Overshoot; S_Ajustado.Overshoot], ...
    [ess_Automatico; ess_Ajustado], ...
    'VariableNames',{'Kp','Ki','Kd','tr_s','ts_s','Mp_porcentaje','ess'}, ...
    'RowNames',{'Automatico','Ajustado'});

disp(Resultados)
