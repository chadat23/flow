const std = @import("std");
const approxEqAbs = std.math.aproxEqAbs;
const utils = @import("utils.zig");

pub const Point = struct {
    x: u16,
    y: u16,

    //pub fn equals(self: *const Point, other: Point, tolerance: f64) bool {
    //    return (approxEqAbs(f64, self.x, other.x, tolerance) and
    //        approxEqAbs(f64, self.y, other.y, tolerance));
    //}
};

pub const PointInfo = struct {
    location: Location,
};

pub const Edge = struct {
    p0: Point,
    p1: Point,

    pub fn create(p0: Point, p1: Point) Edge {
        if (p0.x < p1.x) {
            return Edge{ .p0 = p0, .p1 = p1 };
        } else if (p1.x < p0.x) {
            return Edge{ .p0 = p1, .p1 = p0 };
        }
        if (p0.y < p1.y) {
            return Edge{ .p0 = p0, .p1 = p1 };
        } else if (p1.y < p0.y) {
            return Edge{ .p0 = p1, .p1 = p0 };
        }
        //std.debug.print("###\n p0 {} \n p1 {}\n", .{ p0, p1 });
        unreachable;
    }

    pub fn Length(self: *const Edge) f64 {
        return utils.distPoints(f64, self.p0, self.p1);
    }
};

pub const Element2D = struct {
    edges: [4]?Edge,
};

pub const Location = enum {
    corner,
    perimeter,
    bulk,
    body,
};
