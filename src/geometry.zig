pub const Point = struct {
    x: f32,
    y: f32,
};

pub const Edge = struct {
    p0: Point,
    p1: Point,
    is_body_edge: bool = false,
};

pub const Element2D = struct {
    edges: [4]?Edge,
};

pub const Array = struct {
    items: [6]?usize,
    index: usize,

    pub fn create() Array {
        return .{
            .items = .{null} ** 6,
            .index = 0,
        };
    }

    pub fn append(self: *Array, n: usize) void {
        self.items[self.index] = n;
        self.index += 1;
    }
};
