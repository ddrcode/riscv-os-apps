
.section .text.start

.global _start

_start:


    la a0, hello                       # Load string address
    li a5, 22                          # Load code of println system function
    ecall                              # Handle execution to the system

    mv a0, zero                        # Set the exit code
    li a5, 4                           # Code of `exit` system function
    ecall                              # Return to the system


loop:
    j loop


.section .data

hello: .string "Hello, world"



