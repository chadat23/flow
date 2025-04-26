//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const geometry = @import("geometry.zig");
const Point = geometry.Point;
const PointInfo = geometry.PointInfo;
const Edge = geometry.Edge;
const Element2D = geometry.Element2D;
const Location = geometry.Location;

const Circle = @import("round.zig").Circle;
const makeImageRGB = @import("image.zig").makeImageRGB;
const ppm = @import("ppm.zig");
const fs = @import("fs.zig");
const mesh = @import("mesh.zig");

//pub fn run(file_path: []u8) void {
pub fn run() void {
    const allocator = std.testing.allocator;

    const flow_domain_length: u16 = 30_000;
    const flow_domain_height: u16 = 30_000;

    // TODO: seems like there should be something to get the centroid to automatically place it
    const body = Circle.create(Point{
        .x = flow_domain_length / 2,
        .y = flow_domain_height / 2,
    }, 5_000);

    const shortest_edge: u16 = body.shortestEdge();
    const characteristic_length = body.characteristicLength();
    //const longest_edge_char_len_ratio = 6;
    const longest_edge_char_len_ratio = 4;
    // make base element grid dims weird to avoid intersecting points
    const char_len: u16 = @intFromFloat(@as(f64, @floatFromInt(characteristic_length)) * std.math.pi / 3);
    const longest_edge: u16 = char_len / longest_edge_char_len_ratio;
    std.debug.print("longest_edge: {}\n", .{longest_edge});

    //var points = std.AutoHashMap(Point, [2]?Edge).init(allocator);
    var points = std.AutoHashMap(Point, PointInfo).init(allocator);
    defer points.deinit();
    var edges = std.AutoHashMap(Edge, [2]?usize).init(allocator);
    defer edges.deinit();
    var elements = std.ArrayList(Element2D).init(allocator);
    defer elements.deinit();

    //const fdomain_length = (flow_domain_length + longest_edge - 1) / longest_edge * longest_edge;
    //const domain_height = (flow_domain_height + longest_edge - 1) / longest_edge * longest_edge;
    const domain_length = (flow_domain_length) / longest_edge * longest_edge;
    const domain_height = (flow_domain_height) / longest_edge * longest_edge;
    mesh.addPoints(
        &body,
        &points,
        char_len,
        domain_length,
        domain_height,
        longest_edge,
        shortest_edge,
    );

    //mesh.addEdges(&points, &edges, allocator);

    const image_width = 1000;
    const image_height = 1000;
    const image = makeImageRGB(points, edges, domain_length, domain_height, image_width, image_height);
    defer image.deinit();
    const ppm_image = ppm.encode(&image, image_width, image_height, 255);
    defer ppm_image.deinit();
    const path: []const u8 = "test_image.ppm";
    fs.write(path, ppm_image);
}

test "run" {
    //std.debug.print("x: {}, y: {}\n", .{ x, y });
    //    try testing.expect(add(3, 7) == 10);
    run();
}
