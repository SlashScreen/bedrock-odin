package main

import "core:mem"
import "core:fmt"
import "core:slice"

PROGRAM_SIZE :: 0xFFFF
STACK_SIZE :: 0xFF
BEDROCK_IDENTIFIER :: [10]Byte{0xE8, 0x00, 0x18, 0x42, 0x45, 0x44, 0x52, 0x4F, 0x43, 0x4B}

Stack :: struct {
    pointer : uint,
    data : [STACK_SIZE]Byte,
    name : string,
}

program: [PROGRAM_SIZE]Byte
program_counter: Double

working_stack := Stack{0, [STACK_SIZE]Byte{}, "working stack"}
ret_stack := Stack{0, [STACK_SIZE]Byte{}, "return stack"}

running := true

// UTILS

print_stack :: proc(stack : ^Stack) {
    fmt.println(stack^.name)
    fmt.printfln("stack pointer: %d", stack^.pointer)
	for i := int(stack^.pointer - 1); i >= 0; i-=1 {
        fmt.printfln("%X", stack^.data[i])
    }
    fmt.println("---")
}

// MEMORY

rom_read :: proc(address : Double, to_value : []Byte) {
    width := len(to_value)
    copy(to_value[:], program[program_counter : program_counter + Double(width)])
}

rom_write :: proc(address : Double, value: []Byte) {
    width := len(value)
    copy(program[program_counter : program_counter + Double(width)], value[:])
}

immediate_read :: proc(to_value : []Byte) {
    width := len(to_value)
    rom_read(program_counter, to_value)
    program_counter += Double(width)
}

// STACK 

stack_push :: proc(stack : ^Stack, value : []Byte) {
    copy(stack^.data[stack^.pointer : stack^.pointer + len(value)], value[:])
    stack^.pointer += len(value)
}

stack_pop :: proc(stack : ^Stack, to_value : []Byte) {
    copy(to_value[:], stack^.data[stack^.pointer - len(to_value) : stack^.pointer])
    stack^.pointer -= len(to_value)
}

// OPS

hlt :: proc(_ : ^OpInfo) {
    running = false
}

jmp :: proc(oi : ^OpInfo) {
    stack1, _, _, immediate := op_destinations(oi)

    x := [2]Byte{}
    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }

    program_counter = slice.to_type(x[:], Double)
}

jms :: proc(oi : ^OpInfo) {
    stack1, stack2, _, immediate := op_destinations(oi)

    x := [2]Byte{}
    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }

    b := transmute([2]Byte)program_counter
    stack_push(stack2, b[:])
    program_counter = slice.to_type(x[:], Double)
}

jcn :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    x := [2]Byte{}
    t := make([]Byte, width)
    defer delete(t)

    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }
    stack_pop(stack1, t[:])

    if slice.to_type(t[:], Double) != 0 {
        program_counter = slice.to_type(x[:], Double)
    }
}

jcs :: proc(oi : ^OpInfo) {
    stack1, stack2, width, immediate := op_destinations(oi)

    x := [2]Byte{}
    t := make([]Byte, width)
    defer delete(t)

    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }
    stack_pop(stack1, t[:])

    if slice.to_type(t[:], Double) != 0 {
        b := transmute([2]Byte)program_counter
        stack_push(stack2, b[:])
        program_counter = slice.to_type(x[:], Double)
    }
}

lda :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    x := [2]Byte{}
    v := make([]Byte, width)
    defer delete(v)

    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }

    rom_read(slice.to_type(x[:], Double), v[:])
    stack_push(stack1, v[:])
}

sta :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    x := [2]Byte{}
    v := make([]Byte, width)
    defer delete(v)

    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }
    stack_pop(stack1, v[:])

    rom_write(slice.to_type(x[:], Double), v[:])
}

// LOAD ROM

load_rom :: proc() {
    // TODO
    //remember header https://benbridle.com/projects/bedrock/specification/metadata-specification.html
}

// LOOP 

init :: proc() {
    arena := mem.Arena{}
	context.allocator = mem.arena_allocator(&arena)

	initialize_device_bus()

    load_rom()

    for running == true && program_counter < PROGRAM_SIZE {
        op := [1]Byte{}
        rom_read(program_counter, op[:])
        info := parse_byte_to_opinfo(op[0])
        
        op_procs[info.op](&info)

        program_counter += 1
    }
}
