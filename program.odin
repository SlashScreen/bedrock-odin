package main

import "core:slice"

PROGRAM_SIZE :: 65535

// READ

read_byte :: proc() -> Byte {
    if program_counter >= PROGRAM_SIZE {
        // Handle out-of-bounds access
        error_print("Attempted to read byte beyond program bounds")
        return 0
    }
    defer program_counter += 1
    return program[program_counter]
}

read_double :: proc() -> Double {
    if program_counter + 1 >= PROGRAM_SIZE {
        // Handle out-of-bounds access
        error_print("Attempted to read double beyond program bounds")
        return 0
    }
    defer program_counter += 2
    return slice.to_type(program[program_counter:program_counter+1], Double)
}

// WRITE

write_byte :: proc(value: Byte, address: Double) {
    if address >= PROGRAM_SIZE {
        // Handle out-of-bounds access
        error_print("Attempted to write byte beyond program bounds")
        return
    }
    program[address] = value
}

write_double :: proc(value: Double, address: Double) {
    if address + 1 >= PROGRAM_SIZE {
        // Handle out-of-bounds access
        error_print("Attempted to write double beyond program bounds")
        return
    }
    dbl_slice := transmute([2]Byte)value
    copy(program[address:address + 1], dbl_slice[:])
}


// ADDRESS MANIPULATION

jmp :: proc() {
    program_counter = pop_double(&stack, &stack_pointer)
}

jms :: proc() {
    a := pop_double(&stack, &stack_pointer)
    b := program_counter

    push_double(b, &return_stack, &return_stack_pointer)

    program_counter = a
}

jcn :: proc() {
    a := pop_double(&stack, &stack_pointer)
    t := pop_double(&stack, &stack_pointer)

    if t == 0 {
        program_counter = a
    }
}

jcs :: proc() {
    a := pop_double(&stack, &stack_pointer)
    t := pop_double(&stack, &stack_pointer)

    if t == 0 {
        b := program_counter
        push_double(b, &return_stack, &return_stack_pointer)

        program_counter = a
    }
}

// LOADING

lda :: proc() {
	a := pop_double(&stack, &stack_pointer)
	v := program[a]
	push_byte(v, &stack, &stack_pointer)
}

sta :: proc() {
	a := pop_double(&stack, &stack_pointer)
	v := pop_byte(&stack, &stack_pointer)
	program[a] = v
}
