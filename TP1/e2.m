clc; clear; close all;

% --- Parámetros ---
A  = 5;      % Amplitud de la señal
f0 = 10;     % Frecuencia de la señal (Hz)
fs = 200;    % Frecuencia de muestreo (Hz)
N  = 50;     % Cantidad de muestras del registro

% --- Generación de la señal discreta ---
n = 0:N-1;              % Índice de cada muestra (0, 1, 2, ..., N-1)
t = n / fs;             % Vector de tiempo discreto (en segundos)
x = A * sin(2*pi*f0*t); % Señal sinusoidal evaluada en cada muestra

% --- Gráfica de la señal digital ---
figure;
stem(n, x, 'filled', 'LineWidth', 1.5); % grafica una linea para cada valor de x en cada valor de n
grid on;

title(['Señal Sinusoidal Digital (f_0 = ', num2str(f0), ' Hz, f_s = ', num2str(fs), ' Hz)']);
xlabel('Número de muestra (n)');
ylabel('Amplitud');