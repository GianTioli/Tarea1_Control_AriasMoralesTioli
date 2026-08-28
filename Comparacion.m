clear
clc
close all

% Planta
K = 2.7157;
tau = 0.097505;
G = tf(K,[tau 1]);

% PID finalista de Tyreus-Luyben
Kp_TL = 10.3610;
Ki_TL = 475.7990;
Kd_TL = 0.016279;
C_TL = pid(Kp_TL,Ki_TL,Kd_TL);

% Controlador ajustado mediante PID Tuner
Kp_Tuner = 0.59014;
Ki_Tuner = 8.5172;
Kd_Tuner = 0;
C_Tuner = pid(Kp_Tuner,Ki_Tuner,Kd_Tuner);

% Sistemas en lazo cerrado sobre la misma planta G
T_planta = feedback(G,1);
T_TL = feedback(C_TL*G,1);
T_Tuner = feedback(C_Tuner*G,1);

% Comparacion grafica
t = 0:0.0001:0.35;

[y_planta,~] = step(T_planta,t);
[y_TL,~] = step(T_TL,t);
[y_Tuner,~] = step(T_Tuner,t);

figure('Color','w')
plot(t,ones(size(t)),':','Color',[0 0.4470 0.7410],...
    'LineWidth',1.5)
hold on
plot(t,squeeze(y_planta),'Color',[0.8500 0.3250 0.0980],...
    'LineWidth',1.5)
plot(t,squeeze(y_TL),'Color',[0.4660 0.6740 0.1880],...
    'LineWidth',1.5)
plot(t,squeeze(y_Tuner),'Color',[0.8500 0.1500 0.1500],...
    'LineWidth',1.5)
grid on
xlabel('Tiempo (s)')
ylabel('Salida')
legend('Referencia',...
       'Planta sin controlador',...
       'PID Tyreus-Luyben',...
       'PID Tuner ajustado',...
       'Location','southeast')
xlim([0 0.35])
ylim([-0.05 1.10])
hold off

% Indicadores de desempeno
S_TL = stepinfo(T_TL,...
    'RiseTimeLimits',[0.1 0.9],...
    'SettlingTimeThreshold',0.02);

S_Tuner = stepinfo(T_Tuner,...
    'RiseTimeLimits',[0.1 0.9],...
    'SettlingTimeThreshold',0.02);

ess_TL = abs(1-dcgain(T_TL))*100;
ess_Tuner = abs(1-dcgain(T_Tuner))*100;

Comparacion_Final = table(...
    [S_TL.RiseTime; S_Tuner.RiseTime],...
    [S_TL.SettlingTime; S_Tuner.SettlingTime],...
    [S_TL.Overshoot; S_Tuner.Overshoot],...
    [ess_TL; ess_Tuner],...
    'VariableNames',{'tr(s)','ts(s)','Mp(%)','ess(%)'},...
    'RowNames',{'PID_Tyreus_Luyben','PI_PID_Tuner_ajustado'});

disp(Comparacion_Final)
