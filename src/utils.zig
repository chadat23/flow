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

pub fn midpoint(p0: Point, p1: Point) Point {
    return Point{ .x = (p0.x + p1.x) / 2, .y = (p0.y + p1.y) / 2 };
}

test "midpoint" {
    const p0 = Point{ .x = 1, .y = 2 };
    const p1 = Point{ .x = 4, .y = 6 };
    const actual = midpoint(p0, p1);
    const expected = Point{ .x = 2.5, .y = 4 };
    const tolerance = 0.000001;
    try testing.expect(math.approxEqAbs(f32, actual.x, expected.x, tolerance));
    try testing.expect(math.approxEqAbs(f32, actual.y, expected.y, tolerance));
}

/// Calculates the slope of the line connecting the points
///
/// The line goes from p0 to p1
///
/// p0 = Point{ .x = 1, .y = 2 };
/// p1 = Point{ .x = -4, .y = -6 };
/// actual = slopeRad(p0, p1);
/// expected = -2.129395;
/// try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
pub fn slopeRad(p0: Point, p1: Point) f32 {
    const dx = (p1.x - p0.x);
    const dy = (p1.y - p0.y);
    return std.math.atan2(dy, dx);
}

test "slope" {
    var p0 = Point{ .x = 1, .y = 2 };
    var p1 = Point{ .x = 4, .y = 6 };
    var actual = slopeRad(p0, p1);
    var expected: f32 = 0.927295;
    const tolerance = 0.000001;

    p0 = Point{ .x = 1, .y = 2 };
    p1 = Point{ .x = -4, .y = 6 };
    actual = slopeRad(p0, p1);
    expected = 2.466851;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));

    p0 = Point{ .x = 1, .y = 2 };
    p1 = Point{ .x = -4, .y = -6 };
    actual = slopeRad(p0, p1);
    expected = -2.129395;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));

    p0 = Point{ .x = 1, .y = 2 };
    p1 = Point{ .x = 4, .y = -6 };
    actual = slopeRad(p0, p1);
    expected = -1.212025;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
}
