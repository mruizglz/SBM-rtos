#include "cmsis_os2.h"                          // CMSIS RTOS header file
#include "stm32f4xx_hal.h"
#include <string.h> 
#include <stdlib.h>
/*----------------------------------------------------------------------------
 *      Thread 1 'Thread_Name': Sample thread
 *---------------------------------------------------------------------------*/

osThreadId_t tid_Thread_producer;                        // thread id
osThreadId_t tid_Thread_consumer;
int Init_Thread (void);  
void Producer (void *argument);                   // thread function producing data
void Consumer (void *argument);                   // thread function consuming data
int qsize=0;
uint8_t a=0;
uint8_t b=0;

typedef struct  {
	  GPIO_InitTypeDef pin;
		GPIO_TypeDef *port;
} mygpio_pin;

mygpio_pin pinB0;
mygpio_pin pinB7;

int Init_Thread (void) {
  
	
 
	
  tid_Thread_producer = osThreadNew(Producer, NULL, NULL);
  if (tid_Thread_producer == NULL) {
    return(-1);
  }
	
	tid_Thread_consumer = osThreadNew(Consumer, NULL, NULL);
  if (tid_Thread_consumer == NULL) {
    return(-1);
  }
 
  return(0);
}
 
void Producer (void *argument) {
	
	uint32_t status;
  while (1) {
		
			
				status= osThreadFlagsSet(tid_Thread_consumer,0x0001);
				osDelay(1000);
				status= osThreadFlagsSet(tid_Thread_consumer,0x0002);
				osDelay(1000);
		
	}
}
void Consumer (void *argument) {
	uint8_t val=0;
	uint32_t status;
	int errors=0;
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
    status=osThreadFlagsWait(0x3,osFlagsWaitAny,osWaitForever);
		switch (status){
			case 1:
				HAL_GPIO_TogglePin(GPIOB,led_ld1.Pin);
				a=!a;
				break; 
		case 2:
				HAL_GPIO_TogglePin(GPIOB,led_ld2.Pin);
			  b=!b;
				break;
		default:errors++;
				break;			
		}
		
		
	}
}