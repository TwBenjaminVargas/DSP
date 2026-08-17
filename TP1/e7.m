
fs = 10000;           % frecuencia de muestreo 
t = 0:1/fs:1;         % vector de tiempo: 1 seg
f0 = 1000;            % frecuencia de la señal

% Señales
senal = sin(2*pi*f0*t);           % señal sinusoidal 
ruido = 0.5 * randn(size(t));
senal_ruidosa = senal + ruido;

% FFT de ambas señales
N = length(t);
f = (0:N-1) * (fs/N);  

fft_pura = abs(fft(senal)) / N;
fft_ruidosa = abs(fft(senal_ruidosa)) / N;

% Gráfica de señales en el tiempo 
figure;
subplot(2,1,1);
plot(t(1:200), senal(1:200));
title('Señal sinusoidal pura');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

subplot(2,1,2);
plot(t(1:200), senal_ruidosa(1:200));
title('Señal sinusoidal con ruido');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

% Gráfica de espectros FFT 
figure;
subplot(2,1,1);
plot(f(1:N/2), fft_pura(1:N/2));
title('Espectro FFT - señal pura');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
grid on;

subplot(2,1,2);
plot(f(1:N/2), fft_ruidosa(1:N/2));
title('Espectro FFT - señal con ruido');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
grid on;
