.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp, #0x8000

mov r0, #16
mov r1, #1
bl set_gpio_function

mov r0, #16
mov r1, #0
bl set_gpio

loop$:
b loop$

/*
@ GPIO controller address
ldr r0, =0x20200000

@ Enable ACT LED wired as pin 16
@ Each pin described as 3 bits function select.
@ Pins is grouped in 10, controlled by 4 bytes.
@ So LED 16 is 6th ping in second group of bytes (4..7).
@ Bits for LED 16 in that group is 3*16 = 18 and 19,20.
@ That's why we shift to 18.
mov r1, #1
lsl r1, #18
str r1, [r0, #4]

mov r3, #0

loop$:

@ Set bit either in turn off or turn of section
mov r4, #40
cmp r3, #0
movne r4, #28

@ Now turn on bit #16.
@ We set 16th bit in turn off section of GPIO controller.
@ (Turn off because it's active low.)
mov r1, #1
lsl r1, #16
str r1, [r0, r4]

@ Wait loop
mov r2, #0x7f0000
wait1$:
sub r2, #1
cmp r2, #0
bne wait1$

@ Flip the bits
mvn r3, r3

@ Start over
b loop$
*/
