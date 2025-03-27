pub const Element = union(enum) {
    hexahedran: Hexahedran,
    tetrahedraon: Tetrahedraon,
    quadrilateral: Quadrilateral,
    triangle: Triangle,

    //pub fn move(self: Element, dx: f32, dy: f32) void {
    //    switch (self) {
    //        inline else => |s| s.move(dx, dy),
    //    }
    //}

    pub fn getXValues(self: Element) struct { xs: []const f32, len: usize } {
        return switch (self) {
            inline else => |s| .{ .xs = s.x[0..], .len = s.x.len },
        };
    }

    pub fn getYValues(self: Element) struct { ys: []const f32, len: usize } {
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
    x: [8]f32,
    y: [8]f32,
};

pub const Tetrahedraon = struct {
    //      0
    //     /|\
    //    / | \
    //   3--|--1
    //    \ | /
    //     \|/
    //      2
    x: [4]f32,
    y: [4]f32,
};

pub const Quadrilateral = struct {
    //      0------------1
    //     /              \
    //    /                \
    //   3----____          \
    //            ----____   \
    //                    ----2
    x: [4]f32,
    y: [4]f32,
};

pub const Triangle = struct {
    //      0
    //     / \
    //    /   \
    //   2-----1
    x: [3]f32,
    y: [3]f32,
};
