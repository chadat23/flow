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

    const body = Circle.create(Point{ .x = 0.5, .y = 0.25 }, 3);

    const shortest_edge = body.shortestEdge();

    const longest_edge_char_len_ratio = 0.1;
    const characteristic_length = body.characteristicLength();
    const char_len = characteristic_length * std.math.pi / 3; // make base element grid dims wird to avoid intersecting points
    const lengest_edge = char_len * longest_edge_char_len_ratio;

    var points = std.AutoHashMap(Point, [2]?Edge).init(allocator);
    defer points.deinit();

    var edges = std.AutoHashMap(Edge, [2]?usize).init(allocator);
    defer edges.deinit();

    var elements = std.ArrayList(Element2D).init(allocator);
    defer elements.deinit();


    std.debug.print("debug: {d}\n", .{shortest_edge});
}

test "run" {
    //    try testing.expect(add(3, 7) == 10);
    run();
}
