%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  coeficientes del filtro FIR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pkg load signal

% filtro pasabajos
type = 'low';
fs = 8000;
fc = 200;
order = 30;
fmax = fs/2;
b = fir1(order, fc/fmax, type);
freqz (b);

% genera archivo de cabecera con los coeficientes del filtro
array = b;
min_index = 1;
max_index = length(array);
file_name = 'filter.h';
const_name = 'N_FIR';
array_name = ['float h[' const_name ']={'];
fid=fopen(file_name,'w');
fprintf(fid,'#define ');
fprintf(fid, const_name);
fprintf(fid, ' %d\n\n', max_index);
fprintf(fid, array_name);
fprintf(fid,'%d, ' , array(min_index:(max_index-1)));
fprintf(fid,'%d' , array(max_index));
fprintf(fid,'};\n');
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  coeficientes del filtro IIR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pkg load signal
% aumenta la cantidad de decimales: 16 es el maximo.
output_precision(16)

% filtro pasabajos eliptico
type = 'low';
fs = 8000;
fc = 200;
order = 6;
ripple_band_pass = 1;
attenuation = 40;
fmax = fs/2;
[z, p, g] = ellip(order, ripple_band_pass, attenuation, fc/fmax, type);
sec_ord_sec = zp2sos(z, p, g);
[b, a] = ellip(order, ripple_band_pass, attenuation, fc/fmax, type);
freqz (b, a);

% genera archivo de cabecera con los coeficientes del filtro
array = sec_ord_sec;
min_index = 1;
stages = rows(array);
file_name = 'filter.h';
const_name = 'NUM_SECTIONS';
array_name = ['float b[' const_name '][3]={'];
array_name_a = ['float a[' const_name '][2]={'];
% crea el archivo de cabecera
fid=fopen(file_name,'w');
fprintf(fid,'#define ');
fprintf(fid, const_name);
fprintf(fid, ' %d\n\n', stages);
%arrego a
fprintf(fid, array_name);
fprintf(fid,'\n');
for i=1:stages
  fprintf(fid,'{');
  fprintf(fid,'%.20f, ' , array(i,min_index:2));
  fprintf(fid,'%.20f' , array(i,3));
  fprintf(fid,'},\n');
end
fprintf(fid,'};\n');
%arrego b
fprintf(fid, array_name_a);
fprintf(fid,'\n');
for i=1:stages
  fprintf(fid,'{');
  fprintf(fid,'%.20f, ' , array(i,5));
  fprintf(fid,'%.20f' , array(i,6));
  fprintf(fid,'},\n');
end
fprintf(fid,'};\n');
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  señal de entrada
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generar una se#al sinusoidal
signal_freq=1000;
signal_amp=100;
fs=8000;
sample_number = 4000;
for i=1:sample_number
 signal(i) = round(signal_amp*sin(2*pi*(i-1)*signal_freq/fs));
end
plot(signal);
plot(signal, 'o-b');

% genera una se#al compuesta por sinusoides de diferentes frecuencias
% freq_range contiene las frecuencias en Hz
freq_range=[10,20,40,80,100,200,400,800,1000,1200,1400,1800,2000,2100,2200,2400,2800,3000,3400];
fs=8000;
signal_amp=100;
sample_number = 4000;
n_freq_range=length(freq_range);
for j=1:n_freq_range
  signal_freq=freq_range(j);
  for i=1:sample_number
    signal(i,j) = round(signal_amp*sin(2*pi*(i-1)*signal_freq/fs));
  end
end
comp_signal = signal(1:sample_number, 1);
for i=2:n_freq_range
  comp_signal = comp_signal + signal(1:sample_number, i);
end
plot(comp_signal);

% genera una señal aleatoria
sample_number = 4000;
noise_amp = 1000;
random_signal = round(noise_amp*(1 - 2*rand(1, sample_number)));
plot(random_signal, 'o-b');

% generar el archivo de cabecera de la señal de entrada
array = signal;
min_index = 1;
max_index = length(array);
file_name = 'signal.h';
const_name = 'LINE_ELEMENTS';
array_name = ['short signal[' const_name ']={'];
% crea el archivo de cabecera
fid=fopen(file_name,'w');
fprintf(fid,'#define ');
fprintf(fid, const_name);
fprintf(fid, ' %d\n\n', max_index);
fprintf(fid, array_name);
fprintf(fid,'%d, ' , array(min_index:(max_index-1)));
fprintf(fid,'%d' , array(max_index));
fprintf(fid,'};\n');
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Carga de archivo de salida
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_name = 'fir_out.txt';
[a, fir_out] = textread (file_name, "%f %f", "headerlines", 1);
plot(fir_out);

fft_f (fir_out, 8000)

file_name = 'iir_out.txt';
[a, iir_out] = textread (file_name, "%f %f", "headerlines", 1);
plot(iir_out);

fft_f (iir_out, 8000)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fft_f (comp_signal, fs)
  output_precision(16)
  X = comp_signal;
  L = length(X); % longitud de la se#al
  T = 1/fs; % periodo de muestreo
  t = (0:L-1)*T; % vector de tiempo
  Y = fft(X); % calcula la FFT.
  P2 = abs(Y/L);
  P1 = P2(1:L/2+1);
  P1(2:end-1) = 2*P1(2:end-1);
  f = fs*(0:(L/2))/L; % vector de frecuencias.
  figure;
  plot(f,P1) % grafica la se#al en el dominio de la frecuencia.
  title('Amplitud en el dominio de la frecuencia')
  xlabel('f (Hz)')
  ylabel('|P1(f)|')
  xticks(0:200:fs/2)
  grid on
  figure;
  for i=1:length(P1)
    if(P1(i) < 0.0000001)
      P1(i) = 0.000001;
    endif
  end
  plot(f, 20*log10(P1)) % grafica con salida en dBs.
  title('Amplitud en el dominio de la frecuencia')
  xlabel('f (Hz)')
  ylabel('|P1(f)|')
  xticks(0:200:fs/2)
  grid on
endfunction

fft_f (comp_signal, 8000)
