			.code   32
			.text

@=========================================================================
@ Description:  Montgomery modular multiplication in-place.
@
@			void MontgomeryProductInPlace(
@				unsigned int *a,  // write result back to a
@				const unsigned int *b,
@				const unsigned int *n,
@				unsigned int w,  // must be >= 3
@				unsigned int np0
@			);
@
@ Arguments:
@			a1/r0 = a
@			a2/r1 = b
@			a3/r2 = n
@			a4/r3 = w
@			sp[0] = np0
@ Return:
@			none
@=========================================================================

			.globl  MontgomeryProductInPlace
MontgomeryProductInPlace:
			@ load np0 from stack
			ldr     r12, [sp]

			@ save registers
			stmdb   sp!, {r4, r5, lr}

			@ allocate space on stack to copy a
			sub     sp, sp, r3, lsl #2

			@ add stack parameters (w, np0) for call to MontgomeryProduct
			stmdb   sp!, {r3, r12}

			@ save w
			mov     r4, r3

			@ copy a onto stack
			add     r14, sp, #8
			mov     r12, r0
copyA:
			ldr     r5, [r12], #4
			subs    r3, r3, #1
			str     r5, [r14], #4
			bne     copyA

			@ call MontgomeryProduct
			mov     r3, r2
			mov     r2, r1
			add     r1, sp, #8
			bl      MontgomeryProduct

			@ restore stack and return
			add     sp, sp, #8
			add     sp, sp, r4, lsl #2
			ldmia   sp!, {r4, r5, pc}


@=========================================================================
@ Description:  Montgomery modular squaring in-place.
@
@			void MontgomerySquareInPlace(
@				unsigned int *a,  // write result back to a
@				const unsigned int *n,
@				unsigned int w,  // must be >= 3
@				unsigned int np0
@			);
@
@ Arguments:
@			a1/r0 = a
@			a2/r1 = n
@			a3/r2 = w
@			a4/r3 = np0
@ Return:
@			none
@=========================================================================

			.globl  MontgomerySquareInPlace
MontgomerySquareInPlace:
			@ save registers
			stmdb   sp!, {r4, lr}

			@ allocate space on stack to copy a
			sub     sp, sp, r2, lsl #2

			@ add stack parameters (w, np0) for call to MontgomeryProduct
			stmdb   sp!, {r2, r3}

			@ save w
			mov     r4, r2

			@ copy a onto stack
			add     r14, sp, #8
			mov     r12, r0
copyA2:
			ldr     r3, [r12], #4
			subs    r2, r2, #1
			str     r3, [r14], #4
			bne     copyA2

			@ call MontgomeryProduct
			mov     r3, r1
			add     r2, sp, #8
			add     r1, sp, #8
			bl      MontgomeryProduct

			@ restore stack and return
			add     sp, sp, #8
			add     sp, sp, r4, lsl #2
			ldmia   sp!, {r4, pc}


@=========================================================================
@ Description:  Montgomery modular multiplication.
@
@			void MontgomeryProduct(
@				unsigned int *d,  // cannot be same as a, b, or n
@				const unsigned int *a,
@				const unsigned int *b,
@				const unsigned int *n,
@				unsigned int w,  // must be >= 3
@				unsigned int np0
@			);
@
@ Arguments:
@			a1/r0 = d
@			a2/r1 = a
@			a3/r2 = b
@			a4/r3 = n
@			sp[0] = w
@			sp[1] = np0
@ Return:
@			none
@
@ Writes to `d` during the computation. Therefore, `d' cannot be the same
@ as `a`, `b`, or `n` so that they do not get clobbered during the
@ computation.
@
@ Makes use of the `umlal` instruction available in ARM architectures
@ v3M and v4 or later.
@
@ Stack frame:
@ ----------------------------------
@           | entry | saved | local |
@ ----------|-------|-------|-------|
@ np0       | sp+4  | sp+40 | sp+64 |
@ w         | sp+0  | sp+36 | sp+60 |
@ saved lr  |       | sp+32 | sp+56 |
@ saved r11 |       | sp+28 | sp+52 |
@ saved r10 |       | sp+24 | sp+48 |
@ saved r9  |       | sp+20 | sp+44 |
@ saved r8  |       | sp+16 | sp+40 |
@ saved r7  |       | sp+12 | sp+36 |
@ saved r6  |       | sp+8  | sp+32 |
@ saved r5  |       | sp+4  | sp+28 |
@ saved r4  |       | sp+0  | sp+24 |
@ d[w]      |       |       | sp+20 |
@ np0       |       |       | sp+16 |
@ w-1       |       |       | sp+12 |
@ n         |       |       | sp+8  |
@ b         |       |       | sp+4  |
@ d         |       |       | sp+0  |
@ ----------------------------------
@
@ Register usage:
@ ----------------------------------------------------------------------------
@             |r0 |r1 |r2 |r3 |r4|r5 |r6  |r7 |r8|r9|r10|r11|r12 |r13|r14 |r15|
@             |a1 |a2 |a3 |a4 |v1|v2 |v3  |v4 |v5|v6|v7 |fp |ip  |sp |lr  |pc |
@ ------------|---|---|---|---|--|---|----|---|--|--|---|---|----|---|----|---|
@ entry       |d  |a  |b  |n  |  |   |    |   |  |  |   |   |    |sp |    |pc |
@ zero d      |d  |a  |b  |n  |w |ic |    |   |  |  |   |0  |    |sp |d+i |pc |
@ i loop init |d  |a  |b  |n  |w |   |    |   |  |  |   |0  |    |sp |    |pc |
@ i loop body |d  |a+i|b  |n  |ic|   |    |   |  |  |   |0  |    |sp |    |pc |
@ j loop init |d  |a+i|b  |n  |ic|w-1|a[i]|np0|  |  |   |0  |    |sp |    |pc |
@ j loop body |d+j|a+i|b+j|n+j|ic|jc |a[i]|m  |s |h0|h1 |0  |temp|sp |n[j]|pc |
@ subN        |d+w|   |   |n+i|  |   |    |   |s |  |   |   |temp|sp |d+i |pc |
@ ----------------------------------------------------------------------------
@
@=========================================================================

			.globl  MontgomeryProduct
MontgomeryProduct:
			@ save registers
			stmdb   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, lr}

			@ load (w, np0) from stack
			ldr     r4, [sp, #(9 * 4)]
			ldr     r7, [sp, #(10 * 4)]

			@ save local variables (d, b, n, w-1, np0, d[w])
			mov     r11, #0
			sub     r5, r4, #1
			stmdb   sp!, {r0, r2, r3, r5, r7, r11}

			@ zero d
			mov     r14, r0
zeroD:
				subs    r5, r5, #1
				str     r11, [r14], #4
				bhs     zeroD

			@ for i = 0 to w - 1
iLoop:
				@ reload (d, b, n, jc := w-1, np0)
				ldm     sp, {r0, r2, r3, r5, r7}

				@ ai := a[i]
				ldr     r6, [r1], #4

				@ preload d[0], b[0], n[0]
				ldr     r8, [r0], #4
				ldr     r12, [r2], #4
				ldr     r14, [r3], #4

				@ (h0, s) := ai*b[0] + d[0]
				mov     r9, #0
				umlal   r8, r9, r6, r12

				@ m := s*np0 mod 2^32
				mul     r7, r8, r7

				@ (h1, _) := m*n[0] + s
				mov     r10, #0
				umlal   r8, r10, r7, r14

				@ for j = 1 to w - 1
jLoop:
					@ computation of the following broken down into a few steps
					@ (h0 + h1, d[j-1]) := h0 + h1 + d[j] + ai*b[j] + m*n[j]

					@ preload d[j], b[j], n[j]
					ldr     r8, [r0], #4
					ldr     r12, [r2], #4
					ldr     r14, [r3], #4

					@ (h0, s) := h0 + d[j] + ai*b[j]
					adds    r8, r8, r9
					adc     r9, r11, #0  @ r9 := carry
					umlal   r8, r9, r6, r12

					@ (h1, s) := h1 + s + m*n[j]
					adds    r8, r8, r10
					adc     r10, r11, #0  @ r10 := carry
					umlal   r8, r10, r7, r14

					@ --jc (countdown for j loop)
					subs    r5, r5, #1

					@ d[j-1] := s
					str     r8, [r0, #-8]

					@ next j
					bne     jLoop

				@ preload d[w]
				ldr     r12, [sp, #20]

				@ (d[w], d[w-1]) := d[w] + h0 + h1
				adds    r9, r9, r10
				sbc     r10, r10, r10  @ r10 := carry - 1
				adds    r12, r12, r9
				adc     r10, r10, #1

				@ --ic (countdown for i loop)
				subs    r4, r4, #1

				@ store d[w], d[w-1]
				str     r12, [r0, #-4]
				str     r10, [sp, #20]

				@ next i
				bne     iLoop

			@ if d >= n then d := d - n
			cmp     r10, #0  @ d[w] > 0
			bhi     subtractN
			cmp     r12, r14  @ d[w-1] >= n[w-1]
			bhs     subtractN

			@ remove local variables
			add     sp, sp, #(4 * 6)

			@ restore registers and return
			ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, pc}

subtractN:
			@ carry flag has been set by the bhi/bhs that branched to here
			@ this starts the long subtraction with no initial borrow

			@ load (d, n)
			ldr     r14, [sp]
			ldr     r3, [sp, #8]

			@ d := d - n (long subtraction with carry propagation)
subLoop:
				@ s := d[i] - n[i] - not(carry)
				ldr     r8, [r14], #4
				ldr     r12, [r3], #4
				sbcs    r8, r8, r12

				@ d+i == d+n (check for end of subLoop)
				teq     r14, r0  @ without modifying carry flag

				@ d[i] := s
				str     r8, [r14, #-4]

				@ next subLoop
				bne     subLoop

			@ remove local variables
			add     sp, sp, #(4 * 6)

			@ restore registers and return
			ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, pc}
