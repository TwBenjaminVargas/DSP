pkg load signal

% Especificaciones del filtro
fs = 8000;          % Frecuencia de muestreo (Hz)
fmax = fs / 2;      % Frecuencia de Nyquist (4000 Hz)
fc = 200;           % Frecuencia de corte (Hz)
order = 4;          % Orden del filtro (puedes subirlo a 6 si necesitas caída más abrupta)
rp = 1;             % Rizado máximo en banda de paso (dB)
rs = 40;            % Atenuación mínima en banda de rechazo (dB)

% Diseño del filtro IIR pasabajos (Chebyshev Tipo II: plano en banda de paso y cumple exacto -40 dB en rechazo)
[z, p, g] = cheby2(order, rs, fc / fmax, 'low');
sos = zp2sos(z, p, g);

% Exportar coeficientes al archivo filter1.h
fid = fopen('filter1.h', 'w');
fprintf(fid, '#define NUM_SECTIONS %d\n\n', rows(sos));

fprintf(fid, 'float b[NUM_SECTIONS][3] = {\n');
for i = 1:rows(sos)
    fprintf(fid, '    {%.12e, %.12e, %.12e},\n', sos(i,1), sos(i,2), sos(i,3));
end
fprintf(fid, '};\n\n');

fprintf(fid, 'float a[NUM_SECTIONS][2] = {\n');
for i = 1:rows(sos)
    fprintf(fid, '    {%.12e, %.12e},\n', sos(i,5), sos(i,6));
end
fprintf(fid, '};\n');
fclose(fid);

printf('Archivo filter1.h generado correctamente.\n');