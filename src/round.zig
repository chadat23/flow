const std = @import("std");
const testing = std.testing;
const math = std.math;
const allocPrint = std.fmt.allocPrint;
const Element = @import("element.zig").Element;

pub const Circle = struct {
    x: f32,
    y: f32,
    r: f32,
    sides: u8 = 32,

    pub fn shortestEdge(self: *const Circle) f32 {
        const rad_per_side = 360.0 / @as(f32, @floatFromInt(self.sides)) * math.rad_per_deg;
        const dx = self.r - self.r * @cos(rad_per_side);
        const dy = self.r * @sin(rad_per_side);
        return math.pow(f32, math.pow(f32, dx, 2) + math.pow(f32, dy, 2), 0.5);
    }

    //pub fn position(self: *Circle, element: Element) Position {
    //    const r_2 = math.pow(f32, self.r, 2);
    //    var inside: u8 = 0;
    //    var smallest_2: f32 = math.inf(f32);
    //    const xs = element.getXValues();
    //    const ys = element.getYValues();
    //    for (xs.xs, ys.ys) |x, y| {
    //        const this_r_2 = math.pow(f32, self.x - x, 2) + math.pow(f32, self.y - y, 2);
    //        if (this_r_2 < r_2) {
    //            inside += 1;
    //        } else if (this_r_2 < smallest_2) {
    //            smallest_2 = this_r_2;
    //        }
    //    }
    //    if (inside == xs.len) {
    //        return Position{ .inside = true };
    //    } else if (inside > 0) {
    //        return Position{ .intersects = 0 };
    //    }
    //    return Position{ .outside = math.pow(f32, smallest_2, 0.5) };
    //}
};

test "shortestEdge" {
    const circle = Circle{ .x = 1, .y = 2, .r = 3 };
    const actual = circle.shortestEdge();
    const expected = 0.588103;
    const tolerance = 0.000001;
    try testing.expect(math.approxEqAbs(f32, actual, expected, tolerance));
}

//test "circle position" {
//    var circle = Circle{ .x = 1, .y = 2, .r = 3 };
//    const Quadrilateral = @import("element.zig").Quadrilateral;
//
//    const element = Element{ .quadrilateral = Quadrilateral{
//        .x = .{ 5.5, 6.5, 6, 5 },
//        .y = .{ 9.5, 9, 8.5, 8 },
//    } };
//
//    const position = circle.position(element);
//
//    std.debug.print("position: {}\n", .{position});
//}
