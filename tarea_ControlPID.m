clear
clc
close all

datos = readtable("Motor.csv");


%% Comprobacion de offsets y tiempos de muestreo
% Datos previos a t = 0
reposo = datos.Tiempo < 0;

% Offset de las señales
u0 = mean(datos.Entrada(reposo));
y0 = mean(datos.Velocidad(reposo));

fprintf("Offset entrada = %.4f\n", u0)
fprintf("Offset velocidad = %.4f\n", y0)


%% Eliminacion de muestreo negativo y correccion de offset
% Eliminar muestras con tiempo negativo
datos = datos(datos.Tiempo >= 0, :);

% Corregir offsets
datos.Entrada = datos.Entrada - u0;
datos.Velocidad = datos.Velocidad - y0;

fprintf("Primer tiempo = %.4f s\n", datos.Tiempo(1))
fprintf("Numero de muestras restantes = %d\n", height(datos))


%% Comprobacion columna de tiempos
dt = diff(datos.Tiempo);

fprintf("Incremento minimo = %.4f s\n", min(dt))
fprintf("Incremento maximo = %.4f s\n", max(dt))
fprintf("Tiempos repetidos = %d\n", sum(dt == 0))


t_final = datos.Tiempo(end);

Ts_estimado = (t_final - datos.Tiempo(1)) / (height(datos)-1);

fprintf("Tiempo final = %.4f s\n", t_final)
fprintf("Ts estimado = %.6f s\n", Ts_estimado)


Ts = 0.0025;
N = height(datos);

datos.Tiempo = (0:N-1)' * Ts;
dt = diff(datos.Tiempo);

fprintf("Primer tiempo = %.4f s\n", datos.Tiempo(1))
fprintf("Ultimo tiempo = %.4f s\n", datos.Tiempo(end))
fprintf("Ts minimo = %.6f s\n", min(dt))
fprintf("Ts maximo = %.6f s\n", max(dt))


%% Verificacion de datos corregidos
figure

subplot(2,1,1)
plot(datos.Tiempo, datos.Entrada)
grid on
ylabel('Entrada')
title('Datos corregidos')

subplot(2,1,2)
plot(datos.Tiempo, datos.Velocidad)
grid on
ylabel('Velocidad')
xlabel('Tiempo [s]')

%% Graficacion de los datos originales

datos_originales = readtable("Motor.csv");

figure

subplot(3,1,1)
plot(datos_originales.Tiempo, datos_originales.Entrada)
grid on
ylabel('Entrada')
title('Datos originales')

subplot(3,1,2)
plot(datos_originales.Tiempo, datos_originales.Velocidad)
grid on
ylabel('Velocidad')

subplot(3,1,3)
plot(datos_originales.Tiempo, datos_originales.Corriente)
grid on
ylabel('Corriente')
xlabel('Tiempo [s]')


%% Tratamiento de la señal
% Promedios aproximadamente en régimen permanente de cada pulso
yss1 = mean(datos.Velocidad(datos.Tiempo >= 0.4 & datos.Tiempo <= 0.6));
yss2 = mean(datos.Velocidad(datos.Tiempo >= 1.7 & datos.Tiempo <= 1.9));
yss3 = mean(datos.Velocidad(datos.Tiempo >= 3.2 & datos.Tiempo <= 3.5));

fprintf("Velocidad estacionaria 1 = %.4f\n", yss1)
fprintf("Velocidad estacionaria 2 = %.4f\n", yss2)
fprintf("Velocidad estacionaria 3 = %.4f\n", yss3)

%% Comprobación de ganancia estática
uss1 = mean(datos.Entrada(datos.Tiempo >= 0.4 & datos.Tiempo <= 0.6));
uss2 = mean(datos.Entrada(datos.Tiempo >= 1.7 & datos.Tiempo <= 1.9));
uss3 = mean(datos.Entrada(datos.Tiempo >= 3.2 & datos.Tiempo <= 3.5));

K1 = yss1/uss1;
K2 = yss2/uss2;
K3 = yss3/uss3;

fprintf("Entrada estacionaria 1 = %.4f, K1 = %.4f\n", uss1, K1)
fprintf("Entrada estacionaria 2 = %.4f, K2 = %.4f\n", uss2, K2)
fprintf("Entrada estacionaria 3 = %.4f, K3 = %.4f\n", uss3, K3)


%% Creación del objeto de identifiación
Ts = 0.0025;

data_id = iddata(datos.Velocidad, datos.Entrada, Ts);

data_id.InputName = 'Entrada';
data_id.OutputName = 'Velocidad';
data_id.TimeUnit = 'seconds';
