% Parámetros de la señal
fs = 1000;          % frecuencia de muestreo (Hz)
t = 0:1/fs:1;       % vector de tiempo: 1 segundo

% Generación de ruido aleatorio (distribución normal)
ruido = randn(size(t));

% Gráfica
figure;
plot(t, ruido);
title('Señal de ruido aleatorio');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

