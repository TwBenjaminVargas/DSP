clc; clear; close all;

% Leer archivo generado por C
datos  = load('archivo1.txt');
t      = datos(:, 1);
input  = datos(:, 2);
output = datos(:, 3);

% Graficar
figure;
plot(t, input, 'b', 'LineWidth', 1.5);
hold on;
plot(t, output, 'r--', 'LineWidth', 1.2);
hold off;
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Senal sinusoidal leida desde C (f=440Hz, Fs=8000Hz)');
legend('Entrada x(n)', 'Salida y(n)');
grid on;
xlim([0, 0.01]);   % muestra los primeros 10ms para ver bien los ciclos
