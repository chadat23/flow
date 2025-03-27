const std = @import("std");

pub fn readString(file_path: []u8) std.ArrayList(u8) {
    return readInts(file_path, u8);
}

pub fn readInts(file_path: []u8, T: anytype) std.ArrayList(T) {
    comptime {
        //const type_info = @typeInfo(@TypeOf(number));
        const type_info = @typeInfo(T);
        if (type_info != .int) {
            @compileError("input must be an integer type to read from file");
        }
    }

    const allocator = std.testing.allocator;

    // Open file for reading
    const file = std.fs.cwd().openFile(file_path, .{}) catch unreachable;
    defer file.close();

    // Get the file size.
    const file_size = file.getEndPos() catch unreachable;
    const numb_ints = @divExact(file_size, @sizeOf(T));

    var reader = file.reader();

    // Create array list with the correct capacity
    var array = std.ArrayList(T).initCapacity(allocator, numb_ints) catch unreachable;
    //errdefer array.deinit();

    //Read all integers
    for (0..numb_ints) |_| {
        const value = reader.readInt(T, std.builtin.Endian.big) catch unreachable;
        array.append(value) catch unreachable;
    }

    return array;
}

pub fn write(file_path: []u8, buff: *const std.ArrayList(u8)) void {
    var file = std.fs.cwd().createFile(file_path, .{ .read = false }) catch unreachable;
    defer file.close();

    file.writeAll(buff.items) catch unreachable;
}
