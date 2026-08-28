clear 
clc
close all 

%Planta
K = 2.7157; 
tau = 0.097505;
Ts = 0.0025; 

G = tf(K,[tau 1]);

disp('Planta identificada: ')
G

%%Retardo efectivo asociado al muestreo y obtención de parámetros
Lef = Ts; 

G_L = tf(K,[tau 1], 'InputDelay', Lef); 
disp('Planta con retardo efectivo: ')
G_L

%% Ziegler-Nichols Abierto 

%Controlador P

Ti_P = Inf;
Td_P = 0;

Kp_ZN_P = (tau/(K * Lef));
Ki_ZN_P = 0; 
Kd_ZN_P = 0;

C_ZN_P = pid(Kp_ZN_P, Ki_ZN_P,Kd_ZN_P);

fprintf('\nZN - CONTROLADOR P\n')
fprintf('Kp = %.8f\n',Kp_ZN_P)
fprintf('Ki = %.8f\n',Ki_ZN_P)
fprintf('Kd = %.8f\n',Kd_ZN_P)
fprintf('Ti = %.8f\n', Ti_P)
fprintf('Td = %.8f\n', Td_P)


%CONTROLADOR PI 

%Variables a necesitar
Ti_PI = (Lef/0.3); 
Td_PI = 0;


Kp_ZN_PI = 0.9*Kp_ZN_P; 
Ki_ZN_PI = (Kp_ZN_PI/Ti_PI);
Kd_ZN_PI = 0;

C_ZN_PI = pid(Kp_ZN_PI,Ki_ZN_PI,Kd_ZN_PI); 

fprintf('\nZN - CONTROLADOR PI\n')
fprintf('Kp = %.8f\n',Kp_ZN_PI)
fprintf('Ki = %.8f\n',Ki_ZN_PI)
fprintf('Kd = %.8f\n',Kd_ZN_PI)
fprintf('Ti = %.8f\n', Ti_PI)
fprintf('Td = %.8f\n', Td_PI)

%CONTROLADOR PID

%Variables que se van a necesitar 

Ti_PID = (2*Lef);
Td_PID = (0.5*Lef); 


Kp_ZN_PID = (1.2*Kp_ZN_P);

Ki_ZN_PID = (Kp_ZN_PID/Ti_PID);
Kd_ZN_PID = (Kp_ZN_PID*Td_PID);

C_ZN_PID = pid(Kp_ZN_PID,Ki_ZN_PID,Kd_ZN_PID);

fprintf('\nZN - CONTROLADOR PID\n')
fprintf('Kp = %.8f\n',Kp_ZN_PID)
fprintf('Ki = %.8f\n',Ki_ZN_PID)
fprintf('Kd = %.8f\n',Kd_ZN_PID)
fprintf('Ti = %.8f\n',Ti_PID)
fprintf(' Td = %.8f\n',Td_PID)

%%Lazos cerrados de Ziegler-Nichols
T_planta = feedback(G,1); 

T_ZN_P = feedback(C_ZN_P*G, 1);
T_ZN_PI = feedback(C_ZN_PI*G, 1);
T_ZN_PID = feedback(C_ZN_PID*G, 1);

%Tiempo de simulación 
t = 0:0.0001:0.3; 

%Gráfica 
figure 
step(T_planta,T_ZN_P,T_ZN_PI,T_ZN_PID, t)
grid on

set(findall(gcf, 'Type', 'line'), 'LineWidth',2)
title('Respuesta en lazo cerrado mediante Ziegler-Nichols Abierto')
xlabel('Tiempo(s)')
ylabel('Salida')

legend('Planta sin controlador',...
       'Controlador P',...
       'Controlador PI',...
       'Controlador PID',...
       'Location','best')


%Tabla de constantes ZN

Tabla_ZN = table(...
    [Kp_ZN_P; Kp_ZN_PI; Kp_ZN_PID],...
    [Ki_ZN_P; Ki_ZN_PI; Ki_ZN_PID],...
    [Kd_ZN_P; Kd_ZN_PI; Kd_ZN_PID],...
    [Inf; Ti_PI; Ti_PID],...
    [0; 0;Td_PID],...
    'VariableNames',{'Kp','Ki','Kd','Ti_s','Td_s'},...
    'RowNames',{'P','PI','PID'});

disp(Tabla_ZN)

%% Resultados transitorios Ziegler-Nichols Abierto

S_ZN_P   = stepinfo(T_ZN_P);
S_ZN_PI  = stepinfo(T_ZN_PI);
S_ZN_PID = stepinfo(T_ZN_PID);

% Error de estado estacionario en porcentaje
ess_ZN_P   = abs(1-dcgain(T_ZN_P))*100;
ess_ZN_PI  = abs(1-dcgain(T_ZN_PI))*100;
ess_ZN_PID = abs(1-dcgain(T_ZN_PID))*100;

Resultados_ZN = table(...
    [S_ZN_P.RiseTime; S_ZN_PI.RiseTime; S_ZN_PID.RiseTime],...
    [S_ZN_P.SettlingTime; S_ZN_PI.SettlingTime; S_ZN_PID.SettlingTime],...
    [S_ZN_P.Overshoot; S_ZN_PI.Overshoot; S_ZN_PID.Overshoot],...
    [ess_ZN_P; ess_ZN_PI; ess_ZN_PID],...
    'VariableNames',{'Tiempo_levantamiento_s',...
                     'Tiempo_estabilizacion_s',...
                     'Sobreimpulso_porcentaje',...
                     'Error_estacionario_porcentaje'},...
    'RowNames',{'P','PI','PID'});

disp(Resultados_ZN)



%% Cohen-Coon

r = Lef/tau;

fprintf('\nCOHEN-COON\n')
fprintf('r = %.8f\n',r)

% CONTROLADOR P

Ti_CC_P = Inf;
Td_CC_P = 0;

Kp_CC_P = (1/(K*r))*(1 + r/3);
Ki_CC_P = 0;
Kd_CC_P = 0;

C_CC_P = pid(Kp_CC_P,Ki_CC_P,Kd_CC_P);

fprintf('\nCOHEN-COON - CONTROLADOR P\n')
fprintf('Kp = %.8f\n',Kp_CC_P)
fprintf('Ki = %.8f\n',Ki_CC_P)
fprintf('Kd = %.8f\n',Kd_CC_P)
fprintf('Ti = %.8f\n',Ti_CC_P)
fprintf('Td = %.8f\n',Td_CC_P)


% CONTROLADOR PI

Ti_CC_PI = Lef*((30 + 3*r)/(9 + 20*r));
Td_CC_PI = 0;

Kp_CC_PI = (1/(K*r))*(0.9 + r/12);

Ki_CC_PI = Kp_CC_PI/Ti_CC_PI;
Kd_CC_PI = 0;

C_CC_PI = pid(Kp_CC_PI,Ki_CC_PI,Kd_CC_PI);

fprintf('\nCOHEN-COON - CONTROLADOR PI\n')
fprintf('Kp = %.8f\n',Kp_CC_PI)
fprintf('Ki = %.8f\n',Ki_CC_PI)
fprintf('Kd = %.8f\n',Kd_CC_PI)
fprintf('Ti = %.8f\n',Ti_CC_PI)
fprintf('Td = %.8f\n',Td_CC_PI)


% CONTROLADOR PID

Ti_CC_PID = Lef*((32 + 6*r)/(13 + 8*r));
Td_CC_PID = Lef*(4/(11 + 2*r));

Kp_CC_PID = (1/(K*r))*((4/3) + r/4);

Ki_CC_PID = Kp_CC_PID/Ti_CC_PID;
Kd_CC_PID = Kp_CC_PID*Td_CC_PID;

C_CC_PID = pid(Kp_CC_PID,Ki_CC_PID,Kd_CC_PID);

fprintf('\nCOHEN-COON - CONTROLADOR PID\n')
fprintf('Kp = %.8f\n',Kp_CC_PID)
fprintf('Ki = %.8f\n',Ki_CC_PID)
fprintf('Kd = %.8f\n',Kd_CC_PID)
fprintf('Ti = %.8f\n',Ti_CC_PID)
fprintf('Td = %.8f\n',Td_CC_PID)

T_CC_P   = feedback(C_CC_P*G,1);
T_CC_PI  = feedback(C_CC_PI*G,1);
T_CC_PID = feedback(C_CC_PID*G,1);

%% Gráfica Cohen-Coon

t = 0:0.0001:0.3;

figure
step(T_planta,T_CC_P,T_CC_PI,T_CC_PID,t)
grid on

set(findall(gcf,'Type','line'),'LineWidth',2)

title('Respuesta en lazo cerrado mediante Cohen-Coon')
xlabel('Tiempo (s)')
ylabel('Salida')

legend('Planta sin controlador',...
       'Controlador P',...
       'Controlador PI',...
       'Controlador PID',...
       'Location','best')

%% Tabla de constantes Cohen-Coon

Tabla_CC = table(...
    [Kp_CC_P; Kp_CC_PI; Kp_CC_PID],...
    [Ki_CC_P; Ki_CC_PI; Ki_CC_PID],...
    [Kd_CC_P; Kd_CC_PI; Kd_CC_PID],...
    [Ti_CC_P; Ti_CC_PI; Ti_CC_PID],...
    [Td_CC_P; Td_CC_PI; Td_CC_PID],...
    'VariableNames',{'Kp','Ki','Kd','Ti_s','Td_s'},...
    'RowNames',{'P','PI','PID'});

disp(Tabla_CC)

%% Resultados transitorios Cohen-Coon

S_CC_P   = stepinfo(T_CC_P);
S_CC_PI  = stepinfo(T_CC_PI);
S_CC_PID = stepinfo(T_CC_PID);

% Error de estado estacionario en porcentaje
ess_CC_P   = abs(1-dcgain(T_CC_P))*100;
ess_CC_PI  = abs(1-dcgain(T_CC_PI))*100;
ess_CC_PID = abs(1-dcgain(T_CC_PID))*100;

Resultados_CC = table(...
    [S_CC_P.RiseTime; S_CC_PI.RiseTime; S_CC_PID.RiseTime],...
    [S_CC_P.SettlingTime; S_CC_PI.SettlingTime; S_CC_PID.SettlingTime],...
    [S_CC_P.Overshoot; S_CC_PI.Overshoot; S_CC_PID.Overshoot],...
    [ess_CC_P; ess_CC_PI; ess_CC_PID],...
    'VariableNames',{'Tiempo_levantamiento_s',...
                     'Tiempo_estabilizacion_s',...
                     'Sobreimpulso_porcentaje',...
                     'Error_estacionario_porcentaje'},...
    'RowNames',{'P','PI','PID'});

disp(Resultados_CC)
