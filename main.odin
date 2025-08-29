package main

import "core:fmt"
import "core:slice"


Byte :: u8
Double :: u16

program: [PROGRAM_SIZE]Byte
program_counter: Double = 0

running := true

debug_mode: bool = true

Ops :: enum {
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

// UTILS

error_print :: proc(msg: string) {
	if !debug_mode {
		return
	}
	fmt.eprintfln("ERROR at address %X: %s", msg)
}

main :: proc() {

}
