const std = @import("std");
const testing = std.testing;
const math = std.math;
const geometry = @import("geometry.zig");
const Edge = geometry.Edge;

const Point = @import("geometry.zig").Point;

//pub fn distPoints(comptime T: type, a: Point, b: Point) u16 {
pub fn distPoints(comptime T: type, a: Point, b: Point) T {
    switch (@typeInfo(T)) {
        .comptime_float, .float => {
            return distXYXY(
                T,
                @as(T, @floatFromInt(a.x)),
                @as(T, @floatFromInt(a.y)),
                @as(T, @floatFromInt(b.x)),
                @as(T, @floatFromInt(b.y)),
            );
        },
        .comptime_int, .int => {
            return distXYXY(T, a.x, a.y, b.x, b.y);
        },
        else => @compileError("Type must be an Int or Float"),
    }
}

pub fn distXYXY(comptime T: type, x0: T, y0: T, x1: T, y1: T) T {
    const a0 = @max(x0, x1);
    const a1 = @min(x0, x1);
    const b0 = @max(y0, y1);
    const b1 = @min(y0, y1);
    return distXY(T, a0 - a1, b0 - b1);
}

pub fn distXY(comptime T: type, x: T, y: T) T {
    switch (@typeInfo(T)) {
        .comptime_float, .float => {
            const a = math.pow(T, x, 2);
            const b = math.pow(T, y, 2);
            return math.pow(T, a + b, 0.5);
        },
        .comptime_int, .int => {
            const a: f64 = @floatFromInt(math.pow(u64, x, 2));
            const b: f64 = @floatFromInt(math.pow(u64, y, 2));
            return @intFromFloat(math.pow(f64, a + b, 0.5));
        },
        else => @compileError("Type must be an Int or Float"),
    }
}

test "distXY" {
    const actual = distXY(u16, 30, 40);
    const expected = 50;
    try testing.expectEqual(expected, actual);
}

test "distXYXY" {
    const actual = distXYXY(u16, 10, 20, 40, 60);
    const expected = 50;
    try testing.expectEqual(expected, actual);
}

test "distPoints" {
    const p0 = Point{ .x = 10, .y = 20 };
    const p1 = Point{ .x = 40, .y = 60 };
    const actual = distPoints(f64, p0, p1);
    const expected = 50;
    try testing.expectEqual(expected, actual);
}

// dist from point to the segment between point0 and point1
pub fn distToSegmentPoint(point0: Point, point1: Point, point: Point) f64 {
    return distToSegmentXY(point0, point1, point.x, point.y);
}

pub fn distToSegmentXY(point0: Point, point1: Point, x: u16, y: u16) f64 {
    const p0x: f64 = @floatFromInt(point0.x);
    const p0y: f64 = @floatFromInt(point0.y);
    const p1x: f64 = @floatFromInt(point1.x);
    const p1y: f64 = @floatFromInt(point1.y);
    const px: f64 = @floatFromInt(x);
    const py: f64 = @floatFromInt(y);

    const d0 = distXYXY(f64, p0x, p0y, px, py);
    const d1 = distXYXY(f64, p1x, p1y, px, py);
    const d01 = distXYXY(f64, p0x, p0y, p1x, p1y);

    const angled0 = angleLawOfCos(f64, d0, d1, d01);
    const angled1 = angleLawOfCos(f64, d1, d0, d01);
    if (angled0 > std.math.pi / 2.0 or angled1 > std.math.pi / 2.0) {
        return @min(d0, d1);
    }

    // y = mx + b, y = y
    const m01 = (p0y - p1y) / (p0x - p1x);
    const m01_rad = std.math.atan(m01);
    const b01 = p0y - m01 * p0x;
    const m_rad = m01_rad + std.math.pi / 2.0;
    const m = @tan(m_rad);
    const b = py - m * px;
    const this_x = (b01 - b) / (m - m01);
    const this_y = m * this_x + b;

    const d = distXYXY(f64, this_x, this_y, px, py);

    return d;
}

// calc the angle A, which is oppose of the side A
fn angleLawOfCos(comptime T: type, a: T, b: T, c: T) f64 {
    switch (@typeInfo(T)) {
        .comptime_float, .float => {
            return std.math.acos((b * b + c * c - a * a) / (2 * b * c));
        },
        .comptime_int, .int => {
            const n: f64 = @floatFromInt(b * b + c * c - a * a);
            const d: f64 = @floatFromInt(2 * b * c);
            return std.math.acos(n / d);
        },
        else => @compileError("Type must be an Int or Float"),
    }
}

test "distToSeqment" {
    const tolerance = 0.000001;
    const approxEqAbs = std.math.approxEqAbs;
    const p0 = Point{ .x = 20, .y = 10 };
    const p1 = Point{ .x = 30, .y = 50 };
    var p = Point{ .x = 15, .y = 4 };
    var actual = distToSegmentPoint(p0, p1, p);
    var expected: f64 = 7.81025;
    try testing.expect(approxEqAbs(f64, expected, actual, tolerance));
    p = Point{ .x = 20, .y = 30 };
    actual = distToSegmentPoint(p0, p1, p);
    expected = 4.8507123;
    try testing.expect(approxEqAbs(f64, expected, actual, tolerance));
    p = Point{ .x = 35, .y = 60 };
    actual = distToSegmentPoint(p0, p1, p);
    expected = 11.18034;
    try testing.expect(approxEqAbs(f64, expected, actual, tolerance));
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
    var image = std.ArrayList(u32).initCapacity(allocator, points.count()) catch unreachable;

    for (0..(image_width + 1) * (image_height + 1) * samples) |_| {
        image.append(255) catch unreachable;
    }

    var points_iter = points.iterator();
    while (points_iter.next()) |point| {
        const x = point.key_ptr.*.x * image_width / flow_domain_length;
        const y = point.key_ptr.*.y * image_height / flow_domain_height;
        const i = (x + y * image_width) * 3;
        if (i < image.items.len) {
            image.items[i] = 0;
            image.items[i + 1] = 0;
            image.items[i + 2] = 0;
        }
    }

    return image;
}
