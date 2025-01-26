# Math functions for 64-bit operations
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "consts.s"

.section .text

.global uadd64
.global usub64
.global udiv64
.global ucmp64

.macro stack_to_args2 arg0, arg1
    pop a0, \arg0
    pop a1, \arg1
.endm

.macro stack_to_args4 arg0, arg1, arg2, arg3
    pop a0, \arg0
    pop a1, \arg1
    pop a2, \arg2
    pop a3, \arg3
.endm

.macro result_to_stack2 res0, res1
    push a0, \res0
    push a1, \res1
.endm

# 64-bit unsigned divison (n/d)
# Arguments
#     a0 (nlo) - least significant word of n
#     a1 (nhi) - most significant word of n
#     a2 (dlo) - least significant word of d
#     a3 (dhi) - most significant word of d
# Returns
#     a0 (qlo) - least significant word of the result
#     a1 (qhi) - most significant word of the result
#     a2 (rlo) - least significant word of the remainder
#     a3 (rhi) - most significant word of the remainder
.type udiv64, @function
udiv64:
    .set nlo, 40
    .set nhi, 36
    .set dlo, 32
    .set dhi, 28
    .set idx, 24
    .set qlo, 20
    .set qhi, 16
    .set rlo, 12
    .set rhi, 8

    stack_alloc 48

    bnez a1, 1f                        # test whether 32-bit div can be executed
    bnez a3, 1f                        # which is when both most significant words are 0
        mv a1, a2                      # run 32-bit division on lo-words
        call udiv32
        mv a2, a1                      # and set result register according to div64
        setz a1
        setz a3
        j 4f                           # and jump to the end

1:                                     # handle 64-bit division
    push a0, nlo                       # prepare the stack
    push a1, nhi
    push a2, dlo
    push a3, dhi

    push zero, qlo
    push zero, qhi
    push zero, rlo
    push zero, rhi

    push s1, idx                       # preserves s1 (used here as index)

    call bitlen64
    mv s1, a0                          # get number of iterations (bits of n)


2:
    dec s1                             # idx--
    bltz s1, 3f                        # finish if idx < 0
        stack_to_args2 rlo, rhi        # R = R << 1
        li a2, 1
        call lshift64
        result_to_stack2 rlo, rhi

        stack_to_args2 nlo, nhi
        mv a2, s1
        call getbit64
        pop t0, rlo
        or t0, t0, a0                  # R(0) = N(i)
        push t0, rlo

        stack_to_args4 rlo, rhi, dlo, dhi
        call ucmp64
        bltz a0, 2b                    # branch if R < D
            stack_to_args4 rlo, rhi, dlo, dhi
            call usub64                # R = R - D
            result_to_stack2 rlo, rhi

            stack_to_args2 qlo, qhi
            mv a2, s1
            li a3, 1
            call setbit64              # Q(i) = 1
            result_to_stack2 qlo, qhi
    j 2b

3:                                     # Prepare results
    stack_to_args4 qlo, qhi, rlo, rhi

4:  pop s1, idx                        # retrieve s1
    stack_free 48
    ret

# Adds two 64-bit numbers (x+y)
# Arguments:
#     a0 - least significant word of x
#     a1 - most significant word of x
#     a2 - least significant word of y
#     a3 - most significant word of y
# Returns:
#     a0 - least significant word of the result
#     a1 - most significant word of the result
#     a2 - carry bit if overflow
.type uadd64, @function
uadd64:
    add t0, a0, a2                     # add the least significant words
    sltu t2, t0, a2                    # carry bit from previous addition
                                       # t2 = 1 if (a0+a2) < a2
    add t1, a1, a3                     # add the most significant words
    add t1, t1, t2                     # add the carry out
    sltu a2, t1, a3                    # carry bit from previous addition
    mv a0, t0
    mv a1, t1
    ret

# 64-bit unsigned subtraction
# It uses 64-bit add based on principle that
# x-y = x + ~y + 1
# Arguments
#     a0 - least significant word of x
#     a1 - most significant word of x
#     a2 - least significant word of y
#     a3 - most significant word of y
# Returns
#     a0 - least significant word of the result
#     a1 - most significant word of the result
.type usub64, @function
usub64:
    stack_alloc
    not a2, a2
    not a3, a3
    call uadd64
    li a2, 1
    li a3, 0
    call uadd64
    stack_free
    ret


.type ucmp64, @function
ucmp64:
    bgtu a1, a3, 2f                    # xhi > yhi
    bltu a1, a3, 3f                    # xhi < yhi
    bgtu a0, a2, 2f                    # xlo > ylo
    bltu a0, a2, 3f                    # ylo < ylo
1:  li a0, 0                           # x == y
    j 4f
2:  li a0, 1                           # x > y
    j 4f
3:  li a0, -1                          # x < y
4:  ret

