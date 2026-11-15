idf_component_register(SRCS "filtro_iir.c"
                    INCLUDE_DIRS "."
                    REQUIRES esp_adc esp_driver_dac esp_driver_uart esp_timer)
