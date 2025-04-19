const std = @import("std");
const Circle = @import("round.zig").Circle;
const geometry = @import("geometry.zig");
const Edge = geometry.Edge;
const Point = geometry.Point;
const utils = @import("utils.zig");
const position = @import("position.zig");
const Position = position.Position;

pub fn addBlock(
    points: *std.AutoHashMap(Point, [2]?Edge),
    body: *const Circle,
    x: u16,
    y: u16,
    longest_edge: u16,
    shortest_edge: u16,
    char_len: u16,
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
            const this_position = body.getPositionXY(@intCast(this_x), @intCast(this_y));
            if (this_position == .Outside) {
                points.put(Point{ .x = @intCast(this_x), .y = @intCast(this_y) }, .{null} ** 2) catch unreachable;
            }
        }
    }
}
