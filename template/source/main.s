.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp, #0x8000


mov r0, #16
mov r1, #1
bl SetGPIOFunc

pin .req r0
val .req r1
counter .req r2
flip_bit .req r4

mov flip_bit, #0

loop$:
	mov pin, #16
	mov val, flip_bit
	bl SetGPIOPin

	mov counter, #0xff0000
	wait$:
		sub counter, #1
		cmp counter, #0
		bne wait$

	mvn flip_bit, flip_bit
	b loop$

