#include "cmsis_os2.h"                          // CMSIS RTOS header file
#include "stm32f4xx_hal.h"
#include <stdlib.h> 
/*----------------------------------------------------------------------------
 *      Thread 1 'Thread_Name': Sample thread
 *---------------------------------------------------------------------------*/

osThreadId_t tid_Thread;                        // thread id
int Init_Thread (void);  
void Thread (void *argument);                   // thread function
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
typedef struct  {
	  GPIO_InitTypeDef pin;
		GPIO_TypeDef *port;
		int delay;
		uint8_t counter;
} mygpio_pin;

mygpio_pin pinB0;
mygpio_pin pinB7;
int Init_Thread (void) {
 
	// Initialize LEDS
    __HAL_RCC_GPIOB_CLK_ENABLE();
	pinB0.pin= led_ld1;
	pinB0.port=GPIOB;
	pinB0.delay=15;
	pinB0.counter=1;
  tid_Thread = osThreadNew(Thread, (void *)&pinB0, NULL);
  if (tid_Thread == NULL) {
    return(-1);
  }
	pinB7.pin= led_ld2;
	pinB7.port=GPIOB;
	pinB7.delay=10;
  pinB7.counter=0;
	tid_Thread = osThreadNew(Thread, (void *)&pinB7, NULL);
  if (tid_Thread == NULL) {
    return(-1);
  }
 
  return(0);
}
 
void Thread (void *argument) {
	static uint32_t a=0;
  mygpio_pin *gpio = (mygpio_pin *)argument;
	HAL_GPIO_Init(gpio->port, &(gpio->pin));	
  while (1) {
    gpio->counter++;
		HAL_GPIO_TogglePin(gpio->port, gpio->pin.Pin);
		osDelay(gpio->delay);
  }
}
