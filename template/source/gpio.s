.globl GetGPIOAddr
GetGPIOAddr:
	ldr r0, =0x20200000
	mov pc,lr

.globl SetGPIOFunc
SetGPIOFunc:

	/* 
	 * Check inputs.
	 * r0 is GPIO pin, r1 is function
	 * r0 <= 53 && r1 <= 7
	 */
	cmp	r0, #53
	cmpls r1, #7
	movhi pc, lr

	/* Get GPIO controller address in r0 */
	push {lr}
	push {r4} /* r4 is callee-saved according to ABI */
	mov r2, r0
	bl GetGPIOAddr

	/* 
	 * Calc pin block in r0.
	 * r2 is pin.
	 * r2 will be remainder (division by subtracting)
	 */
	pinblock$:
		cmp r2, #9
		subhi r2, #10
		addhi r0, #4
		bhi pinblock$

	/* 
	 * r0 - start of the 4-byte pin block
	 * r1 - function to set
	 * r2 - pin in pin block 
	 */

	/* Calc bit shift as r2*3 */
	mov r3, r2
	add r2, r3
	add r2, r3

	/* Set function bits in pin block */
	ldr r4, [r0]
	lsl r1, r2
	orr r4, r1
	str r4, [r0]
	
	pop {r4}
	pop {pc}

.globl SetGPIOPin
SetGPIOPin:

	pin .req r0
	val .req r1

	/* Check inputs */
	cmp pin, #53
	movhi pc, lr
	push {lr}
	push {r4-r6} /* Must preserve that registers according to ABI */

	mov r2, pin
	.unreq pin
	pin .req r2

	/* Get GPIO controller address in r0 */
	bl GetGPIOAddr
	gpio_addr .req r0

	/* GPIO controller have 8 bytes describing 64 pins.
	 * Register size is 4 byte, so we need to calculate pin bank.
	 * Then we shift GPIO controller address by the bank size.
	 * And finally calculate shift of pin number in bank.
	 */
	bank .req r3
	lsr bank, pin, #5
	lsl bank, #2
	add gpio_addr, bank
	.unreq bank

	and pin, #31
	set_bit .req r3
	unset_bit .req r4
	mov set_bit, #1
	lsl set_bit, pin
	mvn unset_bit, set_bit
	.unreq pin

	/* 
	 * Now we update corresponding bit.
	 * To not overwrite whole bank we calculate masks and then and'ing/or'ing it 
	 */
	pins_on .req r5
	pins_off .req r6
	ldr pins_on, [gpio_addr, #28]
	ldr pins_off, [gpio_addr, #40]

	teq val, #0
	.unreq val

	orreq pins_off, set_bit
	andeq pins_on, unset_bit

	orrne pins_on, set_bit
	andne pins_off, unset_bit 

	str pins_on, [gpio_addr, #28]
	str pins_off, [gpio_addr, #40]

	.unreq set_bit
	.unreq unset_bit
	.unreq gpio_addr
	.unreq pins_on
	.unreq pins_off

	pop {r4-r6}
	pop {pc}

