1;
pkg load signal

function fft_f (sig, fs)
  L = length(sig);
  Y = fft(sig);
  P2 = abs(Y/L);
  P1 = P2(1:floor(L/2)+1);
  P1(2:end-1) = 2*P1(2:end-1);
  f = fs*(0:floor(L/2))/L;
  figure; plot(f, P1);
  title('Amplitud en frecuencia'); xlabel('f (Hz)'); ylabel('|P1(f)|'); grid on
  P1(P1 < 1e-7) = 1e-6;
  figure; plot(f, 20*log10(P1));
  title('Amplitud en frecuencia (dB)'); xlabel('f (Hz)'); ylabel('dB'); grid on
end

archivo = 'iir_out_pasaaltos_senos.txt';

load('entrada.mat');
[t, y] = textread(archivo, '%f %f', 'headerlines', 1);

figure; plot(x); title('Entrada (tiempo)');
figure; plot(y); title('Salida (tiempo)');
fft_f(x, 8000);   % entrada en frecuencia
fft_f(y, 8000);   % salida en frecuencia
