#include "cmsis_os2.h"                          // CMSIS RTOS header file
#include "stm32f4xx_hal.h"
#include <string.h>
#include <stdlib.h>


void Init_Threads (void);
void Timers (void*);
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
} mygpio_pin;

mygpio_pin pinB0;
mygpio_pin pinB7;
void Timer1_Callback_1(void *arg);
void Timer1_Callback_2(void *arg);
osTimerId_t timsoft2 ;
void Init_Threads(void){
	 osThreadId_t tid_Thread = osThreadNew(Timers, NULL, NULL);
}
void Timers (void* arg) {


	__HAL_RCC_GPIOB_CLK_ENABLE();

	HAL_GPIO_Init(GPIOB, &led_ld1);

	HAL_GPIO_Init(GPIOB, &led_ld2);
	HAL_GPIO_WritePin(GPIOB, led_ld1.Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(GPIOB, led_ld2.Pin, GPIO_PIN_RESET);

	osTimerId_t timsoft1 = osTimerNew(Timer1_Callback_1, osTimerOnce, NULL, NULL);

	osTimerStart(timsoft1,10000);
	timsoft2 = osTimerNew(Timer1_Callback_2, osTimerPeriodic, NULL, NULL);


  while(1){
		osDelay(1000);
}
}
void Timer1_Callback_1(void *arg){

			HAL_GPIO_TogglePin(GPIOB,led_ld1.Pin);
			osTimerStart(timsoft2, 500);

}

void Timer1_Callback_2(void *arg){

			HAL_GPIO_TogglePin(GPIOB,led_ld2.Pin);

}
