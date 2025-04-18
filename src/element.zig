pub const Element = union(enum) {
    hexahedran: Hexahedran,
    tetrahedraon: Tetrahedraon,
    quadrilateral: Quadrilateral,
    triangle: Triangle,

    //pub fn move(self: Element, dx: f64, dy: f32) void {
    //    switch (self) {
    //        inline else => |s| s.move(dx, dy),
    //    }
    //}

    pub fn getXValues(self: Element) struct { xs: []const f64, len: usize } {
        return switch (self) {
            inline else => |s| .{ .xs = s.x[0..], .len = s.x.len },
        };
    }

    pub fn getYValues(self: Element) struct { ys: []const f64, len: usize } {
        return switch (self) {
            inline else => |s| .{ .ys = s.y[0..], .len = s.y.len },
        };
    }
};

pub const Hexahedran = struct {
    //    0------1
    //   /|     /|
    //  4-|----5 |
    //  | 3------2
    //  |/     |/
    //  7------6
    x: [8]f64,
    y: [8]f64,
};

pub const Tetrahedraon = struct {
    //      0
    //     /|\
    //    / | \
    //   3--|--1
    //    \ | /
    //     \|/
    //      2
    x: [4]f64,
    y: [4]f64,
};

pub const Quadrilateral = struct {
    //      0------------1
    //     /              \
    //    /                \
    //   3----____          \
    //            ----____   \
    //                    ----2
    x: [4]f64,
    y: [4]f64,
};

pub const Triangle = struct {
    //      0
    //     / \
    //    /   \
    //   2-----1
    x: [3]f64,
    y: [3]f64,
};
