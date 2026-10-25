pkg load signal

% caso: 'ruido' o 'senos'
caso = 'senos';

fs = 8000;
fmax = fs/2;
N = 4000;

% Diseño del filtro pasaaltos IIR (elíptico) 
rp = 1;       % rizado en banda de paso (dB)
rs = 40;      % atenuación en banda de rechazo (dB)
fp = 1100;    % borde de la banda de paso (Hz)
fr = 900;     % borde de la banda de rechazo (Hz)
[order, Wn] = ellipord(fp/fmax, fr/fmax, rp, rs);
printf('Orden del filtro: %d\n', order);
[b, a] = ellip(order, rp, rs, Wn, 'high');
figure; freqz(b, a, 4096, fs);

% Verificación numérica
[h, f] = freqz(b, a, 4096, fs);
H = 20*log10(abs(h));
printf('Atenuación máxima hasta 900 Hz: %.1f dB\n', max(H(f <= fr)));

% Genera filter.h
[z, p, g] = ellip(order, rp, rs, Wn, 'high');
sos = zp2sos(z, p, g);
fid = fopen('filter.h', 'w');
fprintf(fid, '#define NUM_SECTIONS %d\n\n', rows(sos));
fprintf(fid, 'float b[NUM_SECTIONS][3]={\n');
for i = 1:rows(sos)
  fprintf(fid, '{%.12e, %.12e, %.12e},\n', sos(i,1), sos(i,2), sos(i,3));
end
fprintf(fid, '};\n');
fprintf(fid, 'float a[NUM_SECTIONS][2]={\n');
for i = 1:rows(sos)
  fprintf(fid, '{%.12e, %.12e},\n', sos(i,5), sos(i,6));
end
fprintf(fid, '};\n');
fclose(fid);

% Señal de entrada 
if strcmp(caso, 'ruido')
  x = round(1000*(1 - 2*rand(1, N)));
else
  freq_range = [200 600 1500 2500 3500];
  n = 0:N-1;
  x = zeros(1, N);
  for k = 1:length(freq_range)
    x = x + round(100*sin(2*pi*n*freq_range(k)/fs));
  end
end
figure; plot(x); title('Señal de entrada');

% Genera signal.h 
fid = fopen('signal.h', 'w');
fprintf(fid, '#define LINE_ELEMENTS %d\n\n', length(x));
fprintf(fid, 'short signal[LINE_ELEMENTS]={');
fprintf(fid, '%d, ', x(1:end-1));
fprintf(fid, '%d};\n', x(end));
fclose(fid);

save('entrada.mat', 'x');