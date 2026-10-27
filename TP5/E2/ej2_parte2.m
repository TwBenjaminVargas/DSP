pkg load signal
clear; close all; clc;

fs = 8000;
N = 4000;

% ----- Suma de 19 senoidales de amplitud 100 -----
freq_range = [10,20,40,80,100,200,400,800,1000,1200,1400,1800,2000,2100,2200,2400,2800,3000,3400];
n = 0:N-1;
x = zeros(1, N);
for k = 1:length(freq_range)
  x = x + round(100*sin(2*pi*n*freq_range(k)/fs));
end
figure; plot(x(1:400)); title('Entrada: suma de senoidales (tiempo)'); xlabel('Muestra');

% ----- Genera signal.h -----
fid = fopen('signal.h','w');
fprintf(fid, '#define LINE_ELEMENTS %d\n\n', length(x));
fprintf(fid, 'short signal[LINE_ELEMENTS]={');
fprintf(fid, '%d, ', x(1:end-1));
fprintf(fid, '%d};\n', x(end));
fclose(fid);

% ----- Compilar y ejecutar el filtro en C -----
system('gcc main_fir.c -o main_fir');
system('main_fir');
movefile('fir_out.txt', 'fir_out_senos.txt');

% ----- Leer la salida y graficar -----
[a, y] = textread('fir_out_senos.txt', '%f %f', 'headerlines', 1);
figure; plot(y(1:400)); title('Salida filtrada: senoidales (tiempo)'); xlabel('Muestra');

fft_f(x, fs, 'Entrada senoidales');
fft_f(y, fs, 'Salida senoidales');



