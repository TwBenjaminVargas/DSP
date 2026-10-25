pkg load signal

% caso = 'ruido' o 'senos'
caso = 'senos';

fs = 8000;
fmax = fs/2;
N = 4000;

% ----- Diseño del filtro rechaza banda 300 a 500 Hz -----
order = 300;
b = fir1(order, [250 550]/fmax, 'stop', hamming(order+1));
figure; freqz(b, 1, 4096, fs);

% Verificación numérica
[h, f] = freqz(b, 1, 4096, fs);
H = 20*log10(abs(h));
printf('Atenuación máxima en 300-500 Hz: %.1f dB\n', max(H(f>=300 & f<=500)));

% ----- Genera filter.h -----
fid = fopen('filter.h','w');
fprintf(fid, '#define N_FIR %d\n\n', length(b));
fprintf(fid, 'float h[N_FIR]={');
fprintf(fid, '%.10e, ', b(1:end-1));
fprintf(fid, '%.10e};\n', b(end));
fclose(fid);

% ----- Señal de entrada -----
if strcmp(caso, 'ruido')
  x = round(1000*(1 - 2*rand(1, N)));
else
  freq_range = [100 400 700 1500 2500];
  n = 0:N-1;
  x = zeros(1, N);
  for k = 1:length(freq_range)
    x = x + round(100*sin(2*pi*n*freq_range(k)/fs));
  end
end
figure; plot(x); title('Señal de entrada');

% ----- Genera signal.h -----
fid = fopen('signal.h','w');
fprintf(fid, '#define LINE_ELEMENTS %d\n\n', length(x));
fprintf(fid, 'short signal[LINE_ELEMENTS]={');
fprintf(fid, '%d, ', x(1:end-1));
fprintf(fid, '%d};\n', x(end));
fclose(fid);

save('entrada.mat', 'x');