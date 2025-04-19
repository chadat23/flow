const approxEqAbs = @import("std").math.aproxEqAbs;
const utils = @import("utils.zig");

pub const Point = struct {
    x: u16,
    y: u16,
    location: Location,

    //pub fn equals(self: *const Point, other: Point, tolerance: f64) bool {
    //    return (approxEqAbs(f64, self.x, other.x, tolerance) and
    //        approxEqAbs(f64, self.y, other.y, tolerance));
    //}
};

pub const Edge = struct {
    p0: Point,
    p1: Point,

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
