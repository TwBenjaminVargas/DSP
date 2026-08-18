clc; clear;

% --- 1. Generación de la señal (Punto anterior) ---
A  = 5; f1 = 10; f2 = 25; fs = 200; N = 50;
n  = 0:N-1;
t  = n / fs;
x  = A*sin(2*pi*f1*t) + A*sin(2*pi*f2*t); % Señal compuesta

% --- 2. Creación del archivo de cabecera (.h) ---
nombre_archivo = 'senal_muestras.h';
fileID = fopen(nombre_archivo, 'w'); % Abre/crea el archivo para escritura

% --- 3. Escritura de directivas de preprocesador e inclusión ---
fprintf(fileID, '#ifndef SENAL_MUESTRAS_H\n');
fprintf(fileID, '#define SENAL_MUESTRAS_H\n\n');
fprintf(fileID, '#define LONGITUD_SENAL %d\n\n', N);

% Declaración del arreglo en C
fprintf(fileID, 'const float senal_muestras[%d] = {\n', N);

% --- 4. Escritura de las muestras formateadas ---
for i = 1:N
    if i == N
        fprintf(fileID, '    %.4ff\n', x(i));   % Última muestra (sin coma)
    else
        fprintf(fileID, '    %.4ff,\n', x(i));  % Muestras intermedias (con coma)
    end
end

% Cierre del arreglo y del guardia de inclusión
fprintf(fileID, '};\n\n');
fprintf(fileID, '#endif // SENAL_MUESTRAS_H\n');

fclose(fileID); % Cierra y guarda el archivo

disp(['Archivo "', nombre_archivo, '" generado exitosamente.']);