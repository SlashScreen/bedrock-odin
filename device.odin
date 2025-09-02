package main

import "core:slice"
PORTS_PER_SLOT :: 16
SLOT_COUNT :: 16

Device :: struct {
    ports : map[uint]Port
}

PortFnOperation :: enum {
    NEXT, 
    STOP,
}

Port :: struct {
    write_proc : proc(Byte),
    read_proc : proc(^Stack)  -> PortFnOperation,
}

device_bus : [SLOT_COUNT * PORTS_PER_SLOT]Port

port_write_disconnected :: proc(_ : Byte) {}

port_read_disconnected :: proc(dest_stack : ^Stack) -> PortFnOperation {
    x := [1]Byte{}
    stack_push(dest_stack, x[:])
    return .STOP
}


initialize_device_bus :: proc() {
    for i in 0 ..= (SLOT_COUNT * PORTS_PER_SLOT) {
        device_bus[i] = Port {
            write_proc = port_write_disconnected,
            read_proc = port_read_disconnected,
        }
    }
}

ldd :: proc(oi : ^OpInfo) {
    stack1, _, _, immediate := op_destinations(oi)

    p := [1]Byte{}
    
    if immediate {
        immediate_read(p[:])
    } else {
        stack_pop(stack1, p[:])
    }

    port_number := slice.to_type(p[:], Byte)

    next := PortFnOperation.NEXT
    i := 0
    for next == PortFnOperation.NEXT {
        port := device_bus[port_number + Byte(i)]
        i += 1
        next = port.read_proc(stack1) 
    }
}

std :: proc(oi : ^OpInfo) {
    stack1, _, width, immediate := op_destinations(oi)

    p := [1]Byte{}
    
    if immediate {
        immediate_read(p[:])
    } else {
        stack_pop(stack1, p[:])
    }

    port_number := slice.to_type(p[:], Byte)

    v := make([]Byte, width)
    defer delete(v)

    stack_pop(stack1, v[:])

    for i : uint = 0; i < width; i+=1 {
        port := device_bus[port_number + Byte(i)]
        port.write_proc(v[i])
    }
}


// EXTERNAL DEVICES

load_device :: proc(device : ^Device, slot : uint) {
    for pn, port in device^.ports {
        device_bus[(PORTS_PER_SLOT * slot) + pn] = port
    }
}
