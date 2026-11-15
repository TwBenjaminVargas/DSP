pkg load signal

% Especificaciones del filtro rechaza-banda (notch / bandstop) IIR
fs = 8000;              % Frecuencia de muestreo (Hz)
fmax = fs / 2;          % Frecuencia de Nyquist (4000 Hz)
ws = [300 500] / fmax;  % Banda de rechazo normalizada (300 a 500 Hz)
order = 3;              % Orden del prototipo (genera 2*order = 6 polos -> 3 secciones SOS)
rp = 1;                 % Rizado máximo en banda de paso (dB)
rs = 40;                % Atenuación mínima en banda de rechazo (dB)

% Diseño del filtro IIR rechaza-banda (Chebyshev Tipo II: plano en bandas de paso y -40 dB en 300-500 Hz)
[z, p, g] = cheby2(order, rs, ws, 'stop');
sos = zp2sos(z, p, g);

% Exportar coeficientes al archivo filter_bs.h
fid = fopen('filter_bs.h', 'w');
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

printf('Archivo filter_bs.h generado correctamente.\n');