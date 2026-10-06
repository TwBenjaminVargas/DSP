#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_adc/adc_oneshot.h"

// Etiqueta para identificar las salidas en la consola de depuración (UART)
static const char *TAG = "ADC_EXAMPLE";

// Asignación de hardware:
// ADC_CHANNEL_6 corresponde físicamente al pin GPIO34 en el periférico ADC1 del ESP32.
#define EXAMPLE_ADC_CHANNEL     ADC_CHANNEL_6
#define EXAMPLE_ADC_ATTEN       ADC_ATTEN_DB_12

void app_main(void)
{
    // =========================================================================
    // INICIALIZACIÓN DE LA UNIDAD ADC (HARDWARE BASE)
    // =========================================================================
    
    // Manejador (pointer/handle) para controlar el periférico ADC1
    adc_oneshot_unit_handle_t adc1_handle;

    // Estructura de configuración inicial de la unidad ADC
    adc_oneshot_unit_init_cfg_t init_config1 = {
        .unit_id = ADC_UNIT_1, // Se selecciona ADC1 para evitar conflictos con el controlador Wi-Fi
    };
    
    // Asigna recursos de hardware e inicializa el driver para la unidad ADC1
    ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_config1, &adc1_handle));

    // =========================================================================
    // CONFIGURACIÓN DEL CANAL Y ATENUACIÓN DE ENTRADA
    // =========================================================================
    
    // Estructura de configuración específica para el canal (GPIO34)
    adc_oneshot_chan_cfg_t config = {
        .bitwidth = ADC_BITWIDTH_DEFAULT, // Ancho de palabra de 12 bits (rango dinámico: 0 a 4095)
        .atten = EXAMPLE_ADC_ATTEN,        // Atenuación de 12 dB (extiende el rango de medición a 0V - 3.3V)
    };
    
    // Aplica la configuración de resolución y atenuación al canal GPIO34
    ESP_ERROR_CHECK(adc_oneshot_config_channel(adc1_handle, EXAMPLE_ADC_CHANNEL, &config));

    ESP_LOGI(TAG, "ADC1 configurado correctamente en GPIO34.");

    // =========================================================================
    // BUCLE DE MUESTREO Y CONVERSIÓN
    // =========================================================================
    
    int adc_raw = 0;
    int voltage_mv = 0;

    while (1) {
        // Ejecuta una conversión A/D puntual (One-Shot) en el canal configurado
        // Almacena en 'adc_raw' el valor cuantizado (0 a 4095)
        ESP_ERROR_CHECK(adc_oneshot_read(adc1_handle, EXAMPLE_ADC_CHANNEL, &adc_raw));
        
        // Conversión lineal del valor entero digital a su equivalente en milivoltios
        // Fórmula: Voltaje (mV) = (Valor_RAW * V_max) / Resolución_max
        // Donde V_max = 3300 mV y Resolución_max = 4095 (2^12 - 1)
        voltage_mv = (adc_raw * 3300) / 4095;

        // Envía el resultado a la consola UART indicando el valor bruto y el voltaje
        ESP_LOGI(TAG, "Lectura RAW: %4d  |  Voltaje estimado: %4d mV", adc_raw, voltage_mv);

        // Bloquea la tarea actual durante 500 ms para ceder procesamiento al RTOS
        vTaskDelay(pdMS_TO_TICKS(500));
    }

    // Libera los recursos asignados al ADC si se sale del bucle (código inalcanzable aquí)
    ESP_ERROR_CHECK(adc_oneshot_del_unit(adc1_handle));
}