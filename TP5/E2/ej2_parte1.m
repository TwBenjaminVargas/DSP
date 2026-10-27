pkg load signal
clear; close all; clc;

fs = 8000;
fmax = fs/2;
N = 4000;

% ----- Diseño del filtro pasaaltos -----
order = 66;
fc = 900;
b = fir1(order, fc/fmax, 'high');
figure; freqz(b, 1, 4096, fs);

% ----- Genera filter.h -----
fid = fopen('filter.h','w');
fprintf(fid, '#define N_FIR %d\n\n', length(b));
fprintf(fid, 'float h[N_FIR]={');
fprintf(fid, '%.10e, ', b(1:end-1));
fprintf(fid, '%.10e};\n', b(end));
fclose(fid);

% ----- Ruido aleatorio -----
rand('state', 1);   % misma semilla que en E1: mismo ruido
x = round(1000*(1 - 2*rand(1, N)));
figure; plot(x(1:200)); title('Entrada: ruido (tiempo)'); xlabel('Muestra');

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
movefile('fir_out.txt', 'fir_out_ruido.txt');

% ----- Leer la salida y graficar -----
[a, y] = textread('fir_out_ruido.txt', '%f %f', 'headerlines', 1);
figure; plot(y(1:200)); title('Salida filtrada: ruido (tiempo)'); xlabel('Muestra');

fft_f(x, fs, 'Entrada ruido');
fft_f(y, fs, 'Salida ruido');