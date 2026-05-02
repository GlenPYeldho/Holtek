TARGET ?= ht32f50030
BUILD_DIR ?= build

LOCAL_TOOLCHAIN := $(CURDIR)/tools/arm-gnu-toolchain/bin/arm-none-eabi
ifneq ($(wildcard $(LOCAL_TOOLCHAIN)-gcc $(LOCAL_TOOLCHAIN)-gcc.exe),)
TOOLCHAIN ?= $(LOCAL_TOOLCHAIN)
else
TOOLCHAIN ?= arm-none-eabi
endif

CC := $(TOOLCHAIN)-gcc
OBJCOPY := $(TOOLCHAIN)-objcopy
OBJDUMP := $(TOOLCHAIN)-objdump
SIZE := $(TOOLCHAIN)-size

MCU_FLAGS := -mcpu=cortex-m0plus -mthumb
OPT ?= -Os
STACK_SIZE ?= 512
HEAP_SIZE ?= 512

CPPFLAGS += \
  -DUSE_HT32F50020_30 \
  -DUSE_MEM_HT32F50030 \
  -DUSE_HT32_DRIVER \
  -Ivendor/cmsis/include \
  -Ivendor/holtek/HT32F5xxxx/include \
  -Ivendor/holtek/HT32F5xxxx_Driver/inc

CFLAGS += \
  $(MCU_FLAGS) \
  $(OPT) \
  -g3 \
  -std=c11 \
  -Wall \
  -Wextra \
  -ffunction-sections \
  -fdata-sections \
  -fno-common \
  -MMD \
  -MP

ASFLAGS += \
  $(MCU_FLAGS) \
  -x assembler-with-cpp \
  -Wa,--defsym,USE_HT32_CHIP=25 \
  -DSTACK_SIZE=$(STACK_SIZE) \
  -DHEAP_SIZE=$(HEAP_SIZE) \
  -MMD \
  -MP

LDSCRIPT := linker/ht32f50030.ld
LDFLAGS += \
  $(MCU_FLAGS) \
  -T$(LDSCRIPT) \
  -nostartfiles \
  --specs=nano.specs \
  --specs=nosys.specs \
  -Wl,-Map=$(BUILD_DIR)/$(TARGET).map \
  -Wl,--gc-sections

C_SOURCES := \
  src/main.c \
  src/gpio.c \
  system/syscalls.c \
  system/system_ht32f5xxxx_13.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_adc.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_bftm.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_ckcu.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_gpio.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_i2c.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_rstcu.c \
  vendor/holtek/HT32F5xxxx_Driver/src/ht32f5xxxx_tm.c

ASM_SOURCES := \
  startup/startup_ht32f5xxxx_gcc_13.s

OBJECTS := \
  $(addprefix $(BUILD_DIR)/,$(C_SOURCES:.c=.o)) \
  $(addprefix $(BUILD_DIR)/,$(ASM_SOURCES:.s=.o))

DEPS := $(OBJECTS:.o=.d)

$(BUILD_DIR)/vendor/%.o: CFLAGS += -Wno-unused-parameter

.PHONY: all clean size

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin $(BUILD_DIR)/$(TARGET).lst size

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(LDSCRIPT)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O ihex $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/%.lst: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -D $< > $@

size: $(BUILD_DIR)/$(TARGET).elf
	$(SIZE) $<

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)
