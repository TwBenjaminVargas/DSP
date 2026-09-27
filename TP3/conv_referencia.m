% conv_referencia.m
clc; clear; close all;

Fs = 8000;
N  = 2000;
n  = 0:N-1;

% Señal x: sinusoidal 440 Hz
x = sin(2*pi*440*n/Fs);

% Señal h: filtro media movil de 5 coeficientes
h = ones(1,5) / 5;

% Convolución en Octave
y = conv(x, h);

% Graficar
t_x = n / Fs;
t_y = (0:length(y)-1) / Fs;

figure;
plot(t_x, x, 'b', 'LineWidth', 1.5);
hold on;
plot(t_y, y, 'r--', 'LineWidth', 1.2);
hold off;
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Convolucion en Octave (referencia)');
legend('Entrada x(n)', 'Salida y(n) = x * h');
grid on;
xlim([0, 0.01]);
pause;