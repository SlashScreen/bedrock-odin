package main

import "core:math/bits"
import "base:intrinsics"
import "core:slice"

// UTIL

binary_op :: proc(oi : ^OpInfo, byte_op : proc(a, b : Byte) -> Byte, double_op : proc(a, b : Double) -> Double) {
    stack1, _, width, immediate := op_destinations(oi)
    
    x := make([]Byte, width)
    defer delete(x)
    y := make([]Byte, width)
    defer delete(y)

    if immediate {
        immediate_read(y[:])
    } else {
        stack_pop(stack1, y[:])
    }
    stack_pop(stack1, x[:])

    switch width {
        case 1:
            a := slice.to_type(x[:], Byte)
            b := slice.to_type(y[:], Byte)
            r := [1]Byte{byte_op(a, b)}
            stack_push(stack1, r[:])
        case 2:
            a := slice.to_type(x[:], Double)
            b := slice.to_type(y[:], Double)
            r := transmute([2]Byte)double_op(a, b)
            stack_push(stack1, r[:])
    }
}

compare :: proc(oi : ^OpInfo, byte_op : proc(a, b : Byte) -> bool, double_op : proc(a, b : Double) -> bool, keep : bool) {
    stack1, _, width, immediate := op_destinations(oi)

    x := make([]Byte, width)
    defer delete(x)
    y := make([]Byte, width)
    defer delete(y)

    if immediate {
        immediate_read(y[:])
    } else {
        stack_pop(stack1, y[:])
    }
    stack_pop(stack1, x[:])

    if keep {
        stack_push(stack1, x[:])
        stack_push(stack1, y[:])
    }

    res : Byte = 0x00 
    switch width {
        case 1:
            a := slice.to_type(x[:], Byte)
            b := slice.to_type(y[:], Byte)
            if byte_op(a, b) {res = 0xFF}
        case 2:
            a := slice.to_type(x[:], Double)
            b := slice.to_type(y[:], Double)
            if double_op(a, b) {res = 0xFF}
    }
    res_slice := [1]Byte{res}
    stack_push(stack1, res_slice[:])
}

unary_op :: proc(oi : ^OpInfo, byte_op : proc(a: Byte) -> Byte, double_op : proc(b : Double) -> Double) {
    stack1, _, width, immediate := op_destinations(oi)

    x := make([]Byte, width)
    defer delete(x)

    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }

    switch width {
        case 1:
            a := slice.to_type(x[:], Byte)
            r := [1]Byte{byte_op(a)}
            stack_push(stack1, r[:])
        case 2:
            a := slice.to_type(x[:], Double)
            r := transmute([2]Byte)double_op(a)
            stack_push(stack1, r[:])
    }
}

// ARITHMETIC

add :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a + b
    }

    binary_op(oi, op, op)
}

sub :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a - b
    }

    binary_op(oi, op, op)
}

// INC / DEC

inc :: proc(oi : ^OpInfo) {
    op :: proc(a : $T) -> T where intrinsics.type_is_integer(T) {
        return a + 1
    }

    unary_op(oi, op, op)
}

dec :: proc(oi : ^OpInfo) {
    op :: proc(a : $T) -> T where intrinsics.type_is_integer(T) {
        return a - 1
    }

    unary_op(oi, op, op)
}

// COMPARISON

lth :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> bool where intrinsics.type_is_integer(T) {
        return a < b
    }

    compare(oi, op, op, false)
}

gth :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> bool where intrinsics.type_is_integer(T) {
        return a > b
    }

    compare(oi, op, op, false)
}

equ :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> bool where intrinsics.type_is_integer(T) {
        return a == b
    }

    compare(oi, op, op, false)
}

nqk :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> bool where intrinsics.type_is_integer(T) {
        return a != b
    }

    compare(oi, op, op, true)
}

// BITWISE

shl :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a << b
    }

    binary_op(oi, op, op)
}

shr :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a >> b
    }

    binary_op(oi, op, op)
}

rol :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return bits.rotate_left(a, b)
    }

    binary_op(oi, op, op)
}

ror :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return bits.rotate_right(a, b)
    }

    binary_op(oi, op, op)
}

ior :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a | b
    }

    binary_op(oi, op, op)
}

xor :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a ~ b
    }

    binary_op(oi, op, op)
}

and :: proc(oi : ^OpInfo) {
    op :: proc(a, b : $T) -> T where intrinsics.type_is_integer(T) {
        return a & b
    }

    binary_op(oi, op, op)
}

not :: proc(oi : ^OpInfo) {
    op :: proc(a : $T) -> T where intrinsics.type_is_integer(T) {
        return ~a
    }

    unary_op(oi, op, op)
}
