#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/gpio.h"
#include "driver/gptimer.h"

static const char *TAG = "TIMER_INTERRUPT";

// Pines de Hardware
#define LED_GPIO                GPIO_NUM_2

// Configuración del Timer (1 segundo = 1,000,000 microsegundos)
#define TIMER_RESOLUTION_HZ     1000000 // 1 MHz -> 1 tick = 1 microsegundo (us)
#define TIMER_ALARM_PERIOD_US   1000000 // Periodo de 1,000,000 ticks = 1 segundo

static TaskHandle_t main_task_handle = NULL;

// =========================================================================
// RUTINA DE SERVICIO DE INTERRUPCIÓN (ISR) DEL TIMER
// =========================================================================
// Esta función se ejecuta directamente en contexto de hardware (ISR)
static bool IRAM_ATTR on_timer_alarm_cb(gptimer_handle_t timer, const gptimer_alarm_event_data_t *edata, void *user_ctx)
{
    BaseType_t high_task_awoken = pdFALSE;

    // Envía un evento directo a la tarea principal sin usar bloqueos pesados
    vTaskNotifyGiveFromISR(main_task_handle, &high_task_awoken);

    // Retornar true le avisa al FreeRTOS si debe hacer un cambio de contexto inmediato
    return (high_task_awoken == pdTRUE);
}

void app_main(void)
{
    // Guarda el manejador de la tarea principal para recibir notificaciones desde la ISR
    main_task_handle = xTaskGetCurrentTaskHandle();

    // =========================================================================
    // CONFIGURACIÓN DEL GPIO (LED DE SALIDA)
    // =========================================================================
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << LED_GPIO),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    ESP_ERROR_CHECK(gpio_config(&io_conf));

    // =========================================================================
    // CONFIGURACIÓN DEL TIMER DE HARDWARE (GPTIMER)
    // =========================================================================
    gptimer_handle_t gptimer = NULL;
    gptimer_config_t timer_config = {
        .clk_src = GPTIMER_CLK_SRC_DEFAULT,
        .direction = GPTIMER_COUNT_UP,      // Conteo ascendente
        .resolution_hz = TIMER_RESOLUTION_HZ, // Frecuencia de ticks: 1 MHz
    };
    ESP_ERROR_CHECK(gptimer_new_timer(&timer_config, &gptimer));

    // =========================================================================
    // REGISTRO DEL CALLBACK DE INTERRUPCIÓN
    // =========================================================================
    gptimer_event_callbacks_t cbs = {
        .on_alarm = on_timer_alarm_cb, // Asigna nuestra ISR
    };
    ESP_ERROR_CHECK(gptimer_register_event_callbacks(gptimer, &cbs, NULL));

    // =========================================================================
    // CONFIGURACIÓN DE LA ALARMA Y RECARGA AUTOMÁTICA
    // =========================================================================
    gptimer_alarm_config_t alarm_config = {
        .alarm_count = TIMER_ALARM_PERIOD_US, // Alarma a los 1,000,000 ticks (1s)
        .reload_count = 0,                     // Reinicia la cuenta en 0
        .flags.auto_reload_on_alarm = true,   // Habilita auto-recarga periódica
    };
    ESP_ERROR_CHECK(gptimer_set_alarm_action(gptimer, &alarm_config));

    // Activa e inicia el Timer
    ESP_ERROR_CHECK(gptimer_enable(gptimer));
    ESP_ERROR_CHECK(gptimer_start(gptimer));

    ESP_LOGI(TAG, "Timer por interrupción iniciado en GPIO2 (Periodo: 1 seg).");

    // =========================================================================
    // BUCLE PRINCIPAL (ATENCIÓN A EVENTOS DE LA ISR)
    // =========================================================================
    uint8_t led_state = 0;

    while (1) {
        // Bloquea la tarea y espera hasta recibir la notificación desde la ISR
        ulTaskNotifyTake(pdTRUE, portMAX_DELAY);

        // Alterna el estado del LED (Conmutación)
        led_state = !led_state;
        gpio_set_level(LED_GPIO, led_state);

        ESP_LOGI(TAG, "Interrupción de Timer recibida -> Estado LED: %s", led_state ? "ENCENDIDO" : "APAGADO");
    }
}