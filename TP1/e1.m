clc; clear; close all;

% --- Parámetros ---
fs = 2;              % Frecuencia de la señal (Hz)
fm = 100;            % Frecuencia de muestreo (Hz)
T = 1;               % Duración en segundos
t = 0:1/fm:T;        % Vector de tiempo discreto

% --- Señal Continua (Muestreada) ---
x = sin(2*pi*fs*t);  % Amplitud entre -1 y 1 (Vpp = 2V)

% --- Función para cuantificar ---
% N: número de bits
cuantificar = @(sig, bits) ...
  round(((sig - min(sig)) / (max(sig) - min(sig))) * (2^bits - 1)) ... % Obtener el valor entero correspondiente al nivel de cuantificación
  * ((max(sig) - min(sig)) / (2^bits - 1)) + min(sig); % Multiplicar por el valor de paso y sumar el mínimo para obtener la señal cuantificada

% --- Generación en distintas resoluciones ---
x_2bits = cuantificar(x, 2); % 4 niveles de amplitud
x_3bits = cuantificar(x, 3); % 8 niveles de amplitud
x_8bits = cuantificar(x, 8); % 256 niveles de amplitud

% --- Gráfica comparativa ---
figure;
subplot(3,1,1);
stairs(t, x_2bits, 'r', 'LineWidth', 1.5); hold on; plot(t, x, 'k--');
title('Resolución de 2 bits (4 niveles de amplitud)'); ylabel('Volts'); grid on;

subplot(3,1,2);
stairs(t, x_3bits, 'g', 'LineWidth', 1.5); hold on; plot(t, x, 'k--');
title('Resolución de 3 bits (8 niveles de amplitud)'); ylabel('Volts'); grid on;

subplot(3,1,3);
stairs(t, x_8bits, 'b', 'LineWidth', 1.5); hold on; plot(t, x, 'k--');
title('Resolución de 8 bits (256 niveles - casi continua)'); ylabel('Volts'); grid on;
xlabel('Tiempo (s)');