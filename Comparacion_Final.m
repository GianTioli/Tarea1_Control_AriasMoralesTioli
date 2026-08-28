clear
clc
close all

G = tf(2.7157,[0.097505 1],'InputDelay',0.0025);

C_TL = pid(10.3610,475.7990,0.016279);
C_Tuner = pid(0.59014,8.5172,0);

T_Planta = feedback(G,1);
T_TL = feedback(C_TL*G,1);
T_Tuner = feedback(C_Tuner*G,1);

t = 0:0.0005:0.35;

y_planta = step(T_Planta,t);
y_TL = step(T_TL,t);
y_Tuner = step(T_Tuner,t);

figure
plot(t,ones(size(t)),'--','LineWidth',1)
hold on
plot(t,y_planta,'LineWidth',1.5)
plot(t,y_TL,'LineWidth',1.5)
plot(t,y_Tuner,'LineWidth',1.5)

grid on
xlabel('Tiempo [s]')
ylabel('Salida')
title('Comparación de los controladores seleccionados')
legend('Referencia','Planta sin controlador','PID Tyreus-Luyben','PID Tuner ajustado','Location','best')
xlim([0 0.35])
ylim([0 1.1])
