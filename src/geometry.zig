const approxEqAbs = @import("std").math.aproxEqAbs;
pub const Point = struct {
    x: f32,
    y: f32,

    pub fn equals(self: *const Point, other: Point, tolerance: f32) bool {
        return (approxEqAbs(f32, self.x, other.x, tolerance) and 
            approxEqAbs(f32, self.y, other.y, tolerance));
};

pub const Edge = struct {
    p0: Point,
    p1: Point,
};

pub const Element2D = struct {
    edges: [4]?Edge,
};
