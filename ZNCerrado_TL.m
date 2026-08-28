clear
clc
close all

% Planta
K = 2.7157;
tau = 0.097505;
Ts = 0.0025;

G = tf(K,[tau 1]);

disp('Planta identificada:')
G

%% Retardo efectivo asociado al muestreo y obtencion de parametros
Lef = Ts;

G_L = tf(K,[tau 1],'InputDelay',Lef);

disp('Planta con retardo efectivo:')
G_L

% Obtencion de Ku y Pu
figure
margin(G_L)
grid on
title('Obtención computacional de Ku y Pu')

[Ku,~,Wu,~] = margin(G_L);

Pu = 2*pi/Wu;

fprintf('\nPARÁMETROS ÚLTIMOS\n')
fprintf('Ku = %.8f\n',Ku)
fprintf('Wu = %.8f rad/s\n',Wu)
fprintf('Pu = %.8f s\n',Pu)

% Comprobacion de oscilaciones sostenidas
C_ultima = pid(Ku,0,0);
T_ultima = feedback(C_ultima*G_L,1);

figure
step(T_ultima,0.1)
grid on
set(findall(gcf,'Type','line'),'LineWidth',2)
title(sprintf('Oscilaciones sostenidas: Ku = %.4f',Ku))
xlabel('Tiempo (s)')
ylabel('Salida')

%% Ziegler-Nichols cerrado

% Controlador P

Kp_ZN_P = 0.5*Ku;
Ki_ZN_P = 0;
Kd_ZN_P = 0;

C_ZN_P = pid(Kp_ZN_P,Ki_ZN_P,Kd_ZN_P);

fprintf('\nZN - CONTROLADOR P\n')
fprintf('Kp = %.8f\n',Kp_ZN_P)
fprintf('Ki = %.8f\n',Ki_ZN_P)
fprintf('Kd = %.8f\n',Kd_ZN_P)

% Controlador PI

Kp_ZN_PI = 0.45*Ku;
Ti_ZN_PI = Pu/1.2;

Ki_ZN_PI = Kp_ZN_PI/Ti_ZN_PI;
Kd_ZN_PI = 0;

C_ZN_PI = pid(Kp_ZN_PI,Ki_ZN_PI,Kd_ZN_PI);

fprintf('\nZN - CONTROLADOR PI\n')
fprintf('Kp = %.8f\n',Kp_ZN_PI)
fprintf('Ti = %.8f s\n',Ti_ZN_PI)
fprintf('Ki = %.8f\n',Ki_ZN_PI)
fprintf('Kd = %.8f\n',Kd_ZN_PI)

% Controlador PID

Kp_ZN_PID = 0.6*Ku;
Ti_ZN_PID = 0.5*Pu;
Td_ZN_PID = 0.125*Pu;

Ki_ZN_PID = Kp_ZN_PID/Ti_ZN_PID;
Kd_ZN_PID = Kp_ZN_PID*Td_ZN_PID;

C_ZN_PID = pid(Kp_ZN_PID,Ki_ZN_PID,Kd_ZN_PID);

fprintf('\nZN - CONTROLADOR PID\n')
fprintf('Kp = %.8f\n',Kp_ZN_PID)
fprintf('Ti = %.8f s\n',Ti_ZN_PID)
fprintf('Td = %.8f s\n',Td_ZN_PID)
fprintf('Ki = %.8f\n',Ki_ZN_PID)
fprintf('Kd = %.8f\n',Kd_ZN_PID)

%% Lazos cerrados de Ziegler-Nichols
T_planta = feedback(G,1);

T_ZN_P   = feedback(C_ZN_P*G,1);
T_ZN_PI  = feedback(C_ZN_PI*G,1);
T_ZN_PID = feedback(C_ZN_PID*G,1);

t = 0:0.0001:0.3;

figure
step(T_planta,T_ZN_P,T_ZN_PI,T_ZN_PID,t)
grid on

set(findall(gcf,'Type','line'),'LineWidth',2)
title('Respuestas en lazo cerrado mediante Ziegler-Nichols')
xlabel('Tiempo (s)')
ylabel('Salida')

legend('Planta sin controlador',...
       'Controlador P',...
       'Controlador PI',...
       'Controlador PID',...
       'Location','best')

Tabla_ZN = table(...
    [Kp_ZN_P; Kp_ZN_PI; Kp_ZN_PID],...
    [Ki_ZN_P; Ki_ZN_PI; Ki_ZN_PID],...
    [Kd_ZN_P; Kd_ZN_PI; Kd_ZN_PID],...
    [Inf; Ti_ZN_PI; Ti_ZN_PID],...
    [0; 0; Td_ZN_PID],...
    'VariableNames',{'Kp','Ki','Kd','Ti_s','Td_s'},...
    'RowNames',{'P','PI','PID'});

disp(Tabla_ZN)

S_ZN_P   = stepinfo(T_ZN_P);
S_ZN_PI  = stepinfo(T_ZN_PI);
S_ZN_PID = stepinfo(T_ZN_PID);

ess_ZN_P   = abs(1-dcgain(T_ZN_P));
ess_ZN_PI  = abs(1-dcgain(T_ZN_PI));
ess_ZN_PID = abs(1-dcgain(T_ZN_PID));

Resultados_ZN = table(...
    [S_ZN_P.RiseTime; S_ZN_PI.RiseTime; S_ZN_PID.RiseTime],...
    [S_ZN_P.SettlingTime; S_ZN_PI.SettlingTime; S_ZN_PID.SettlingTime],...
    [S_ZN_P.Overshoot; S_ZN_PI.Overshoot; S_ZN_PID.Overshoot],...
    [ess_ZN_P; ess_ZN_PI; ess_ZN_PID],...
    'VariableNames',{'RiseTime(s)','SettlingTime(s)',...
                     'Overshoot(%)','ErrorEstacionario'},...
    'RowNames',{'P','PI','PID'});

disp(Resultados_ZN)

%% Tyreus-Luyben

% Controlador P

Kp_TL_P = 0.5*Ku;
Ki_TL_P = 0;
Kd_TL_P = 0;

C_TL_P = pid(Kp_TL_P,Ki_TL_P,Kd_TL_P);

fprintf('\nTYREUS-LUYBEN - CONTROLADOR P\n')
fprintf('Kp = %.8f\n',Kp_TL_P)
fprintf('Ki = %.8f\n',Ki_TL_P)
fprintf('Kd = %.8f\n',Kd_TL_P)

% Controlador PI

Kp_TL_PI = Ku/2.2;
Ti_TL_PI = 2.2*Pu;

Ki_TL_PI = Kp_TL_PI/Ti_TL_PI;
Kd_TL_PI = 0;

C_TL_PI = pid(Kp_TL_PI,Ki_TL_PI,Kd_TL_PI);

fprintf('\nTYREUS-LUYBEN - CONTROLADOR PI\n')
fprintf('Kp = %.8f\n',Kp_TL_PI)
fprintf('Ti = %.8f s\n',Ti_TL_PI)
fprintf('Ki = %.8f\n',Ki_TL_PI)
fprintf('Kd = %.8f\n',Kd_TL_PI)

% Controlador PID

Kp_TL_PID = Ku/2.2;
Ti_TL_PID = 2.2*Pu;
Td_TL_PID = Pu/6.3;

Ki_TL_PID = Kp_TL_PID/Ti_TL_PID;
Kd_TL_PID = Kp_TL_PID*Td_TL_PID;

C_TL_PID = pid(Kp_TL_PID,Ki_TL_PID,Kd_TL_PID);

fprintf('\nTYREUS-LUYBEN - CONTROLADOR PID\n')
fprintf('Kp = %.8f\n',Kp_TL_PID)
fprintf('Ti = %.8f s\n',Ti_TL_PID)
fprintf('Td = %.8f s\n',Td_TL_PID)
fprintf('Ki = %.8f\n',Ki_TL_PID)
fprintf('Kd = %.8f\n',Kd_TL_PID)

%% Lazos cerrados de Tyreus-Luyben
T_planta = feedback(G,1);

T_TL_P   = feedback(C_TL_P*G,1);
T_TL_PI  = feedback(C_TL_PI*G,1);
T_TL_PID = feedback(C_TL_PID*G,1);

t = 0:0.0001:0.3;

figure
step(T_planta,T_TL_P,T_TL_PI,T_TL_PID,t)
grid on

set(findall(gcf,'Type','line'),'LineWidth',2)
title('Respuestas en lazo cerrado mediante Tyreus-Luyben')
xlabel('Tiempo (s)')
ylabel('Salida')

legend('Planta sin controlador',...
       'Controlador P',...
       'Controlador PI',...
       'Controlador PID',...
       'Location','best')

Tabla_TL = table(...
    [Kp_TL_P; Kp_TL_PI; Kp_TL_PID],...
    [Ki_TL_P; Ki_TL_PI; Ki_TL_PID],...
    [Kd_TL_P; Kd_TL_PI; Kd_TL_PID],...
    [Inf; Ti_TL_PI; Ti_TL_PID],...
    [0; 0; Td_TL_PID],...
    'VariableNames',{'Kp','Ki','Kd','Ti_s','Td_s'},...
    'RowNames',{'P','PI','PID'});

disp(Tabla_TL)

S_TL_P   = stepinfo(T_TL_P);
S_TL_PI  = stepinfo(T_TL_PI);
S_TL_PID = stepinfo(T_TL_PID);

ess_TL_P   = abs(1-dcgain(T_TL_P));
ess_TL_PI  = abs(1-dcgain(T_TL_PI));
ess_TL_PID = abs(1-dcgain(T_TL_PID));

Resultados_TL = table(...
    [S_TL_P.RiseTime; S_TL_PI.RiseTime; S_TL_PID.RiseTime],...
    [S_TL_P.SettlingTime; S_TL_PI.SettlingTime; S_TL_PID.SettlingTime],...
    [S_TL_P.Overshoot; S_TL_PI.Overshoot; S_TL_PID.Overshoot],...
    [ess_TL_P; ess_TL_PI; ess_TL_PID],...
    'VariableNames',{'RiseTime(s)','SettlingTime(s)',...
                     'Overshoot(%)','ErrorEstacionario'},...
    'RowNames',{'P','PI','PID'});

disp(Resultados_TL)
