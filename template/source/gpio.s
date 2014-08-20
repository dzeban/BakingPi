.globl get_gpio_addr
get_gpio_addr:
ldr r0, =0x20200000
mov pc,lr

.globl set_gpio_function
set_gpio_function:

	/* 
	 * Check inputs.
	 * r0 is GPIO pin, r1 is function
	 * r0 <= 53 && r1 <= 8
	 */
	cmp	r0, #53
	cmpls r1, #7
	movhi pc, lr

	/* Get GPIO controller address in r0 */
	push {lr}
	mov r2, r0
	bl get_gpio_addr

	/* 
	 * Calc pin block in r0.
	 * r2 will be remainder (division by subtracting)
	 */
	pinblock$:
		cmp r2, #9
		subhi r2, #10
		addhi r0, #4
		bhi pinblock$

	/* r2*3 */
	add r2, r2,lsl #1
	/*
	mov r3, r2
	add r2, r3
	add r2, r3
	*/

	lsl r1, r2
	str r1, [r0]
	/*
	mov r4, [r0]
	orr r4, r1
	str r4, [r0]
	*/
	pop {pc}


.globl set_gpio
set_gpio:

	pin .req r0
	val .req r1

	/* Check inputs */
	cmp pin, #53
	movhi pc, lr
	push {lr}

	mov r2, pin
	.unreq pin
	pin .req r2

	/* Get GPIO controller address in r0 */
	bl get_gpio_addr
	gpio_addr .req r0

	bank .req r3
	lsr bank, pin, #5
	lsl bank, #2
	add gpio_addr, bank
	.unreq bank

	and pin, #31
	set_bit .req r3
	mov set_bit, #1
	lsl set_bit, pin
	.unreq pin

	teq val, #0
	.unreq val

	streq set_bit, [gpio_addr, #40]
	strne set_bit, [gpio_addr, #28]
	.unreq set_bit
	.unreq gpio_addr

	pop {pc}

