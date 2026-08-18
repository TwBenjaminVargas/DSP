clc; clear; close all;

% --- Parámetros ---
A  = 5;       % Amplitud
f1 = 10;      % Frecuencia de la primera señal (Hz)
f2 = 25;      % Frecuencia de la segunda señal (Hz)
fs = 200;     % Frecuencia de muestreo (Hz)
N  = 50;      % Cantidad de muestras

% --- Generación de señales (Puntos 2 y 3) ---
n = 0:N-1;
t = n / fs;

x_p2 = A * sin(2*pi*f1*t);            % Señal del Punto 2 (única frecuencia)
x_p3 = x_p2 + A * sin(2*pi*f2*t);     % Señal del Punto 3 (suma de frecuencias)

% --- Cálculo de los Espectros de Frecuencia (FFT) ---
f = (0:N-1) * (fs / N);               % Vector de frecuencias (Hz)

X_p2 = abs(fft(x_p2)) / N;           % Magnitud normalizada del Punto 2
X_p3 = abs(fft(x_p3)) / N;           % Magnitud normalizada del Punto 3

% --- Gráficas de los Espectros ---
figure;

% Espectro de la señal del Punto 2
subplot(2,1,1);
stem(f, X_p2, 'r', 'filled', 'LineWidth', 1.5); grid on;
title('Espectro de Frecuencia - Punto 2 (f_1 = 10 Hz)');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');

% Espectro de la señal del Punto 3
subplot(2,1,2);
stem(f, X_p3, 'b', 'filled', 'LineWidth', 1.5); grid on;
title('Espectro de Frecuencia - Punto 3 (Suma: 10 Hz + 25 Hz)');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');