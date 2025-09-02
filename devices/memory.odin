package devices

import bedrock "../"

Page :: [0xFF]u8

Head :: struct {
    page_offset : u16,
    address_offset : u16
}

pages : [dynamic]Page
head1 : Head
head2 : Head

memory_device := bedrock.Device {
    ports = map[uint]bedrock.Port {
        
    }
}

// HEAD OPS

head_read :: proc(h : ^Head) -> u8 {
    defer h^.address_offset += 1
    return pages[h^.page_offset][h^.address_offset]
}

head_write :: proc( h : ^Head, value : u8) {
    pages[h^.page_offset][h^.address_offset] = value
    h^.address_offset += 1
}

// INTERNAL

get_page_count :: proc() -> uint {
    return len(pages)
}

set_page_count :: proc(count: uint) {
    resize_dynamic_array(&pages, count)
}
