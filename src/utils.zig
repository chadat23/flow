const std = @import("std");
const testing = std.testing;
const math = std.math;

const Point = @import("geometry.zig").Point;

pub fn distPoints(a: Point, b: Point) f32 {
    return distXYXY(a.x, a.y, b.x, b.y);
}

pub fn distXYXY(x0: f32, y0: f32, x1: f32, y1: f32) f32 {
    return distXY(x0 - x1, y0 - y1);
}

pub fn distXY(x: f32, y: f32) f32 {
    return math.pow(f32, math.pow(f32, x, 2) + math.pow(f32, y, 2), 0.5);
}

test "distXY" {
    const actual = distXY(3, 4);
    const expected = 5;
    const tolerance = 0.000001;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
}

test "distXYXY" {
    const actual = distXYXY(1, 2, 4, 6);
    const expected = 5;
    const tolerance = 0.000001;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
}

test "distPoints" {
    const p0 = Point{ .x = 1, .y = 2 };
    const p1 = Point{ .x = 4, .y = 6 };
    const actual = distPoints(p0, p1);
    const expected = 5;
    const tolerance = 0.000001;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
}
