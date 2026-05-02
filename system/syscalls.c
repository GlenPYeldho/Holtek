#include <errno.h>
#include <stddef.h>
#include <stdint.h>

extern uint8_t __HeapBase;
extern uint8_t __HeapLimit;

void *_sbrk(ptrdiff_t increment)
{
  static uint8_t *heap_end;
  uint8_t *previous_heap_end;

  if (heap_end == NULL)
  {
    heap_end = &__HeapBase;
  }

  if (increment < 0)
  {
    errno = ENOMEM;
    return (void *)-1;
  }

  if ((uintptr_t)heap_end + (uintptr_t)increment > (uintptr_t)&__HeapLimit)
  {
    errno = ENOMEM;
    return (void *)-1;
  }

  previous_heap_end = heap_end;
  heap_end += increment;

  return previous_heap_end;
}
