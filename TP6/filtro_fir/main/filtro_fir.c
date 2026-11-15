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
#define TIEMPO_BARRIDO_SEG  10.0f            // Duración de un ciclo completo de barrido (s)

// ============================================================================
// DEFINICIÓN DEL FILTRO FIR (REEMPLAZAR AQUÍ PARA PROBAR OTRO FILTRO)
// ============================================================================
// Paso 1: Cambiar FIR_NUM_TAPS por la cantidad total de coeficientes (orden + 1)
#define FIR_NUM_TAPS        301

// Paso 2: Pegar dentro de las llaves los coeficientes h[0], h[1], ..., h[N-1]
const float fir_coeffs[FIR_NUM_TAPS] ={-2.7335930237e-04, -2.2852518451e-04, -1.5446887368e-04, -5.9091765970e-05, 4.6231441111e-05, 1.4829546342e-04, 2.3405610778e-04, 2.9267872982e-04, 3.1732452482e-04, 3.0637353067e-04, 2.6384846467e-04, 1.9891244653e-04, 1.2445497850e-04, 5.4935558611e-05, 3.7986456413e-06, -1.9119259345e-05, -9.7241806073e-06, 2.9092469903e-05, 8.7420227649e-05, 1.4963423985e-04, 1.9693249527e-04, 2.1075707663e-04, 1.7654570791e-04, 8.7136422932e-05, -5.4859769883e-05, -2.3628060936e-04, -4.3454641946e-04, -6.2069119002e-04, -7.6391079040e-04, -8.3691835423e-04, -8.2117087463e-04, -7.1096410112e-04, -5.1551433089e-04, -2.5845062496e-04, 2.5412600335e-05, 2.9563895134e-04, 5.1319950609e-04, 6.4773797173e-04, 6.8368906653e-04, 6.2397271620e-04, 4.9035122924e-04, 3.2011180199e-04, 1.5942761723e-04, 5.4431416700e-05, 4.1570948943e-05, 1.3908854546e-04, 3.4140166122e-04, 6.1774233381e-04, 9.1569430883e-04, 1.1693635329e-03, 1.3109927307e-03, 1.2840628594e-03, 1.0554756053e-03, 6.2439405006e-04, 2.5769754791e-05, -6.7254823605e-04, -1.3790805881e-03, -1.9930951201e-03, -2.4217580580e-03, -2.5970238748e-03, -2.4890630189e-03, -2.1134643604e-03, -1.5304475591e-03, -8.3572622019e-04, -1.4423289646e-04, 4.3063931994e-04, 7.9859294515e-04, 9.1070197089e-04, 7.7069351375e-04, 4.3662188383e-04, 1.1995952389e-05, -3.7261499494e-04, -5.8457496210e-04, -5.1639094787e-04, -1.1003645472e-04, 6.2650388939e-04, 1.6142041272e-03, 2.7112721034e-03, 3.7341091591e-03, 4.4878841149e-03, 4.8016269273e-03, 4.5615588283e-03, 3.7362999857e-03, 2.3887155850e-03, 6.7133812937e-04, -1.1948091887e-03, -2.9550677566e-03, -4.3640241524e-03, -5.2289283426e-03, -5.4456240399e-03, -5.0199022917e-03, -4.0695104831e-03, -2.8053997639e-03, -1.4946057703e-03, -4.1074249737e-04, 2.1923762867e-04, 2.6215657084e-04, -2.8969576349e-04, -1.3092368064e-03, -2.5508024705e-03, -3.6904599501e-03, -4.3843773260e-03, -4.3354422651e-03, -3.3561560474e-03, -1.4157557898e-03, 1.3383257739e-03, 4.5904341361e-03, 7.8984332649e-03, 1.0761711297e-02, 1.2704770550e-02, 1.3362183145e-02, 1.2549543256e-02, 1.0306635412e-02, 6.9032374950e-03, 2.8041774232e-03, -1.4025434922e-03, -5.1038044057e-03, -7.7694174801e-03, -9.0511669484e-03, -8.8542413265e-03, -7.3662554776e-03, -5.0357442971e-03, -2.5005715923e-03, -4.7572799633e-04, 3.8207938625e-04, -3.8972107990e-04, -2.9477430423e-03, -7.0768486553e-03, -1.2185918117e-02, -1.7371138900e-02, -2.1541547045e-02, -2.3590505307e-02, -2.2587818982e-02, -1.7961901753e-02, -9.6408992431e-03, 1.8737051229e-03, 1.5518240041e-02, 2.9767422932e-02, 4.2815032424e-02, 5.2812118581e-02, 5.8129908584e-02, 5.7608995663e-02, 5.0756614178e-02, 3.7859978853e-02, 1.9995027206e-02, -1.0751713462e-03, -2.3101818094e-02, -4.3625977614e-02, -6.0291156682e-02, -7.1149452194e-02, 9.2398919920e-01, -7.1149452194e-02, -6.0291156682e-02, -4.3625977614e-02, -2.3101818094e-02, -1.0751713462e-03, 1.9995027206e-02, 3.7859978853e-02, 5.0756614178e-02, 5.7608995663e-02, 5.8129908584e-02, 5.2812118581e-02, 4.2815032424e-02, 2.9767422932e-02, 1.5518240041e-02, 1.8737051229e-03, -9.6408992431e-03, -1.7961901753e-02, -2.2587818982e-02, -2.3590505307e-02, -2.1541547045e-02, -1.7371138900e-02, -1.2185918117e-02, -7.0768486553e-03, -2.9477430423e-03, -3.8972107990e-04, 3.8207938625e-04, -4.7572799633e-04, -2.5005715923e-03, -5.0357442971e-03, -7.3662554776e-03, -8.8542413265e-03, -9.0511669484e-03, -7.7694174801e-03, -5.1038044057e-03, -1.4025434922e-03, 2.8041774232e-03, 6.9032374950e-03, 1.0306635412e-02, 1.2549543256e-02, 1.3362183145e-02, 1.2704770550e-02, 1.0761711297e-02, 7.8984332649e-03, 4.5904341361e-03, 1.3383257739e-03, -1.4157557898e-03, -3.3561560474e-03, -4.3354422651e-03, -4.3843773260e-03, -3.6904599501e-03, -2.5508024705e-03, -1.3092368064e-03, -2.8969576349e-04, 2.6215657084e-04, 2.1923762867e-04, -4.1074249737e-04, -1.4946057703e-03, -2.8053997639e-03, -4.0695104831e-03, -5.0199022917e-03, -5.4456240399e-03, -5.2289283426e-03, -4.3640241524e-03, -2.9550677566e-03, -1.1948091887e-03, 6.7133812937e-04, 2.3887155850e-03, 3.7362999857e-03, 4.5615588283e-03, 4.8016269273e-03, 4.4878841149e-03, 3.7341091591e-03, 2.7112721034e-03, 1.6142041272e-03, 6.2650388939e-04, -1.1003645472e-04, -5.1639094787e-04, -5.8457496210e-04, -3.7261499494e-04, 1.1995952389e-05, 4.3662188383e-04, 7.7069351375e-04, 9.1070197089e-04, 7.9859294515e-04, 4.3063931994e-04, -1.4423289646e-04, -8.3572622019e-04, -1.5304475591e-03, -2.1134643604e-03, -2.4890630189e-03, -2.5970238748e-03, -2.4217580580e-03, -1.9930951201e-03, -1.3790805881e-03, -6.7254823605e-04, 2.5769754791e-05, 6.2439405006e-04, 1.0554756053e-03, 1.2840628594e-03, 1.3109927307e-03, 1.1693635329e-03, 9.1569430883e-04, 6.1774233381e-04, 3.4140166122e-04, 1.3908854546e-04, 4.1570948943e-05, 5.4431416700e-05, 1.5942761723e-04, 3.2011180199e-04, 4.9035122924e-04, 6.2397271620e-04, 6.8368906653e-04, 6.4773797173e-04, 5.1319950609e-04, 2.9563895134e-04, 2.5412600335e-05, -2.5845062496e-04, -5.1551433089e-04, -7.1096410112e-04, -8.2117087463e-04, -8.3691835423e-04, -7.6391079040e-04, -6.2069119002e-04, -4.3454641946e-04, -2.3628060936e-04, -5.4859769883e-05, 8.7136422932e-05, 1.7654570791e-04, 2.1075707663e-04, 1.9693249527e-04, 1.4963423985e-04, 8.7420227649e-05, 2.9092469903e-05, -9.7241806073e-06, -1.9119259345e-05, 3.7986456413e-06, 5.4935558611e-05, 1.2445497850e-04, 1.9891244653e-04, 2.6384846467e-04, 3.0637353067e-04, 3.1732452482e-04, 2.9267872982e-04, 2.3405610778e-04, 1.4829546342e-04, 4.6231441111e-05, -5.9091765970e-05, -1.5446887368e-04, -2.2852518451e-04, -2.7335930237e-04};


// Memoria de estados (buffer circular) e índice de escritura del filtro FIR
float fir_delay_line[FIR_NUM_TAPS] = {0.0f};
int fir_write_idx = 0;

// ============================================================================
// FUNCIÓN DE FILTRADO FIR (CONVOLUCIÓN EN BUFFER CIRCULAR)
// ============================================================================
/**
 * @brief Procesa una muestra de entrada aplicando el filtro FIR definido arriba.
 *        Calcula: y[n] = sum_{k=0}^{N-1} h[k] * x[n - k]
 * @param x_n Muestra actual centrada en cero.
 * @return float Muestra filtrada y[n].
 */
float aplicar_filtro_fir(float x_n) {
    // Guardar la muestra nueva en la posición actual del buffer circular
    fir_delay_line[fir_write_idx] = x_n;

    float acumulador = 0.0f;
    int read_idx = fir_write_idx;

    // Producto interno entre los coeficientes h[k] y las muestras retardadas x[n-k]
    for (int k = 0; k < FIR_NUM_TAPS; k++) {
        acumulador += fir_coeffs[k] * fir_delay_line[read_idx];
        read_idx = (read_idx == 0) ? (FIR_NUM_TAPS - 1) : (read_idx - 1);
    }

    // Avanzar el índice circular para la próxima muestra
    fir_write_idx = (fir_write_idx + 1) % FIR_NUM_TAPS;

    return acumulador;
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
        // Se acumula la fase instantánea para evitar saltos bruscos al variar f
        fase += (2.0f * M_PI * freq_actual) / (float)FS;
        if (fase >= 2.0f * M_PI) {
            fase -= 2.0f * M_PI;
        }

        // Incrementar frecuencia linealmente y reiniciar al llegar a FREQ_FINAL
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
        // ETAPA 3: PROCESAMIENTO FIR
        // --------------------------------------------------------------------
        float y_n = aplicar_filtro_fir(x_n);

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