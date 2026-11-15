pkg load signal

% Especificaciones del filtro pasaaltos IIR
fs = 8000;          % Frecuencia de muestreo (Hz)
fmax = fs / 2;      % Frecuencia de Nyquist (4000 Hz)
fc = 1100;          % Frecuencia de corte inferior de banda de paso (Hz)
order = 4;          % Orden del filtro (subir a 6 si necesitás transición más abrupta)
rp = 1;             % Rizado máximo en banda de paso (dB)
rs = 40;            % Atenuación mínima en banda de rechazo (dB)

% Diseño del filtro IIR pasaaltos (Chebyshev Tipo II: plano en banda de paso 1100-4000 Hz y -40 dB en rechazo)
[z, p, g] = cheby2(order, rs, fc / fmax, 'high');
sos = zp2sos(z, p, g);

% Exportar coeficientes al archivo filter_hp.h
fid = fopen('filter_hp.h', 'w');
fprintf(fid, '#define NUM_SECTIONS %d\n\n', rows(sos));

fprintf(fid, 'const float b[NUM_SECTIONS][3] = {\n');
for i = 1:rows(sos)
    fprintf(fid, '    {%.12ef, %.12ef, %.12ef},\n', sos(i,1), sos(i,2), sos(i,3));
end
fprintf(fid, '};\n\n');

fprintf(fid, 'const float a[NUM_SECTIONS][2] = {\n');
for i = 1:rows(sos)
    fprintf(fid, '    {%.12ef, %.12ef},\n', sos(i,5), sos(i,6));
end
fprintf(fid, '};\n');
fclose(fid);

printf('Archivo filter_hp.h generado correctamente.\n');