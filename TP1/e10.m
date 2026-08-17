fs = 10000;
f0 = 1000;
muestras = [50, 100, 500, 1000];

figure;
for i = 1:4
  N = muestras(i);
  t = (0:N-1) / fs;
  senal = sin(2*pi*f0*t);
  
  fft_senal = abs(fft(senal)) / N;
  f = (0:N-1) * (fs/N);
  
  subplot(4,1,i);
  plot(f(1:N/2), fft_senal(1:N/2));
  title(['N = ', num2str(N), ' muestras']);
  xlabel('Frecuencia (Hz)');
  ylabel('Amplitud');
  grid on;
end
