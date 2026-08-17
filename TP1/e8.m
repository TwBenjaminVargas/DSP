pkg load signal  

fs = 10000;           % frecuencia de muestreo 
t = 0:1/fs:1;         % vector de tiempo: 1 segundo
f0 = 100;             % frecuencia fundamental

% Generación de señales
cuadrada = square(2*pi*f0*t);
triangular = sawtooth(2*pi*f0*t, 0.5);

% Gráfica comparativa 
figure;
subplot(2,1,1);
plot(t(1:500), cuadrada(1:500));
title('Señal cuadrada');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

subplot(2,1,2);
plot(t(1:500), triangular(1:500));
title('Señal triangular');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;
