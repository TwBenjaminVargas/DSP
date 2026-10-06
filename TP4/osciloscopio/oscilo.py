import sys
import serial
import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtWidgets

# Configuración del puerto serie en Linux
SERIAL_PORT = '/dev/ttyUSB1'  # Reemplazar por '/dev/ttyACM0' si corresponde
BAUD_RATE = 115200
BUFFER_SIZE = 200             # Cantidad de muestras visibles en pantalla

# Inicializar conexión con la ESP32
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    print(f"Conectado exitosamente al puerto {SERIAL_PORT}")
except Exception as e:
    print(f"Error al abrir el puerto {SERIAL_PORT}: {e}")
    print("Verifica el puerto o dale permisos ejecutando: sudo chmod 666 /dev/ttyUSB0")
    sys.exit(1)

# Buffers circulares para almacenar las ondas
data_in = [0] * BUFFER_SIZE
data_out = [0] * BUFFER_SIZE

# Configuración de la ventana gráfica con PyQtGraph
app = QtWidgets.QApplication(sys.argv)
win = pg.GraphicsLayoutWidget(show=True, title="Osciloscopio Virtual DSP - ESP32")
win.resize(900, 500)

plot = win.addPlot(title="Simulación DSP: Entrada (Original) vs Salida (Procesada)")
plot.setYRange(0, 260)
plot.setLabel('left', 'Amplitud (8-bits / Voltaje)', units='LSB')
plot.setLabel('bottom', 'Tiempo (Muestras)')
plot.showGrid(x=True, y=True)
plot.addLegend()

# Trazados de las señales
curve_in = plot.plot(pen=pg.mkPen('c', width=2), name="Entrada (Original)")      # Color Cian
curve_out = plot.plot(pen=pg.mkPen('m', width=2), name="Salida") # Color Magenta

def update():
    global data_in, data_out
    while ser.in_waiting:
        try:
            line = ser.readline().decode('utf-8', errors='ignore').strip()
            # Parsear trama de datos: "Entrada:VAL1,Salida:VAL2"
            if "Entrada:" in line and "Salida:" in line:
                parts = line.split(',')
                val_in = int(parts[0].split(':')[1])
                val_out = int(parts[1].split(':')[1])

                # Actualizar buffers
                data_in.append(val_in)
                data_in.pop(0)
                data_out.append(val_out)
                data_out.pop(0)
        except (ValueError, IndexError):
            continue

    # Redibujar las curvas en pantalla
    curve_in.setData(data_in)
    curve_out.setData(data_out)

# Configurar temporizador para refresco continuo a ~60 FPS
timer = QtCore.QTimer()
timer.timeout.connect(update)
timer.start(16)

if __name__ == '__main__':
    sys.exit(app.exec_())