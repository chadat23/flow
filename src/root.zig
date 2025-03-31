//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const geometry = @import("geometry.zig");
const Point = geometry.Point;
const Edge = geometry.Edge;
const Element2D = geometry.Element2D;
const Array = geometry.Array;

const Circle = @import("round.zig").Circle;

const utils = @import("utils.zig");

//pub fn run(file_path: []u8) void {
pub fn run() void {
    const allocator = std.testing.allocator;

    var points = std.AutoHashMap(Point, [6]?Array).init(allocator);
    defer points.deinit();

    var edges = std.AutoHashMap(Edge, [2]?Array).init(allocator);
    defer edges.deinit();

    var elements = std.ArrayList(Element2D).init(allocator);
    defer elements.deinit();

    const body = Circle{ .x = 0.5, .y = 0.25, .r = 3 };

    mesh(body, &points, &edges, &elements);
}

fn mesh(
    body: anytype,
    points: *std.AutoHashMap(Point, Array),
    edges: *std.AutoHashMap(Edge, Array),
    elements: *std.AutoList(Element2D),
) void {
    //const shortest_edge = body.shortestEdge();
    var bi = body.iterator();
    const first_point = bi.nextPoint();
    points.put(first_point, Array.create());
    var last_point = first_point;
    for (bi.nextPoint()) |point| {
        const third_point = point_finder(last_point, point, body);
        const body_edge = Edge{
            .p0 = last_point,
            .p1 = point,
            .is_on_body = true,
        };
        const edge_0 = Edge{
            .p0 = point,
            .p1 = third_point,
        };
        const edge_1 = Edge{
            .p0 = last_point,
            .p1 = third_point,
        };
        const element = Element2D{
            .e0 = body_edge,
            .e1 = edge_0,
            .e2 = edge_1,
        };
        points.put(point, Array.create());
        points.put(third_point, Array.create());
        edges.put(body_edge, Array.create());
        points.get(last_point).?.append(edges.len);
        points.get(point).?.append(edges.len);
        edges.put(edge_0, Array.create());
        points.get(point).?.append(edges.len);
        points.get(third_point).?.append(edges.len);
        edges.put(edge_1, Array.create());
        points.get(third_point).?.append(edges.len);
        points.get(last_point).?.append(edges.len);
        elements.append(element);
        edges.get(body_edge).?.append(elements.len);
        edges.get(edge_0).?.append(elements.len);
        edges.get(edge_0).?.append(elements.len);
        last_point = point;
    }
}

fn point_finder(p0: Point, p1: Point, body: Circle) Point {
    const midpoint = utils.midpoint(p0, p1);
    const dist = utils.distPoints(p0, p1);
    const slope = utils.slopeRad(p0, p1);
    var perp_slope = slope + std.math.pi / 2;
    var proposed_point = Point{
        .x = midpoint.x + dist * @cos(perp_slope),
        .y = midpoint.y + dist * @sin(perp_slope),
    };
    if (body.isInside(proposed_point)) {
        perp_slope += std.math.pi;
        proposed_point = Point{
            .x = midpoint.x + dist * @cos(perp_slope),
            .y = midpoint.y + dist * @sin(perp_slope),
        };
    }
    return proposed_point;
}

test "run" {
    //    try testing.expect(add(3, 7) == 10);
    run();
}
