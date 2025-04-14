const std = @import("std");
const testing = std.testing;
const math = std.math;
const geometry = @import("geometry.zig");
const Edge = geometry.Edge;

const Point = @import("geometry.zig").Point;

pub fn distPoints(a: Point, b: Point) u16 {
    return distXYXY(a.x, a.y, b.x, b.y);
}

pub fn distXYXY(x0: u16, y0: u16, x1: u16, y1: u16) u16 {
    const a0 = @max(x0, x1);
    const a1 = @min(x0, x1);
    const b0 = @max(y0, y1);
    const b1 = @min(y0, y1);
    return distXY(a0 - a1, b0 - b1);
}

pub fn distXY(x: u16, y: u16) u16 {
    const a: f32 = @floatFromInt(math.pow(u32, x, 2));
    const b: f32 = @floatFromInt(math.pow(u32, y, 2));
    return @intFromFloat(math.pow(f32, a + b, 0.5));
}

test "distXY" {
    const actual = distXY(30, 40);
    const expected = 50;
    try testing.expectEqual(actual, expected);
}

test "distXYXY" {
    const actual = distXYXY(10, 20, 40, 60);
    const expected = 50;
    try testing.expectEqual(actual, expected);
}

test "distPoints" {
    const p0 = Point{ .x = 10, .y = 20 };
    const p1 = Point{ .x = 40, .y = 60 };
    const actual = distPoints(p0, p1);
    const expected = 50;
    try testing.expectEqual(actual, expected);
}

pub fn makeImageRGB(
    points: std.AutoHashMap(Point, [2]?Edge),
    flow_domain_length: u16,
    flow_domain_height: u16,
    image_width: u32,
    image_height: u32,
) std.ArrayList(u32) {
    const allocator = std.testing.allocator;
    const samples: u16 = 3;
    var image = std.ArrayList(u32).initCapacity(allocator, (image_width + 1) * (image_height + 1) * samples) catch unreachable;

    for (0..(image_width + 1) * (image_height + 1) * samples) |_| {
        image.append(255) catch unreachable;
    }

    var points_iter = points.iterator();
    while (points_iter.next()) |point| {
        const x = point.key_ptr.*.x * image_width / flow_domain_length;
        const y = point.key_ptr.*.y * image_height / flow_domain_height;
        const i = (x + y * image_width) * 3;
        image.items[i] = 0;
        image.items[i + 1] = 0;
        image.items[i + 2] = 0;
    }

    return image;
}
