*************************************************************************
Uso básico de threads y colas en CMSIS RTOS v2
*************************************************************************

Este documento describe el funcionamiento de un programa en C que utiliza CMSIS RTOS v2 y la biblioteca HAL de STM32 para controlar dos LEDs mediante hilos concurrentes que se comunican con colas.

-------------------
Descripción General
-------------------

El programa crea dos hilos, denominados ``Producer`` y ``Consumer``. El hilo ``Producer`` se encarga de introducir datos en la cola que tiene el identificador ``id_MsgQueue``.
El numero total de mensajes que se introducen en la cola en cada iteración del bucle ``while`` es 32 con un tiempo de retardo entre operaciones de escritura que es variable
El ``Consumer`` se encarga de extraer los datos de cola y de actuar sobre los leds en función del valor leido de la cola.

-------------------
Estructura de Datos
-------------------

Se define una estructura llamada ``mygpio_pin`` que encapsula toda la información necesaria para controlar un LED:

- ``GPIO_InitTypeDef pin``: configuración del pin (modo, velocidad, tipo de salida).
- ``GPIO_TypeDef *port``: puerto GPIO al que pertenece el pin.


Esta estructura permite pasar todos los parámetros necesarios a la función del hilo de forma organizada.

---------------------------
Inicialización de los Hilos
---------------------------

La función ``Init_Thread`` realiza las siguientes operaciones:

1. Crea una cola con ``osMessageQueueNew`` para almacenar hasta 16 mensajes cada uno de tamaño un ``uint8_t``, es decir, un solo byte.
2. Crea un hilo ``Consumer`` con ``osThreadNew``, ejecutando la función ``Consumer``.
3. Crea un hilo ``Producer`` con ``osThreadNew``, ejecutando la función ``Producer``.


-------------------------
Función del Hilo Producer
-------------------------

La función ``Producer(void *argument)`` realiza las siguientes operaciones:
1. De manera continua en un bucle infinito inserta en cola en cada iteración del bucle while 32 mensajes de 1 byte con el valor de la variable index. 
2. Los mensajes se introducen con un retardo que varia desde 100ms hasta 400ms
3. La función osMessageQueuePut introduce los mensajes con timeout 0, lo cúal implica que si no hay sitio en la cola el mensaje no se podrá guardar.
   
-------------------------
Función del Hilo Consumer
-------------------------
La función ``Consumer(void *argument)`` realiza las siguientes operaciones:
1. De manera continua en un bucle infinito extrae de la cola los mensajes introducidos por el hilo ``Producer``.
2. Si se saca un valor de la cola se procede a encender o apagar los leds en función del valor leido.
3. La variable errors_or_timeout cuenta el número de veces que no se ha podido leer un mensaje de la cola, ya sea por timeout o porque la cola está vacía.

-----------------------
Uso de HAL y CMSIS RTOS
-----------------------

- **HAL (Hardware Abstraction Layer)**: se utiliza para configurar e inicializar los pines GPIO de forma sencilla y portable.
- **CMSIS RTOS v2**: proporciona las funciones para crear y gestionar hilos, como ``osThreadNew`` y ``osDelay``, y las funciones para gestionar las colas.

-------------
Código Fuente
-------------

.. code-block:: c

	#include "cmsis_os2.h"                          // CMSIS RTOS header file
	#include "stm32f4xx_hal.h"
	#include <string.h> 
	#include <stdlib.h>


	osThreadId_t tid_Thread;                        // thread id
	osMessageQueueId_t id_MsgQueue;  
	int Init_Thread (void);  
	void Producer (void *argument);                   // thread function producing data
	void Consumer (void *argument);                   // thread function consuming data
	int qsize=0;
	uint16_t h=0;
	uint8_t i=0;

	typedef struct  {
		GPIO_InitTypeDef pin;
			GPIO_TypeDef *port;
	} mygpio_pin;

	mygpio_pin pinB0;
	mygpio_pin pinB7;

	int Init_Thread (void) {
	
		id_MsgQueue = osMessageQueueNew(16, sizeof(uint8_t), NULL);
	
		
	tid_Thread = osThreadNew(Producer, NULL, NULL);
	if (tid_Thread == NULL) {
		return(-1);
	}
		
		tid_Thread = osThreadNew(Consumer, NULL, NULL);
	if (tid_Thread == NULL) {
		return(-1);
	}
	
	return(0);
	}
	
	void Producer (void *argument) {
		uint8_t index=0;
		osStatus_t status;
	while (1) {
			for( h=1; h<5; h++){
				for( i=0; i< 8; i++){
					status=osMessageQueuePut(id_MsgQueue, &index, 0U, 0U);
					index++;
					osDelay(h*100);
				}
			}
		}
	}
	void Consumer (void *argument) {
		uint8_t val=0;
		osStatus_t status;
		int errors_or_timeouts=0;
		GPIO_InitTypeDef led_ld1 = {
			.Pin = GPIO_PIN_0,
			.Mode = GPIO_MODE_OUTPUT_PP,
			.Pull = GPIO_NOPULL,
			.Speed = GPIO_SPEED_FREQ_LOW
		};
		GPIO_InitTypeDef led_ld2 = {
			.Pin = GPIO_PIN_7,
			.Mode = GPIO_MODE_OUTPUT_PP,
			.Pull = GPIO_NOPULL,
			.Speed = GPIO_SPEED_FREQ_LOW
		};
		__HAL_RCC_GPIOB_CLK_ENABLE();
		
		HAL_GPIO_Init(GPIOB, &led_ld1);
		
		HAL_GPIO_Init(GPIOB, &led_ld2);
		
			
	while (1) {
		qsize=osMessageQueueGetCount (id_MsgQueue);    
			status = osMessageQueueGet(id_MsgQueue, &val, NULL, 10U);   // wait for message
			if (status == osOK){
				HAL_GPIO_WritePin(GPIOB,led_ld1.Pin,(GPIO_PinState) val&0x01);
				HAL_GPIO_WritePin(GPIOB,led_ld2.Pin,(GPIO_PinState)(val&0x02)>>1);
				
			}
			else {
				errors_or_timeouts++;
			}
			osDelay(250); //This delay is to simulate an operation that needs 101ms to complete
			
	}
	}

------------
Dependencias
------------

- Librería HAL de STM32.
- CMSIS RTOS v2.

------------------------------------------------------
Preguntas y respuestas sobre **ejemplothreads-queues**
------------------------------------------------------

Esta sección contiene una serie de preguntas con sus respectivas respuestas sobre el funcionamiento del código que utiliza CMSIS RTOS v2 para controlar LEDs en una placa STM32.


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
¿Cuál es el propósito de la cola de mensajes `id_MsgQueue` en esta aplicación?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


La cola de mensajes `id_MsgQueue` actúa como un canal de comunicación y sincronización entre los hilos `Producer` y `Consumer`. Permite que el hilo productor envíe datos (índices) al consumidor de forma segura y sincronizada. Al definir una cola con capacidad para 16 elementos de tipo `uint8_t`, se establece un buffer temporal que desacopla la producción y el consumo de datos.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
¿Qué función cumple el bucle anidado en el hilo `Producer`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

El bucle anidado en `Producer` genera una secuencia de valores que se colocan en la cola de mensajes. El bucle externo recorre `h` de 1 a 4, y el interno recorre `i` de 0 a 7. En cada iteración, se coloca un valor en la cola (`index`) y se incrementa. El retardo `osDelay(h*100)` introduce una variabilidad en el tiempo entre envíos, oscilando entre 100 ms y 400 ms. Esto simula diferentes tasas de producción de datos. 

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
¿Cuanto tiempo tarda en llenarse la cola de mensajes `id_MsgQueue`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


En la cola se introducen 32 mensajes en cada ciclo completo de los bucles anidados (8 mensajes por cada uno de los 4 valores de `h`) pero el Thread Consumer extrae mensajes cada 250ms en el caso de que existan. Por tanto la cola nunca llega a llenarse.
Intente calcular cual sería el numero máximo de mensajes que se pueden acumular en la cola.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
¿cuanto vale la variable errors_or_timeouts despues de 1 minuto de ejecución del código?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Vale 0 porque no se produce dicha condición nunca.

.. note:: 
   Challenge: Modifique el código del hilo ``Producer`` para que la variable errors_or_timeouts no valga cero.


