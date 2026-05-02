#include "ht32.h"

#define GPIO_LED_PORT              (HT_GPIOB)
#define GPIO_LED_GPIO_ID           (GPIO_PB)
#define GPIO_LED_PIN               (GPIO_PIN_5)
#define GPIO_LED_AFIO_PIN          (AFIO_PIN_5)
#define GPIO_LED_AFIO_MODE         (AFIO_FUN_GPIO)

#define GPIO_TIMER                 (HT_BFTM0)
#define GPIO_DELAY_TICKS           (SystemCoreClock / 2u)
#define BFTM_MAX_DELAY_TICKS       (0x10000u)

static void gpio_timer_init(void)
{
  CKCU_PeripClockConfig_TypeDef clock = {{0}};

  clock.Bit.BFTM0 = 1;
  CKCU_PeripClockConfig(clock, ENABLE);

  BFTM_SetCounter(GPIO_TIMER, 0);
  BFTM_OneShotModeCmd(GPIO_TIMER, ENABLE);
}

static void gpio_delay_ticks(u32 ticks)
{
  while (ticks != 0u)
  {
    u32 chunk = ticks;

    if (chunk > BFTM_MAX_DELAY_TICKS)
    {
      chunk = BFTM_MAX_DELAY_TICKS;
    }

    BFTM_ClearFlag(GPIO_TIMER);
    BFTM_SetCounter(GPIO_TIMER, 0);
    BFTM_SetCompare(GPIO_TIMER, (BFTM_DataTypeDef)(chunk - 1u));
    BFTM_EnaCmd(GPIO_TIMER, ENABLE);

    while (BFTM_GetFlagStatus(GPIO_TIMER) != SET)
    {
    }

    ticks -= chunk;
  }
}

static void gpio_init(void)
{
  CKCU_PeripClockConfig_TypeDef clock = {{0}};

  clock.Bit.AFIO = 1;
  clock.Bit.PB = 1;
  CKCU_PeripClockConfig(clock, ENABLE);

  AFIO_GPxConfig(GPIO_LED_GPIO_ID, GPIO_LED_AFIO_PIN, GPIO_LED_AFIO_MODE);
  GPIO_PullResistorConfig(GPIO_LED_PORT, GPIO_LED_PIN, GPIO_PR_DISABLE);
  GPIO_DriveConfig(GPIO_LED_PORT, GPIO_LED_PIN, GPIO_DV_8MA);
  GPIO_WriteOutBits(GPIO_LED_PORT, GPIO_LED_PIN, SET);
  GPIO_DirectionConfig(GPIO_LED_PORT, GPIO_LED_PIN, GPIO_DIR_OUT);

  gpio_timer_init();
}

void gpio_run(void)
{
  gpio_init();

  while (1)
  {
    GPIO_WriteOutData(GPIO_LED_PORT, GPIO_ReadOutData(GPIO_LED_PORT) ^ GPIO_LED_PIN);
    gpio_delay_ticks(GPIO_DELAY_TICKS);
  }
}
