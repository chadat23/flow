pub const Point = struct {
    x: f32,
    y: f32,
};

pub const Edge = struct {
    p0: Point,
    p1: Point,
};

pub const Element2D = struct {
    edges: [4]?Edge,
};
