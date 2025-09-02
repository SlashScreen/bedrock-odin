package main

psh :: proc(oi : ^OpInfo) {
    stack1, stack2, width, immediate := op_destinations(oi)

    x := make([]Byte, width)
    defer delete(x)
    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack2, x[:])
    }

    stack_push(stack2, x[:])
}

pop :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    x := make([]Byte, width)
    defer delete(x)
    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }
}

cpy :: proc(oi : ^OpInfo) {
    stack1, stack2, width, immediate := op_destinations(oi)

    x := make([]Byte, width)
    defer delete(x)
    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack2, x[:])
    }

    stack_push(stack1, x[:])
    stack_push(stack2, x[:])
}

dup :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    x := make([]Byte, width)
    defer delete(x)
    if immediate {
        immediate_read(x[:])
    } else {
        stack_pop(stack1, x[:])
    }

    stack_push(stack1, x[:])
    stack_push(stack1, x[:])
}

ovr :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    y := make([]Byte, width)
    defer delete(y)
    x := make([]Byte, width)
    defer delete(x)

    if immediate {
        immediate_read(y[:])
    } else {
        stack_pop(stack1, y[:])
    }
    stack_pop(stack1, x[:])

    stack_push(stack1, x[:])
    stack_push(stack1, y[:])
    stack_push(stack1, x[:])
}

swp :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    y := make([]Byte, width)
    defer delete(y)
    x := make([]Byte, width)
    defer delete(x)

    if immediate {
        immediate_read(y[:])
    } else {
        stack_pop(stack1, y[:])
    }
    stack_pop(stack1, x[:])

    stack_push(stack1, y[:])
    stack_push(stack1, x[:])
}

rot :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    z := make([]Byte, width)
    defer delete(z)
    y := make([]Byte, width)
    defer delete(y)
    x := make([]Byte, width)
    defer delete(x)

    if immediate {
        immediate_read(z[:])
    } else {
        stack_pop(stack1, z[:])
    }
    stack_pop(stack1, y[:])
    stack_pop(stack1, x[:])

    stack_push(stack1, y[:])
    stack_push(stack1, z[:])
    stack_push(stack1, x[:])
}
