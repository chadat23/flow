//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const geometry = @import("geometry.zig");
const Point = geometry.Point;
const Edge = geometry.Edge;
const Element2D = geometry.Element2D;

const Circle = @import("round.zig").Circle;

//pub fn run(file_path: []u8) void {
pub fn run() void {
    const allocator = std.testing.allocator;
    var edges = std.AutoHashMap(Edge, [2]?usize).init(allocator);
    defer edges.deinit();

    var elements = std.ArrayList(Element2D).init(allocator);
    defer elements.deinit();

    const body = Circle{ .x = 0.5, .y = 0.25, .r = 3 };

    const shortest_edge = body.shortestEdge();

    std.debug.print("debug: {d}\n", .{shortest_edge});
}

test "run" {
    //    try testing.expect(add(3, 7) == 10);
    run();
}
