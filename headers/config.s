.ifndef __CONFIG_S__
.equ __CONFIG_S__, 1

# Generic
.equ DEBUG, 0

.weak ENABLE_IRQ
.weak ENABLE_PLIC


# Global / default settings
# Don't change these, but edit your platform-specifc config file instead.

# Specifies the minimum stack size allocated per function
# when stack_alloc macro is used without any argument.
# If the macro is called with argument smaller than this value,
# the value will be defaulted to this one
# The ILP32I ABI specifies that individual stack-chunk should be
# 16-bytes long.
.set MIN_STACK_ALLOC_CHUNK, 4

# Defines the total size of a stack used be IRQ handlers.
.set ISR_STACK_SIZE, 4096

# Indicates whether the platform on which the OS will be running has
# M or Zmmul extension. If not, the OS provides a fallback solution
# that lets to execute math instructions (div, mul, etc) without any
# further changes. Means the OS should be using math instructions of
# RISC-V assembly, regardless the target platform.
.set HAS_EXTENSION_M, 1
.set HAS_EXTENSION_ZMMUL, 1

# Address where user programs being loaded
.set PROGRAM_RAM, 0x80100000
.set FLASH1_BASE, 0x22000000

#--------------------------------------

# All the above settings can be overwritten in the individaul
# per-machine configs

.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25

.equ OUTPUT_DEV, 3
.equ UART_BASE, 0x10000000


# Memory
.equ MEM_MIN_ADDR, 0x80000000
.equ MEM_MAX_ADDR, 0x803fffff
.equ STACK_SIZE, 4096
.equ MIN_STACK_ALLOC_CHUNK, 16

# Screen
.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25

# Devices
.equ RTC_BASE, 0x101000

.equ UART_BASE, 0x10000000
.equ UART_IRQ, 10

.equ PLIC_BASE, 0xc000000

.equ MTIME, 0x0200BFF8
.equ MTIMECMP, 0x02004000


# Output

# Options
# 0 - no output
# bit 0 set - output to framebuffer (writes to memory, can be inspected by gdb)
# bit 1 set - output to serial
# bit 2 set - screen over serial (bit 0 mandatory, don't set bit 1)
# bit 4 set - screen (graphics driver required, bit 0 mandatory, bit 1 or 3 optional)
# At this moment only bit 0 and 1 are supported
# When bit 0 only is set, then the framebuffer content can be checked with gdb
# The option can be provided to assembler with
# `--defsym OUTPUT_DEV=1` (see makefile)
.ifndef OUTPUT_DEV
    .equ OUTPUT_DEV, 1
.endif


.equ SCREEN_OVER_SERIAL_HBORDER, 4
.equ SCREEN_OVER_SERIAL_VBORDER, 1

.equ BORDER_COLOR, 1


# System

.equ SYSTEM_TIMER_INTERVAL, 1333333
.endif
