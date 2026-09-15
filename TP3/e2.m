clc; clear; close all;

datos  = load('archivo2.txt');
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
title('Senal original vs senal con ganancia (GAIN=2)');
legend('Entrada x(n)', 'Salida y(n) = 2·x(n)');
grid on;
xlim([0, 0.01]);