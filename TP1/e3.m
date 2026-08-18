clc; clear; close all;

% --- Parámetros ---
A  = 5;       % Amplitud idéntica para ambas señales
f1 = 10;      % Frecuencia de la primera señal (Hz)
f2 = 25;      % Frecuencia de la segunda señal (Hz)
fs = 200;     % Frecuencia de muestreo (Hz)
N  = 50;      % Cantidad de muestras del registro

% --- Generación de las señales discretas ---
n = 0:N-1;              % Índice de cada muestra
t = n / fs;             % Vector de tiempo discreto (s)

x1 = A * sin(2*pi*f1*t); % Primera señal sinusoidal
x2 = A * sin(2*pi*f2*t); % Segunda señal sinusoidal

% --- Suma de las señales ---
x_sum = x1 + x2;         % Señal resultante

% --- Gráficas ---
figure;

% Gráfica de la primera señal
subplot(3,1,1);
stem(n, x1, 'r', 'filled'); grid on;
title(['Señal 1 (f_1 = ', num2str(f1), ' Hz)']);
ylabel('Amplitud');

% Gráfica de la segunda señal
subplot(3,1,2);
stem(n, x2, 'g', 'filled'); grid on;
title(['Señal 2 (f_2 = ', num2str(f2), ' Hz)']);
ylabel('Amplitud');

% Gráfica de la señal resultante
subplot(3,1,3);
stem(n, x_sum, 'b', 'filled', 'LineWidth', 1.5); grid on;
title('Señal Resultante (x_1 + x_2)');
xlabel('Número de muestra (n)');
ylabel('Amplitud');