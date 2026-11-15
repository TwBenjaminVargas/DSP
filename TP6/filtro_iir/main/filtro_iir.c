#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_adc/adc_oneshot.h"
#include "driver/dac_oneshot.h"
#include "driver/uart.h"
#include "esp_timer.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

// ============================================================================
// PARÁMETROS DE HARDWARE Y MUESTREO
// ============================================================================
#define FS                  8000            // Frecuencia de muestreo: 8000 Hz
#define SAMPLE_PERIOD_US    (1000000 / FS)  // Período de muestreo: 125 us
#define UART_BAUD_RATE      921600

#define ADC_UNIT            ADC_UNIT_1
#define ADC_CHANNEL         ADC_CHANNEL_6   // GPIO 34: Entrada analógica al filtro
#define DAC_GEN_CHANNEL     DAC_CHAN_0      // GPIO 25: Salida del generador (unir a GPIO 34)
#define DAC_OUT_CHANNEL     DAC_CHAN_1      // GPIO 26: Salida analógica filtrada

// ============================================================================
// PARÁMETROS DEL BARRIDO DE FRECUENCIA (CHIRP SINUSOIDAL)
// ============================================================================
#define FREQ_INICIAL        50.0f           // Frecuencia de inicio del barrido (Hz)
#define FREQ_FINAL          3500.0f         // Frecuencia máxima del barrido (Hz)
#define TIEMPO_BARRIDO_SEG  10.0f           // Duración de un ciclo completo de barrido (s)

// ============================================================================
// DEFINICIÓN DEL FILTRO IIR (REEMPLAZAR AQUÍ CON LO GENERADO EN filter1.h)
// ============================================================================
// Paso 1: Cambiar NUM_SECTIONS por la cantidad de etapas biquad (Orden / 2)
#define NUM_SECTIONS        3

// Paso 2: Pegar la matriz b[NUM_SECTIONS][3] generada por Octave

const float b[NUM_SECTIONS][3] = {
    {6.425904666910e-01f, -1.193582137970e+00f, 6.425904666910e-01f},
    {1.000000000000e+00f, -1.907994743624e+00f, 1.000000000000e+00f},
    {1.000000000000e+00f, -1.940890543577e+00f, 1.000000000000e+00f},
};

const float a[NUM_SECTIONS][2] = {
    {-1.433543161725e+00f, 7.150591334111e-01f},
    {-1.559590988329e+00f, 6.347958961009e-01f},
    {-1.886024837259e+00f, 9.095541989353e-01f},
};


// Memoria de estados internos w[sección][0..1] para Forma Directa II
float wn[NUM_SECTIONS][2] = {0};

// ============================================================================
// FUNCIÓN DE FILTRADO IIR (SECCIONES BIQUAD EN FORMA DIRECTA II)
// ============================================================================
/**
 * @brief Procesa una muestra de entrada aplicando el filtro IIR en cascada (SOS).
 *        Por cada sección s calcula:
 *          w[n] = x_s[n] - a1 * w[n-1] - a2 * w[n-2]
 *          y_s[n] = b0 * w[n] + b1 * w[n-1] + b2 * w[n-2]
 * @param x_n Muestra actual centrada en cero.
 * @return float Muestra filtrada y[n].
 */
float aplicar_filtro_iir(float x_n) {
    float signal = x_n;

    for (int s = 0; s < NUM_SECTIONS; s++) {
        // Nodo intermedio w[n]
        float out_wn = signal - (a[s][0] * wn[s][0]) - (a[s][1] * wn[s][1]);

        // Salida de la sección s
        signal = (b[s][0] * out_wn) + (b[s][1] * wn[s][0]) + (b[s][2] * wn[s][1]);

        // Desplazamiento de los registros de retardo
        wn[s][1] = wn[s][0];
        wn[s][0] = out_wn;
    }

    return signal;
}

// ============================================================================
// FUNCIÓN PRINCIPAL (APP_MAIN)
// ============================================================================
void app_main(void) {
    uart_set_baudrate(UART_NUM_0, UART_BAUD_RATE);

    // Configurar ADC1 (GPIO 34)
    adc_oneshot_unit_handle_t adc_handle;
    adc_oneshot_unit_init_cfg_t adc_init_cfg = { .unit_id = ADC_UNIT };
    adc_oneshot_new_unit(&adc_init_cfg, &adc_handle);

    adc_oneshot_chan_cfg_t adc_chan_cfg = {
        .bitwidth = ADC_BITWIDTH_12,
        .atten = ADC_ATTEN_DB_12,
    };
    adc_oneshot_config_channel(adc_handle, ADC_CHANNEL, &adc_chan_cfg);

    // Configurar DAC0 (GPIO 25 - Generador) y DAC1 (GPIO 26 - Salida filtrada)
    dac_oneshot_handle_t dac_gen_handle;
    dac_oneshot_config_t dac_gen_cfg = { .chan_id = DAC_GEN_CHANNEL };
    dac_oneshot_new_channel(&dac_gen_cfg, &dac_gen_handle);

    dac_oneshot_handle_t dac_out_handle;
    dac_oneshot_config_t dac_out_cfg = { .chan_id = DAC_OUT_CHANNEL };
    dac_oneshot_new_channel(&dac_out_cfg, &dac_out_handle);

    // Variables para el generador de barrido continuo de frecuencia
    const float total_muestras_barrido = (float)FS * TIEMPO_BARRIDO_SEG;
    const float delta_freq = (FREQ_FINAL - FREQ_INICIAL) / total_muestras_barrido;
    float freq_actual = FREQ_INICIAL;
    float fase = 0.0f;

    uint64_t start_time = 0;
    int raw_adc = 0;

    while (1) {
        start_time = esp_timer_get_time();

        // --------------------------------------------------------------------
        // ETAPA 1: GENERACIÓN DE SINUSOIDAL CON FRECUENCIA CRECIENTE -> GPIO 25
        // --------------------------------------------------------------------
        fase += (2.0f * M_PI * freq_actual) / (float)FS;
        if (fase >= 2.0f * M_PI) {
            fase -= 2.0f * M_PI;
        }

        freq_actual += delta_freq;
        if (freq_actual > FREQ_FINAL) {
            freq_actual = FREQ_INICIAL;
        }

        float muestra_generada = 0.85f * sinf(fase);
        uint8_t dac_gen_byte = (uint8_t)((muestra_generada + 1.0f) * 127.5f);
        dac_oneshot_output_voltage(dac_gen_handle, dac_gen_byte);

        // --------------------------------------------------------------------
        // ETAPA 2: ADQUISICIÓN POR ADC -> GPIO 34
        // --------------------------------------------------------------------
        adc_oneshot_read(adc_handle, ADC_CHANNEL, &raw_adc);
        uint8_t val_in_byte = (uint8_t)(raw_adc >> 4);
        float x_n = ((float)raw_adc / 16.0f) - 127.5f;

        // --------------------------------------------------------------------
        // ETAPA 3: PROCESAMIENTO IIR
        // --------------------------------------------------------------------
        float y_n = aplicar_filtro_iir(x_n);

        // --------------------------------------------------------------------
        // ETAPA 4: SALIDA ANALÓGICA (GPIO 26) Y MONITOR SERIE
        // --------------------------------------------------------------------
        float y_desplazada = y_n + 127.5f;
        if (y_desplazada > 255.0f) y_desplazada = 255.0f;
        if (y_desplazada < 0.0f)   y_desplazada = 0.0f;
        uint8_t val_out_byte = (uint8_t)y_desplazada;

        dac_oneshot_output_voltage(dac_out_handle, val_out_byte);

        printf("Entrada:%d,Salida:%d\n", val_in_byte, val_out_byte);

        // Esperar hasta completar los 125 us (8000 Hz)
        while ((esp_timer_get_time() - start_time) < SAMPLE_PERIOD_US) {
        }
    }
}