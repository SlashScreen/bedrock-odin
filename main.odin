package main

import "core:mem"
import "core:fmt"
import "core:slice"


Byte :: u8
Double :: u16
DataSlice :: []Byte



debug_mode: bool = true

Mode :: enum {
	Immediate,
	Wide,
	ReturnStack,
}

Op :: enum {
	HLT = 0x00,
	PSH = 0x01,
	POP = 0x02,
	CPY = 0x03,
	DUP = 0x04,
	OVR = 0x05,
	SWP = 0x06,
	ROT = 0x07,
	JMP = 0x08,
	JMS = 0x09,
	JCN = 0x0A,
	JCS = 0x0B,
	LDA = 0x0C,
	STA = 0x0D,
	LDD = 0x0E,
	STD = 0x0F,
	ADD = 0x10,
	SUB = 0x11,
	INC = 0x12,
	DEC = 0x13,
	LTH = 0x14,
	GTH = 0x15,
	EQU = 0x16,
	NQK = 0x17,
	SHL = 0x18,
	SHR = 0x19,
	ROL = 0x1A,
	ROR = 0x1B,
	IOR = 0x1C,
	XOR = 0x1D,
	AND = 0x1E,
	NOT = 0x1F,
}

OpInfo :: struct {
	mode : bit_set[Mode; u8],
	op : Op
}

// UTILS

error_print :: proc(msg: string) {
	if !debug_mode {
		return
	}
	fmt.eprintfln("ERROR at address %X: %s", msg)
}

op_destinations :: proc(oi : ^OpInfo) -> (^Stack, ^Stack, uint, bool) {
	stack_1 := &ret_stack if Mode.ReturnStack in oi.mode else &working_stack
	stack_2 := &working_stack if Mode.ReturnStack in oi.mode else &ret_stack
	width := uint(2 if Mode.Wide in oi.mode else 1)
	immediate := Mode.Immediate in oi.mode

	return stack_1, stack_2, width, immediate
}

// MAIN

main :: proc() {
	arena := mem.Arena{}
	context.allocator = mem.arena_allocator(&arena)

	initialize_device_bus()

	x : Double = 2
	x_slice := transmute([2]Byte)x
	fmt.println("pushing")
	stack_push(&working_stack, x_slice[:])

	print_stack(&working_stack)

	y_slice := [2]Byte{}
	fmt.println("popping")
	stack_pop(&working_stack, y_slice[:])

	print_stack(&working_stack)
	fmt.printfln("final value: %v", slice.to_type(y_slice[:], Double))
}
