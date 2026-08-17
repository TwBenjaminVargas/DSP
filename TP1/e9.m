
fs = 10000;           % frecuencia de muestreo
N = 1000;  
t = (0:N-1) / fs;
f0 = 1000;            % frecuencia de la señal

% Señal sinusoidal
senal = sin(2*pi*f0*t);

% FFT
fft_senal = abs(fft(senal)) / N;
f = (0:N-1) * (fs/N);   % eje de frecuencias

% Gráfica del espectro
figure;
plot(f(1:N/2), fft_senal(1:N/2));
title('Espectro de amplitud - sinusoidal 1 kHz');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
grid on;
