const std = @import("std");
const testing = std.testing;
const math = std.math;
const approx = math.approxEqAbs;
const allocPrint = std.fmt.allocPrint;
const Element = @import("element.zig").Element;
const Point = @import("geometry.zig").Point;
const utils = @import("utils.zig");
const Position = @import("position.zig").Position;

const point_count = 64;

pub const Circle = struct {
    center: Point,
    r: f32,
    points: [point_count]Point,

    pub fn create(center: Point, r: f32) Circle {
        var points: [point_count]Point = undefined;
        const rad_per_side = math.degreesToRadians(360.0 / @as(f32, @floatFromInt(points.len)));
        for (0..points.len) |i| {
            const rads = @as(f32, @floatFromInt(i)) * rad_per_side;
            const x: i32 = @as(i32, center.x);
            const y: i32 = @as(i32, center.y);
            points[i] = Point{
                .x = @as(u16, @intCast(x + @as(i32, @intFromFloat(r * @cos(rads))))),
                .y = @as(u16, @intCast(y + @as(i32, @intFromFloat(r * @sin(rads))))),
            };
        }
        return .{
            .center = center,
            .r = r,
            .points = points,
        };
    }

    pub fn shortestEdge(self: *const Circle) u16 {
        return utils.distPoints(self.points[0], self.points[1]);
    }

    pub fn characteristicLength(self: *const Circle) u16 {
        return utils.distPoints(self.points[0], self.points[point_count / 2]);
    }

    pub fn isInBody(self: *const Circle, point: Point) bool {
        var circle_iterator = self.iterator();
        const first_point = circle_iterator.nextPoint().?;
        var last_point = first_point;
        var crosses: u8 = 0;
        while (circle_iterator.nextPoint()) |this_point| {
            if (isAdjacent(last_point, this_point, point)) {
                crosses += 1;
            }
            last_point = this_point;
        }
        if (isAdjacent(last_point, first_point, point)) {
            crosses += 1;
        }
        //std.debug.print("crosses {d}\n", .{crosses});
        return if (crosses & 1 == 1) true else false;
    }

    pub fn iterator(self: *const Circle) CircleIterator {
        return CircleIterator{ .body = self.* };
    }
};

//test "characteristicLength" {
//    const circle = Circle.create(Point{ .x = 3, .y = 4 }, 5);
//    const actual = circle.characteristicLength();
//    const expected = 10;
//    //const tolerance = 0.000001;
//    std.debug.print("crosses {}\n", .{actual});
//    try testing.expectEqual(actual, expected);
//}

test "isInBody" {
    const circle = Circle.create(Point{ .x = 60, .y = 70 }, 50);
    // above
    var point = Point{ .x = 60, .y = 121 };
    try testing.expect(!circle.isInBody(point));
    // in
    point = Point{ .x = 60, .y = 119 };
    try testing.expect(circle.isInBody(point));
    // right
    point = Point{ .x = 111, .y = 71 };
    try testing.expect(!circle.isInBody(point));
    // in
    point = Point{ .x = 108, .y = 71 };
    try testing.expect(circle.isInBody(point));
    // below
    point = Point{ .x = 61, .y = 18 };
    try testing.expect(!circle.isInBody(point));
    // in
    point = Point{ .x = 61, .y = 22 };
    try testing.expect(circle.isInBody(point));
    // left
    point = Point{ .x = 8, .y = 69 };
    try testing.expect(!circle.isInBody(point));
    // in
    point = Point{ .x = 12, .y = 69 };
    try testing.expect(circle.isInBody(point));
}

//test "shortestEdge" {
//    const circle = Circle.create(Point{ .x = 1, .y = 2 }, 3);
//    const actual = circle.shortestEdge();
//    const expected = 0.588103;
//    const tolerance = 0.000001;
//    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
//}

pub const CircleIterator = struct {
    body: Circle,
    index: u8 = 0,

    pub fn nextPoint(self: *CircleIterator) ?Point {
        if (self.index >= self.body.points.len) return null;
        const point = self.body.points[self.index];
        self.index += 1;
        return point;
    }
};

//test "nextPoint" {
//    const circle = Circle.create(Point{ .x = 1, .y = 2 }, 3);
//    var cl = circle.iterator();
//    const expect = testing.expect;
//    const tol = 0.000001;
//
//    var actual = cl.nextPoint().?;
//    var expected = Point{ .x = 4e0, .y = 2e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.9423556e0, .y = 2.585271e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.7716384e0, .y = 3.1480503e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.4944088e0, .y = 3.6667109e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.1213202e0, .y = 4.1213202e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 2.6667106e0, .y = 4.494409e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 2.1480503e0, .y = 4.7716384e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 1.5852706e0, .y = 4.942356e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 9.999999e-1, .y = 5e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 4.14729e-1, .y = 4.9423556e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.4805055e-1, .y = 4.7716384e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -6.667111e-1, .y = 4.4944086e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.1213202e0, .y = 4.1213202e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.4944091e0, .y = 3.6667106e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.7716389e0, .y = 3.1480498e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.9423559e0, .y = 2.585271e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -2e0, .y = 1.9999998e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.9423556e0, .y = 1.4147285e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.7716384e0, .y = 8.519497e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.4944086e0, .y = 3.3328915e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.12132e0, .y = -1.21320724e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -6.6671e-1, .y = -4.9440932e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = -1.4804935e-1, .y = -7.716391e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 4.1472888e-1, .y = -9.4235563e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 1e0, .y = -1e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 1.5852712e0, .y = -9.4235563e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 2.1480508e0, .y = -7.716384e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 2.6667113e0, .y = -4.9440837e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.121321e0, .y = -1.2131953e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.4944088e0, .y = 3.3328915e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.7716386e0, .y = 8.519497e-1 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//    actual = cl.nextPoint().?;
//    expected = Point{ .x = 3.9423559e0, .y = 1.4147294e0 };
//    try expect(approx(f32, actual.x, expected.x, tol));
//    try expect(approx(f32, actual.y, expected.y, tol));
//
//    try expect(cl.nextPoint() == null);
//    //std.debug.print("circle iterator {d}: {any}\n", .{ i, circle_iterator.nextPoint() });
//}

// is true if the point is to the left of, or on, the line segment,
// to the left of, or on this_point
// is false if to the left of last_point (that gets counted in the last round)
fn isAdjacent(last_point: Point, this_point: Point, point: Point) bool {
    const min_max = if (last_point.y < this_point.y) .{ last_point.y, this_point.y } else .{ this_point.y, last_point.y };
    if (point.y < min_max[0] or min_max[1] < point.y) {
        return false;
    }
    if (this_point.y == point.y and point.x <= this_point.x) {
        return true;
    }
    if (last_point.y == point.y) {
        return false;
    }
    const lpx: f32 = @floatFromInt(last_point.x);
    const lpy: f32 = @floatFromInt(last_point.y);
    const tpx: f32 = @floatFromInt(this_point.x);
    const tpy: f32 = @floatFromInt(this_point.y);
    const px: f32 = @floatFromInt(point.x);
    const py: f32 = @floatFromInt(point.y);
    const slope = (tpy - lpy) / (tpx - lpx);
    const dy = py - lpy;
    const x = lpx + dy / slope;
    if (px <= x) return true else return false;
}

test "isAdjascent" {
    // above
    var last_point = Point{ .x = 5, .y = 0 };
    var this_point = Point{ .x = 5, .y = 5 };
    var point = Point{ .x = 5, .y = 10 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    this_point = Point{ .x = 5, .y = 0 };
    last_point = Point{ .x = 5, .y = 5 };
    point = Point{ .x = 5, .y = 10 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    // below
    last_point = Point{ .x = 5, .y = 2 };
    this_point = Point{ .x = 5, .y = 5 };
    point = Point{ .x = 5, .y = 1 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    this_point = Point{ .x = 5, .y = 2 };
    last_point = Point{ .x = 5, .y = 5 };
    point = Point{ .x = 5, .y = 1 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    // last_point
    last_point = Point{ .x = 5, .y = 0 };
    this_point = Point{ .x = 5, .y = 5 };
    point = Point{ .x = 4, .y = 0 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    // this_point
    last_point = Point{ .x = 5, .y = 0 };
    this_point = Point{ .x = 5, .y = 5 };
    point = Point{ .x = 4, .y = 5 };
    try testing.expect(isAdjacent(last_point, this_point, point));
    point = Point{ .x = 5, .y = 5 };
    try testing.expect(isAdjacent(last_point, this_point, point));
    point = Point{ .x = 6, .y = 5 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    // line segment
    last_point = Point{ .x = 5, .y = 0 };
    this_point = Point{ .x = 5, .y = 5 };
    point = Point{ .x = 4, .y = 3 };
    try testing.expect(isAdjacent(last_point, this_point, point));
    point = Point{ .x = 6, .y = 3 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
    this_point = Point{ .x = 10, .y = 5 };
    point = Point{ .x = 7, .y = 3 };
    try testing.expect(isAdjacent(last_point, this_point, point));
    point = Point{ .x = 9, .y = 3 };
    try testing.expect(!isAdjacent(last_point, this_point, point));
}
