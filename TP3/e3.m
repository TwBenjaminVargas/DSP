clc; clear; close all;

datos  = load('archivo3.txt');
t      = datos(:, 1);
input  = datos(:, 2);
output = datos(:, 3);

figure;
plot(t, input, 'b', 'LineWidth', 1.5);
hold on;
plot(t, output, 'r', 'LineWidth', 1.5);
hold off;
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Senal original vs senal retardada (DELAY=50 muestras)');
legend('Entrada x(n)', 'Salida y(n) = x(n-100)');
grid on;
xlim([0.01, 0.015]);