#include "ht32.h"

void gpio_run(void);

int main(void)
{
  gpio_run();

  while (1)
  {
    __WFI();
  }
}
