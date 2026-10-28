pkg load signal

% caso: 'ruido' o 'senos'
caso = 'ruido';

fs = 8000;
fmax = fs/2;
N = 4000;

% ----- Diseño del filtro pasabanda IIR (elíptico) -----
rp = 1;                    
rs = 40;                   
Wp = [200 300]/fmax;       
Ws = [150 350]/fmax; 

[n, Wn] = ellipord(Wp, Ws, rp, rs);
printf('Orden del prototipo n: %d ', n);

[b, a] = ellip(n, rp, rs, Wn);     
figure; freqz(b, a, 4096, fs);

% ----- Verificación numérica -----
[h, f] = freqz(b, a, 4096, fs);
H = 20*log10(abs(h));
printf('\nAtenuacion maxima en rechazo (<=150 Hz y >=350 Hz): %.1f dB\n', max(H(f <= 150 | f >= 350)));
printf('Ganancia minima en banda de paso (200-300 Hz): %.1f dB\n', min(H(f >= 200 & f <= 300)));

% ----- Genera filter.h -----
[z, p, g] = ellip(n, rp, rs, Wn);
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

% ----- Señal de entrada -----
if strcmp(caso, 'ruido')
  x = round(1000*(1 - 2*rand(1, N)));
else
  freq_range = [100 250 400 1000 2000];
  n_t = 0:N-1;                         % no usar 'n': ya es el orden del filtro
  x = zeros(1, N);
  for k = 1:length(freq_range)
    x = x + round(100*sin(2*pi*n_t*freq_range(k)/fs));
  end
end
figure; plot(x); title('Señal de entrada');

% ----- Genera signal.h -----
fid = fopen('signal.h', 'w');
fprintf(fid, '#define LINE_ELEMENTS %d\n\n', length(x));
fprintf(fid, 'short signal[LINE_ELEMENTS]={');
fprintf(fid, '%d, ', x(1:end-1));
fprintf(fid, '%d};\n', x(end));
fclose(fid);

save('entrada.mat', 'x');