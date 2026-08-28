clear
clc
close all

G = tf(2.7157,[0.097505 1]);

C_Tuner = pid(0.59014,8.5172,0);
T_Tuner = feedback(C_Tuner*G,1);

info_Tuner = stepinfo(T_Tuner);
ess_Tuner = abs(1-dcgain(T_Tuner));

figure
step(T_Tuner,0.5)
grid on
title('Respuesta del controlador ajustado mediante PID Tuner')
xlabel('Tiempo [s]')
ylabel('Salida')

info_Tuner
fprintf('Error estado estacionario = %.6f\n',ess_Tuner)
