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

    const flow_domain_length: f32 = 10;
    const flow_domain_height: f32 = 10;

    // TODO: seems like there should be something to get the centroid to automatically place it
    const body = Circle.create(Point{ .x = flow_demain_length / 2, .y = flow_domain_height / 2 }, 3);

    const shortest_edge = body.shortestEdge();
    const characteristic_length = body.characteristicLength();
    const longest_edge_char_len_ratio = 0.1;
    const char_len = characteristic_length * std.math.pi / 3; // make base element grid dims weird to avoid intersecting points
    const lengest_edge = char_len * longest_edge_char_len_ratio;

    const tol_shortest_edge_ratio = 0.01;
    const tolerance = shortest_edge * tol_shortest_edge_ratio;

    var points = std.AutoHashMap(Point, [10]?Edge).init(allocator);
    defer points.deinit();

    var edges = std.AutoHashMap(Edge, [2]?usize).init(allocator);
    defer edges.deinit();

    var elements = std.ArrayList(Element2D).init(allocator);
    defer elements.deinit();

    var x = 0;
    var y = 0;
    while (x < flow_dimain_length + shortest_edge) : (x += longest_edge) {
        while (y < flow_dimain_height + shortest_edge) : (y += longest_edge) {
            points.put(Point{ .x= x, .y = y}, .{null} ** 2);
        }
    }

    const image = makeImageRGB(points, flow_domain_length, flow_domain_height, 200, 200);
    defer image.deinit();
    
    ppm.encode(image, 200, 200, 255) std.ArrayList(u8) {

    std.debug.print("debug: {d}\n", .{shortest_edge});
}

test "run" {
    //    try testing.expect(add(3, 7) == 10);
    run();
}
