TARGET = stdlib

BUILD_DIR = build
C_SRC = $(shell find -name '*.c')

# compile
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc 
CP = $(PREFIX)objcopy 
AS = $(PREFIX)gcc -x assembler-with-cpp
SZ = $(PREFIX)size

# from Truestudio
ASM_SRC = ./startup_stm32f10x_md.s

# wheather debug DEBUG = 1
DEBUG = 1

#optimize
OPT = -Og

###############
# CFLAGS
###############

#cpu
CPU = -mcpu=cortex-m3

# fpu
# NONE for m0/3

# mcu
MCU = $(CPU) -mthumb

AS_DEFS =

# C defs
C_DEFS = \
				 -DUSE_STDPERIPH_DRIVER \
				 -DSTM32F10X_MD

AS_INC =

C_INC = \
				-I./ \
				-Icore \
				-Ilib/inc \
				-Iusr/inc

# the "sections" options and the --gc-sections in link process
# is used to delete the dead code that not used
# they must be used at the same time

ASFLAG = $(MCU) $(AS_DEFS) $(AS_INC) $(OPT)-Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INC) $(OPT) -Wall -fdata-sections -ffunction-sections

# set debug flag
ifeq ($(DEBUG), 1)
CFLAGS += -g
endif

# dependency output .d file to build dir
# mmd output .d file -mp will gen a phony target to
# make sure make no error when deleted .h file
CFLAGS += -MMD -MP -MF"$(BUILD_DIR)/$(notdir $(@:%.o=%.d))"

# link script
# this file define memory map/section stack location and size
LDSCRIPT = ./stm32f103c8tx.ld

#LIBS = -lc -lm -lnosys
# lc stand for standard c LIB
# lm stands for math LIB
# lnosys is from newlib(For embeded) not sure what for (for now)
LIBS = -lc
LIBDIR = 

#Wl, pass things behind ',' to linker
# map seems store data useful for debug
# cref seems also have to do with debug
# --gc-sections delete the unused code
LDFLAG = $(MCU) -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections


all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

# 我认为 vpath 是提示相关文件去“哪”找
OBJ = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SRC:%.c=%.o)))

vpath %.c $(sort $(dir $(C_SRC)))

OBJ += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SRC:%.s=%.o)))

vpath %.s $(sort $(dir $(ASM_SRC)))

# "|" then reqiures changes won't cause target rebuild(update)
# 因为每次 make 文件夹的时间会变如果不用 “|” 那么每一次都会完全重新编译

# things behind a like "d, lms" is settings for .lis file
# after "=" is the .lis file
# .lst file contains rich info about stack frame
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:%.c=%.lst)) $< -o $@
	
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJ) Makefile | $(BUILD_DIR)
	$(CC) $(OBJ) $(LDFLAG) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(CP) -O ihex $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(CP) -O binary -S  $< $@

$(BUILD_DIR):
	mkdir $@

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)

burn: all
	st-flash write $(BUILD_DIR)/$(TARGET).bin 0x08000000
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)
