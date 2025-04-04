const std = @import("std");
const testing = std.testing;
const math = std.math;
const allocPrint = std.fmt.allocPrint;
const Element = @import("element.zig").Element;
const Point = @import("geometry.zig").Point;
const utils = @import("utils.zig");

pub const CircleIterator = struct {
    body: Circle,
    index: u8 = 0,
    rad_per_side: f32,

    pub fn nextPoint(self: *CircleIterator) ?Point {
        if (self.index >= self.body.sides) return null;
        const x = self.body.center.x + self.body.r * @cos(@as(f32, @floatFromInt(self.index)) * self.rad_per_side);
        const y = self.body.center.y + self.body.r * @sin(@as(f32, @floatFromInt(self.index)) * self.rad_per_side);
        self.index += 1;
        return Point{ .x = x, .y = y };
    }
};

test "nextPoint" {
    const circle = Circle{ .center = Point{ .x = 1, .y = 2 }, .r = 3 };
    var cl = circle.iterator();
    const expect = testing.expect;
    const approx = math.approxEqAbs;
    const tol = 0.000001;

    var actual = cl.nextPoint().?;
    var expected = Point{ .x = 4e0, .y = 2e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.9423556e0, .y = 2.585271e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.7716384e0, .y = 3.1480503e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.4944088e0, .y = 3.6667109e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.1213202e0, .y = 4.1213202e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 2.6667106e0, .y = 4.494409e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 2.1480503e0, .y = 4.7716384e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 1.5852706e0, .y = 4.942356e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 9.999999e-1, .y = 5e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 4.14729e-1, .y = 4.9423556e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.4805055e-1, .y = 4.7716384e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -6.667111e-1, .y = 4.4944086e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.1213202e0, .y = 4.1213202e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.4944091e0, .y = 3.6667106e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.7716389e0, .y = 3.1480498e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.9423559e0, .y = 2.585271e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -2e0, .y = 1.9999998e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.9423556e0, .y = 1.4147285e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.7716384e0, .y = 8.519497e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.4944086e0, .y = 3.3328915e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.12132e0, .y = -1.21320724e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -6.6671e-1, .y = -4.9440932e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = -1.4804935e-1, .y = -7.716391e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 4.1472888e-1, .y = -9.4235563e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 1e0, .y = -1e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 1.5852712e0, .y = -9.4235563e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 2.1480508e0, .y = -7.716384e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 2.6667113e0, .y = -4.9440837e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.121321e0, .y = -1.2131953e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.4944088e0, .y = 3.3328915e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.7716386e0, .y = 8.519497e-1 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));
    actual = cl.nextPoint().?;
    expected = Point{ .x = 3.9423559e0, .y = 1.4147294e0 };
    try expect(approx(f32, actual.x, expected.x, tol));
    try expect(approx(f32, actual.y, expected.y, tol));

    try expect(cl.nextPoint() == null);
    //std.debug.print("circle iterator {d}: {any}\n", .{ i, circle_iterator.nextPoint() });
}

pub const Circle = struct {
    center: Point,
    r: f32,
    sides: u8 = 32,

    pub fn shortestEdge(self: *const Circle) f32 {
        const rad_per_side = math.degreesToRadians(360.0 / @as(f32, @floatFromInt(self.sides)));
        const dx = self.r - self.r * @cos(rad_per_side);
        const dy = self.r * @sin(rad_per_side);
        return utils.distXY(dx, dy);
    }

    pub fn iterator(self: *const Circle) CircleIterator {
        const rad_per_side = math.degreesToRadians(360.0 / @as(f32, @floatFromInt(self.sides)));
        return CircleIterator{ .body = self.*, .rad_per_side = rad_per_side };
    }
};

test "shortestEdge" {
    const circle = Circle{ .center = Point{ .x = 1, .y = 2 }, .r = 3 };
    const actual = circle.shortestEdge();
    const expected = 0.588103;
    const tolerance = 0.000001;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
}
