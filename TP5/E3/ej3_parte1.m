pkg load signal

% caso: 'ruido' o 'senos'
caso = 'senos';

fs = 8000;
fmax = fs/2;
N = 4000;

% ----- Diseño del filtro pasabanda 200 a 300 Hz -----
order = 260;
b = fir1(order, [200 300]/fmax, 'pass', hamming(order+1));
figure; freqz(b, 1, 4096, fs);

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
  freq_range = [100 250 400 1000 2000];
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

save('entrada.mat', 'x');   % para graficar la entrada después
