const Point = @import("geometry.zig").Point;

const PositionType = enum{
    Inside,
    Intersects,
    Outside,
};

pub const Position = union(PositionType) {
    Inside: bool,
    Intersecting: [2]Point,
    Outside: f32,
};

