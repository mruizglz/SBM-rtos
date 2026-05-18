# SBM

Repositorio con código de ejemplo para entender el funcionamiento de CMSIS-RTOS V2 en STM32.

## Documentación

La documentación de ayuda está disponible en:

- Sphinx Doc: https://mruizglz.github.io/SBM-rtos
- PDF: https://mruizglz.github.io/SBM-rtos/simplepdf/SBM-CMSIS-RTOS-V2.pdf

## Ejemplos incluidos en el repositorio

- `/home/runner/work/SBM-rtos/SBM-rtos/ejemplothreads`
  - Uso básico de **threads** concurrentes.
  - Crea dos hilos que controlan los LEDs en `PB0` y `PB7` con distintos retardos (`osThreadNew`, `osDelay`).

- `/home/runner/work/SBM-rtos/SBM-rtos/ejemplothreads-flags`
  - Comunicación/sincronización entre hilos mediante **thread flags**.
  - Un hilo `Producer` señaliza flags y un hilo `Consumer` actúa sobre LEDs según `osThreadFlagsWait`.

- `/home/runner/work/SBM-rtos/SBM-rtos/ejemplothreads-queues`
  - Comunicación entre hilos con **colas de mensajes**.
  - Un `Producer` inserta datos con `osMessageQueuePut` y un `Consumer` los procesa con `osMessageQueueGet` para controlar LEDs.

- `/home/runner/work/SBM-rtos/SBM-rtos/ejemplothreads-timers`
  - Uso de **software timers** en CMSIS-RTOS v2.
  - Crea un timer one-shot y otro periódico (`osTimerNew`, `osTimerStart`) para secuenciar el comportamiento de los LEDs.

Más detalle de cada ejemplo en la documentación Sphinx (`docs/*.rst`).
