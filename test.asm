# Test program for the ICAI-RISC-16
#
# Executes every instruction in the processor set and tests them.

.org $0x00

start:
	movi $test, %r6	# R6 will be the test function addr

	movi $0x55FF, %r1	# Initialize R1 and tests addi
	movi $0x0F0F, %r2	# R2 is a mask
	nand %r1, %r2, %r4	# Test nand op
	movi $0xFAF0, %r5	# Expected result
	jalr %r6, %r7		# Check the result

	add %r1, %r2, %r4	# Test addition
	movi $0x650E, %r5
	jalr %r6, %r7

	sub %r1, %r2, %r4	# Substraction
	movi $0x46F0, %r5
	jalr %r6, %r7

	sub %r2, %r1, %r4	# Signed operands
	movi $0xB910, %r5
	jalr %r6, %r7

	srl %r2, %r4
	movi $0x0787, %r5
	jalr %r6, %r7

	sra %r2, %r4
	movi $0x0787, %r5
	jalr %r6, %r7

	movi $0xFFF0, %r3	# Signed shifts
	srl %r3, %r4
	movi $0x7FF8, %r5
	jalr %r6, %r7

	sra %r3, %r4
	movi $0xFFF8, %r5
	jalr %r6, %r7

	sll %r2, %r4		# Left shift
	movi $0x1E1E, %r5
	jalr %r6, %r7

	# Operations with overflow
	movi $0x7FFF, %r1
	addi %r1, $1, %r4
	sltu %r1, %r2, %r4	# Positive numbers comparison
	addi %r0, $0, %r5
	jalr %r6, %r7

	sltu %r2, %r1, %r4
	addi %r0, $1, %r5
	jalr %r6, %r7

	sltu %r1, %r1, %r4
	addi %r0, $0, %r5
	jalr %r6, %r7

	# Test memory in a loop by reading and writing peripherials
loop:
	movi $0x8000, %r1	# Mem addr
	lw   %r1, $0, %r2	# Read
	sw   %r1, $0, %r2	# Store
	beq  %r0, %r0, $loop

test:	# Test function
	# Tests for r4 = r5. If not loop. If yes return.
	beq  %r5, %r4, $return
fail:	beq  %r0, %r0, $fail
return:	jalr %r7, %r0
