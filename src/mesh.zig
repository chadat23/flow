const std = @import("std");
const Circle = @import("round.zig").Circle;
const geometry = @import("geometry.zig");
const Edge = geometry.Edge;
const Point = geometry.Point;
const Location = geometry.Location;
const utils = @import("utils.zig");
const position = @import("position.zig");
const Position = position.Position;

pub fn addEdges(
    points: *std.AutoHashMap(Point, [2]?Edge),
    edges: *std.AutoHashMap(Edge, [2]?usize),
    allocator: std.mem.Allocator,
) void {
    var unused_points = std.AutoHashMap(Point, void).init(allocator);
    defer unused_points.deinit();
    var point_iter = points.iterator();
    while (point_iter.next()) |entry| {
        unused_points.put(entry.key_ptr.*, {}) catch unreachable;
    }
    point_iter = points.iterator();
    while (point_iter.next()) |p| {
        const point = p.key_ptr.*;
        switch (point.location) {
            .corner => {
                _ = unused_points.remove(point);
                var closest: f64 = @floatFromInt(std.math.maxInt(u16) - 1);
                var closest_point = point;
                var second_closest: f64 = @floatFromInt(std.math.maxInt(u16));
                var second_closest_point = point;

                var upoint_iter = unused_points.iterator();
                while (upoint_iter.next()) |up| {
                    const test_point = up.key_ptr.*;
                    const dist = utils.distPoints(f64, point, test_point);
                    if (dist < closest) {
                        second_closest = closest;
                        second_closest_point = closest_point;
                        closest = dist;
                        closest_point = test_point;
                    } else if (dist < second_closest) {
                        second_closest = dist;
                        second_closest_point = test_point;
                    }
                }
                //std.debug.print("### dists closest: {}, second_closest {}.\n", .{ closest, second_closest });

                p.value_ptr.*[0] = Edge{ .p0 = point, .p1 = closest_point };
                p.value_ptr.*[1] = Edge{ .p0 = point, .p1 = second_closest_point };
                edges.put(Edge{ .p0 = point, .p1 = closest_point }, .{null} ** 2) catch unreachable;
                edges.put(Edge{ .p0 = point, .p1 = second_closest_point }, .{null} ** 2) catch unreachable;
            },
            .perimeter => {},
            .bulk => {},
            .body => {},
        }
    }
}

pub fn addPoints(
    points: *std.AutoHashMap(Point, [2]?Edge),
    body: *const Circle,
    x: u16,
    y: u16,
    longest_edge: u16,
    shortest_edge: u16,
    char_len: u16,
    domain_width: u16,
    domain_height: u16,
) void {
    const positions: [4]Position = .{
        body.getPositionXY(x, y),
        body.getPositionXY(x + longest_edge, y),
        body.getPositionXY(x + longest_edge, y + longest_edge),
        body.getPositionXY(x, y + longest_edge),
    };

    // TODO: refine this, sets the minimum size of the element grid
    const max_allow_divs: u16 = longest_edge / shortest_edge;
    var divisions: [4]?u16 = .{null} ** 4;
    for (positions, 0..) |p, i| {
        switch (p) {
            .Inside => {
                divisions[i] = null;
            },
            .Outside => {
                divisions[i] = char_len / p.Outside + 1;
            },
            else => unreachable,
        }
    }
    var is_entirely_inside = true;
    for (divisions) |division| {
        if (division) |_| {
            is_entirely_inside = false;
        }
    }
    if (is_entirely_inside) return {};

    var steps: u16 = std.math.maxInt(u16);
    //var steps: u16 = 1;
    for (divisions) |division| {
        if (division) |d| {
            if (d < steps) {
                steps = if (d < max_allow_divs) d else max_allow_divs;
            }
        }
    }

    // TODO: here's where the reference point for what sets the local mesh size is set
    const step_size: u16 = longest_edge / steps;
    for (0..steps) |i| {
        for (0..steps) |j| {
            const this_x = x + i * step_size;
            const this_y = y + j * step_size;
            const this_position = body.getPositionXY(
                @intCast(this_x),
                @intCast(this_y),
            );
            if (this_position == .Outside) {
                const location: Location = if (this_x == 0 or this_x > domain_width)
                    if (this_y == 0 or this_y > domain_height)
                        Location.corner
                    else
                        Location.perimeter
                else if (this_y == 0 or this_y > domain_height)
                    Location.perimeter
                else
                    Location.bulk;
                points.put(Point{
                    .x = @intCast(this_x),
                    .y = @intCast(this_y),
                    .location = location,
                }, .{null} ** 2) catch unreachable;
            }
        }
    }
}
