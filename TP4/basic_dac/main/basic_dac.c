#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/dac_oneshot.h"

// Etiqueta para las salidas en la consola de depuración
static const char *TAG = "DAC_EXAMPLE";

// En el ESP32:
// DAC_CHANNEL_0 corresponde al pin físico GPIO25 (DAC1)
// DAC_CHANNEL_1 corresponde al pin físico GPIO26 (DAC2)
#define EXAMPLE_DAC_CHANNEL     DAC_CHAN_0

void app_main(void)
{
    // =========================================================================
    // INICIALIZACIÓN Y CONFIGURACIÓN DEL DAC (HARDWARE BASE)
    // =========================================================================
    
    // Manejador (handle) para controlar el canal del DAC
    dac_oneshot_handle_t dac_handle;

    // Estructura de configuración inicial para el canal seleccionado
    dac_oneshot_config_t init_cfg = {
        .chan_id = EXAMPLE_DAC_CHANNEL,
    };

    // Asigna recursos de hardware e inicializa el driver del DAC en GPIO25
    ESP_ERROR_CHECK(dac_oneshot_new_channel(&init_cfg, &dac_handle));

    ESP_LOGI(TAG, "DAC configurado correctamente en GPIO25.");

    // =========================================================================
    // BUCLE DE GENERACIÓN DE SEÑAL ANALÓGICA (ONDA EN RAMPA)
    // =========================================================================
    
    uint8_t dac_value = 0;
    uint32_t voltage_mv = 0;

    while (1) {
        // Escribe el valor digital de 8 bits (0 a 255) en el canal DAC
        ESP_ERROR_CHECK(dac_oneshot_output_voltage(dac_handle, dac_value));

        // Cálculo del voltaje analógico equivalente generado en milivoltios
        // Fórmula: Voltaje (mV) = (Valor_DAC * V_max) / Resolución_max
        // Donde V_max = 3300 mV y Resolución_max = 255 (2^8 - 1)
        voltage_mv = (dac_value * 3300) / 255;

        // Imprime en consola cada 32 pasos para no saturar el monitor serie
        if (dac_value % 32 == 0) {
            ESP_LOGI(TAG, "Valor DAC (RAW): %3d | Voltaje salida: %4lu mV", dac_value, voltage_mv);
        }

        // Incrementa el valor digital (al superar 255 vuelve automáticamente a 0)
        dac_value++;

        // Pequeña retardo de 20 ms entre cada escalón de voltaje
        vTaskDelay(pdMS_TO_TICKS(20));
    }

    // Libera los recursos del DAC en caso de salir del bucle (inalcanzable aquí)
    ESP_ERROR_CHECK(dac_oneshot_del_channel(dac_handle));
}