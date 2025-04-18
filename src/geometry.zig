const approxEqAbs = @import("std").math.aproxEqAbs;
pub const Point = struct {
    x: u16,
    y: u16,

    //pub fn equals(self: *const Point, other: Point, tolerance: f64) bool {
    //    return (approxEqAbs(f64, self.x, other.x, tolerance) and
    //        approxEqAbs(f64, self.y, other.y, tolerance));
    //}
};

pub const Edge = struct {
    p0: Point,
    p1: Point,
};

pub const Element2D = struct {
    edges: [4]?Edge,
};
