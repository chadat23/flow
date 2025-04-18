const Point = @import("geometry.zig").Point;

const PositionType = enum {
    Inside,
    Intersecting,
    Outside,
};

pub const Position = union(PositionType) {
    Inside: bool,
    Intersecting: [2]Point,
    Outside: u16,
};
