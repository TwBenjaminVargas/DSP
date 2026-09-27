clc; clear; close all;

% Leer archivo generado por C
datos  = load('archivo6.txt');
t      = datos(:, 1);
input  = datos(:, 2);
output = datos(:, 3);

% Graficar
figure;
plot(t, input,  'b',   'LineWidth', 1.0);
hold on;
plot(t, output, 'r--', 'LineWidth', 0.8);
hold off;
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Senal aleatoria generada en C (Fs=8000Hz)');
legend('Entrada x(n)', 'Salida y(n)');
grid on;
xlim([0, 0.01]);
pause;
