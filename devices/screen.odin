package devices

Color :: u16 // 4 x u4
Pixel :: u8

palette : [16]Color
cursor : [2]uint
size : [2]uint
sprite_buffer : [16]u8 // pointers to memory
foreground : []Pixel
background : []Pixel