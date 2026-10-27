function fft_f(x, fs, nombre)
  L = length(x);
  Y = fft(x);
  P2 = abs(Y/L);
  P1 = P2(1:L/2+1);
  P1(2:end-1) = 2*P1(2:end-1);
  f = fs*(0:(L/2))/L;
  P1(P1 < 1e-6) = 1e-6;
  figure; plot(f, P1); grid on
  title(['Espectro (lineal) - ' nombre]); xlabel('f (Hz)'); ylabel('Amplitud')
  figure; plot(f, 20*log10(P1)); grid on
  title(['Espectro (dB) - ' nombre]); xlabel('f (Hz)'); ylabel('Amplitud (dB)')
end