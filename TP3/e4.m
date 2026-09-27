clc; clear; close all;

% Leer archivo generado por C
datos  = load('archivo4.txt');
t      = datos(:, 1);
input  = datos(:, 2);
output = datos(:, 3);

% Graficar
figure;
plot(t, input,  'b',   'LineWidth', 1.5);
hold on;
plot(t, output, 'r--', 'LineWidth', 1.2);
hold off;
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Desplazamiento de nivel (LEVEL = 0.5)');
legend('Entrada x(n)', 'Salida y(n) = x(n) + LEVEL');
grid on;
xlim([0, 0.01]);
pause;
