#***************************************************************************************
# Copyright (c) 2020-2022 Institute of Computing Technology, Chinese Academy of Sciences
#
# NEMU is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
#
# See the Mulan PSL v2 for more details.
#**************************************************************************************/

NAME = gcpt

WORK_DIR = $(CURDIR)

ifdef O
	BUILD_DIR = $(shell readlink -f $(O))/build
else
	BUILD_DIR = $(WORK_DIR)/build
endif

OBJ_DIR ?= $(BUILD_DIR)/obj
BINARY ?= $(BUILD_DIR)/$(NAME)

.DEFAULT_GOAL = app

INC_DIR += $(NEMU_HOME)/include/generated
# Compilation flags
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJDUMP = $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy
INCLUDES  = $(addprefix -I, $(INC_DIR))
CFLAGS   += -fno-PIE -mcmodel=medany -O2 -MMD -Wall -Werror $(INCLUDES) -march=rv64gcv


ifdef GCPT_PAYLOAD_PATH
CFLAGS += -DGCPT_PAYLOAD_PATH=\"$(GCPT_PAYLOAD_PATH)\"
endif

# Files to be compiled
SRCS = $(shell find src/ -name "*.[cS]")
OBJS = $(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(basename $(SRCS))))

# Compilation patterns
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@) && echo + CC $<
	@$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/%.o: %.S
	@mkdir -p $(dir $@) && echo + AS $<
	@$(CC) $(CFLAGS) -c -o $@ $<

# Dependencies
-include $(OBJS:.o=.d)

$(BINARY): $(OBJS)
	@echo + LD $@
	@$(LD) -O2 -T restore.lds -o $@ $^
	@$(OBJDUMP) -S $@ --start-address=0x0 --stop-address=0x100000 > $@.txt
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $@ $@.bin

app: $(BINARY)

.PHONY: clean
clean:
	-rm -rf $(BUILD_DIR)
