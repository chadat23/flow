const std = @import("std");

const geometry = @import("geometry.zig");
const Point = geometry.Point;
const PointInfo = geometry.PointInfo;
const Edge = geometry.Edge;

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn create(r: u8, g: u8, b: u8) Color {
        return Color{ .r = r, .g = g, .b = b };
    }
};

const white = Color.create(255, 255, 255);
const black = Color.create(0, 0, 0);
const red = Color.create(255, 0, 0);
const green = Color.create(0, 128, 0);
const blue = Color.create(0, 0, 255);
const purple = Color.create(255, 0, 255);
const orange = Color.create(255, 0, 255);

pub fn makeImageRGB(
    points: std.AutoHashMap(Point, PointInfo),
    edges: std.AutoHashMap(Edge, [2]?usize),
    domain_length: u16,
    domain_height: u16,
    image_width: u32,
    image_height: u32,
) std.ArrayList(u32) {
    const allocator = std.testing.allocator;

    const samples: u16 = 3;
    const domain_length_image_width_ratio: f64 = @as(f64, @floatFromInt(domain_length)) / @as(f64, @floatFromInt(image_width));
    const domain_height_image_height_ratio: f64 = @as(f64, @floatFromInt(domain_height)) / @as(f64, @floatFromInt(image_height));
    var image = std.ArrayList(u32).initCapacity(allocator, image_width * image_height * 3) catch unreachable;

    for (0..(image_width + 1) * (image_height + 1) * samples) |_| {
        image.append(255) catch unreachable;
    }

    //_ = edges;
    const edge_color = red;
    var edges_iter = edges.iterator();
    while (edges_iter.next()) |edge| {
        const p0x: f64 = @floatFromInt(edge.key_ptr.*.p0.x);
        const p0y: f64 = @floatFromInt(edge.key_ptr.*.p0.y);
        const p1x: f64 = @floatFromInt(edge.key_ptr.*.p1.x);
        const p1y: f64 = @floatFromInt(edge.key_ptr.*.p1.y);

        const steps = @as(usize, @intFromFloat(edge.key_ptr.*.Length() / domain_length_image_width_ratio));
        const steps_f: f64 = @floatFromInt(steps);
        const dx = p1x - p0x;
        const m = (p1y - p0y) / dx;
        for (0..steps) |n| {
            const x = p0x + @as(f64, @floatFromInt(n)) * dx / steps_f;
            var y: f64 = undefined;
            if (p0x == p1x) {
                const dy = p1y - p0y;
                y = p0y + @as(f64, @floatFromInt(n)) * dy / steps_f;
            } else {
                y = p0y + @as(f64, @floatFromInt(n)) * dx / steps_f * m;
            }

            const img_x: usize = @intFromFloat(x / domain_length_image_width_ratio);
            const img_y: usize = @intFromFloat(y / domain_height_image_height_ratio);

            const i: usize = (img_x + img_y * image_width) * 3;
            if (i < image.items.len) {
                image.items[i] = edge_color.r;
                image.items[i + 1] = edge_color.g;
                image.items[i + 2] = edge_color.b;
            }
        }
    }

    const corner_point_color = black;
    const perimeter_point_color = green;
    const bulk_point_color = blue;
    const body_point_color = purple;
    var points_iter = points.iterator();
    while (points_iter.next()) |point| {
        const p = point.key_ptr;
        const point_info = point.value_ptr;
        const x = p.x * image_width / domain_length;
        const y = p.y * image_height / domain_height;
        const i = (x + y * image_width) * 3;
        switch (point_info.location) {
            .corner => {
                image.items[i] = corner_point_color.r;
                image.items[i + 1] = corner_point_color.g;
                image.items[i + 2] = corner_point_color.b;
            },
            .perimeter => {
                image.items[i] = perimeter_point_color.r;
                image.items[i + 1] = perimeter_point_color.g;
                image.items[i + 2] = perimeter_point_color.b;
            },
            .bulk => {
                image.items[i] = bulk_point_color.r;
                image.items[i + 1] = bulk_point_color.g;
                image.items[i + 2] = bulk_point_color.b;
            },
            .body => {
                image.items[i] = body_point_color.r;
                image.items[i + 1] = body_point_color.g;
                image.items[i + 2] = body_point_color.b;
            },
        }
    }

    return image;
}
