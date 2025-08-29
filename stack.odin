package main

import "core:slice"

STACK_SIZE :: 255
RETURN_STACK_SIZE :: 255

stack : [STACK_SIZE]Byte
stack_pointer : Byte = 0

return_stack : [RETURN_STACK_SIZE]Byte
return_stack_pointer : Byte = 0

push_byte :: proc(value: Byte, to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    if ptr^ >= STACK_SIZE {
        error_print("Stack overflow")
        return
    }
    to_stack[ptr^] = value
    ptr^ += 1
}

push_double :: proc(value: Double, to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    if ptr^ + 1 >= STACK_SIZE {
        error_print("Stack overflow (double)")
        return
    }
    dbl_slice := transmute([2]Byte)value
    copy(to_stack[ptr^:ptr^ + 1], dbl_slice[:])
    ptr^ += 2
}

pop_byte :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) -> Byte {
    if ptr^ == 0 {
        error_print("Stack underflow")
        return 0
    }
    defer ptr^ -= 1
    return to_stack[ptr^]
}

pop_double :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) -> Double {
    if ptr^ < 2 {
        error_print("Stack underflow (double)")
        return 0
    }
    defer ptr^ -= 2
    dbl_slice := to_stack[ptr^:ptr^ + 1]
    return slice.to_type(dbl_slice, Double)
}

dup_byte :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    x := pop_byte(to_stack, ptr)
    push_byte(x, to_stack, ptr)
    push_byte(x, to_stack, ptr)
}

dup_double :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    x := pop_double(to_stack, ptr)
    push_double(x, to_stack, ptr)
    push_double(x, to_stack, ptr)
}

ovr_byte :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    y := pop_byte(to_stack, ptr)
    x := pop_byte(to_stack, ptr)

    push_byte(x, to_stack, ptr)
    push_byte(y, to_stack, ptr)
    push_byte(x, to_stack, ptr)
}

ovr_double :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    y := pop_double(to_stack, ptr)
    x := pop_double(to_stack, ptr)

    push_double(x, to_stack, ptr)
    push_double(y, to_stack, ptr)
    push_double(x, to_stack, ptr)
}

swp_byte :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    y := pop_byte(to_stack, ptr)
    x := pop_byte(to_stack, ptr)

    push_byte(y, to_stack, ptr)
    push_byte(x, to_stack, ptr)
}

swp_double :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    y := pop_double(to_stack, ptr)
    x := pop_double(to_stack, ptr)

    push_double(x, to_stack, ptr)
    push_double(y, to_stack, ptr)
}

rot_byte :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    z := pop_byte(to_stack, ptr)
    y := pop_byte(to_stack, ptr)
    x := pop_byte(to_stack, ptr)

    push_byte(y, to_stack, ptr)
    push_byte(z, to_stack, ptr)
    push_byte(x, to_stack, ptr)
}

rot_double :: proc(to_stack : ^[STACK_SIZE]Byte, ptr: ^u8) {
    z := pop_double(to_stack, ptr)
    y := pop_double(to_stack, ptr)
    x := pop_double(to_stack, ptr)

    push_double(y, to_stack, ptr)
    push_double(z, to_stack, ptr)
    push_double(x, to_stack, ptr)
}