const std = @import("std");
const testing = std.testing;

pub fn encode(source_image: *std.ArrayList(u32), width: u16, height: u16, max_color: u16) std.ArrayList(u8) {
    var buf = std.ArrayList(u8).initCapacity(std.testing.allocator, 4024) catch unreachable;

    //const allocator = testing.allocator;
    const allocator = std.heap.page_allocator;

    const header = std.fmt.allocPrint(
        allocator,
        "P6\n{d} {d}\n{d}\n",
        .{ width, height, max_color },
    ) catch unreachable;
    defer allocator.free(header);

    buf.appendSlice(header) catch unreachable;

    for (source_image.items, 1..) |si, i| {
        buf.append(@intCast(si)) catch unreachable;
        if (i % (width * 3) == 0) {
            buf.append('\n') catch unreachable;
        } else {
            buf.append(' ') catch unreachable;
        }
    }

    return buf;
}

test "encode" {
    var source_image = std.ArrayList(u32).init(testing.allocator);
    defer source_image.deinit();

    const source_image_data = .{
        0,   0, 0,   0, 0,   0,   0, 0,   0,   255, 0, 255,
        0,   0, 0,   0, 255, 128, 0, 0,   0,   0,   0, 0,
        0,   0, 0,   0, 0,   0,   0, 255, 128, 0,   0, 0,
        0,   0, 0,   0, 255, 128, 0, 0,   0,   0,   0, 0,
        255, 0, 255, 0, 0,   0,   0, 0,   0,   0,   0, 0,
    };
    source_image.appendSlice(&source_image_data) catch unreachable;

    const width = 4;
    const height = 5;
    const max_color = 255;

    const actual_image = encode(&source_image, width, height, max_color);
    defer actual_image.deinit();

    var expected_image = std.ArrayList(u8).init(testing.allocator);
    defer expected_image.deinit();

    expected_image.appendSlice(&.{
        0x50, 0x36, 0x0a,
        0x34, 0x20, 0x35,
        0x0a, 0x32, 0x35,
        0x35, 0x0a, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0xff,
        0x20, 0x00, 0x20,
        0xff, 0x0a, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0xff, 0x20,
        0x80, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x0a, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0xff, 0x20,
        0x80, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x0a, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0xff, 0x20,
        0x80, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x0a, 0xff,
        0x20, 0x00, 0x20,
        0xff, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x20, 0x00,
        0x20, 0x00, 0x20,
        0x00, 0x0a,
    }) catch unreachable;

    try testing.expectEqual(expected_image.items.len, actual_image.items.len);
    for (expected_image.items, actual_image.items, 0..) |e, a, i| {
        if (e != a) {
            std.debug.print("e != a for i: {}, e: {x}, a: {x}.\n", .{ i, e, a });
        }
        try testing.expectEqual(e, a);
    }
}
