
.section .text

.global main

main:

    la a0, hello                       # Load string address
    li a5, 22                          # Load code of println system function
    ecall                              # Handle execution to the system

    mv a0, zero                        # Return 0 as exit code

    ret


.section .rodata

hello: .string "Hello, asm\n"



