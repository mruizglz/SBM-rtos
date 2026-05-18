#include "cmsis_os2.h"                          // CMSIS RTOS header file
#include "stm32f4xx_hal.h"
#include <string.h> 
#include <stdlib.h>
/*----------------------------------------------------------------------------
 *      Thread 1 'Thread_Name': Sample thread
 *---------------------------------------------------------------------------*/

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
		osDelay(250);
		
  }
}