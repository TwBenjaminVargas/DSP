#include <stdio.h>
#include <math.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"

static const char *TAG = "DSP_SIMULATION";

#define SINE_SAMPLES    64      // Número de muestras por período
#define GAIN_FACTOR     1.8f    // Factor de ganancia a simular (Punto 2)

void app_main(void)
{
    ESP_LOGI(TAG, "Iniciando simulacion de senal de entrada y salida procesada...");

    // Tabla Look-Up Table (LUT) para generar una senoidal de 8 bits (0 a 255)
    uint8_t sine_lut[SINE_SAMPLES];
    for (int i = 0; i < SINE_SAMPLES; i++) {
        sine_lut[i] = (uint8_t)(127.5f * (1.0f + sinf(2.0f * M_PI * i / SINE_SAMPLES)));
    }

    uint16_t index = 0;

    while (1) {
        // 1. Simulación de la señal de entrada (p. ej. viniendo del ADC / Arduino)
        uint8_t sample_in = sine_lut[index];

        // 2. Procesamiento DSP: Aplicar Ganancia con saturación a 8 bits
        int temp_out = (int)(sample_in * GAIN_FACTOR);
        uint8_t sample_out = (temp_out > 255) ? 255 : temp_out;

        // 3. Enviar trama formateada al puerto serie para el osciloscopio en Python
        printf("Entrada:%d,Salida:%d\n", sample_in, sample_out);

        // Avanza al siguiente punto de la onda
        index = (index + 1) % SINE_SAMPLES;

        // Frecuencia de muestreo (~100 muestras/segundo)
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}