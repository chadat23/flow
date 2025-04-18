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
    const max_allowable_divisions: u16 = longest_edge / shortest_edge;
    var min_divisions: ?u16 = null;
    var max_divisions: ?u16 = 0;
    for (positions) |p| {
        switch (p) {
            .Inside => {
                max_divisions = null;
            },
            .Outside => {
                const divisions = char_len / p.Outside + 1;
                if (min_divisions) |d| {
                    if (divisions < d) {
                        min_divisions = divisions;
                    }
                } else {
                    min_divisions = divisions;
                }
                if (max_divisions) |d| {
                    if (d < divisions) {
                        if (divisions < max_allowable_divisions) {
                            max_divisions = divisions;
                        } else {
                            max_divisions = max_allowable_divisions;
                        }
                    }
                }
            },
            else => unreachable,
        }
    }
    if (min_divisions == null and max_divisions == null) {
        return {};
    }

    const steps = if (max_divisions) |max| max else max_allowable_divisions;
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
    //std.debug.print("done: {any}\n", .{8});
}
