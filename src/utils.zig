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

pub fn makeImageRGB(points: std>AutoHashMap(Point, [10]?Edge, flow_domain_length: f32, flow_domain_height: f32, width: u16, height: u16) std.AutoArray(u32) {
    const allocator = std.testing.allocator;
    var image = std.AutoArray(u32).initCapacity(allocator, width * height * 3);

    image.appendSlice(.{255} ** (width * height * 3));

    for (points.keys()) |point| {
        const x = math.floor(point.x / flow_domain_length * width);
        const y = math.floor(point.y / flow_domain_heigth * height);
        const i = (x + y * width) * 3;
        image.items[i] = 0;
        image.items[i+1] = 0;
        image.items[i+2] = 0;
    }
    
    return image;
}
