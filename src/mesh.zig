const std = @import("std");
const Circle = @import("round.zig").Circle;
const geometry = @import("geometry.zig");
const Edge = geometry.Edge;
const Point = geometry.Point;
const PointInfo = geometry.PointInfo;
const Location = geometry.Location;
const utils = @import("utils.zig");
const position = @import("position.zig");
const Position = position.Position;

pub fn addPoints(
    body: *const Circle,
    points: *std.AutoHashMap(Point, PointInfo),
    char_len: u16,
    flow_domain_length: u16,
    flow_domain_height: u16,
    longest_edge: u16,
    shortest_edge: u16,
) void {
    const max_allow_divs: u16 = longest_edge / shortest_edge;
    var x: u16 = 0;
    var y: u16 = 0;
    while (x < flow_domain_length) : (x += longest_edge) {
        y = 0;
        while (y < flow_domain_height) : (y += longest_edge) {
            addElementPoints(
                points,
                body,
                x,
                y,
                longest_edge,
                max_allow_divs,
                char_len,
                flow_domain_length,
                flow_domain_height,
            );
        }
    }
    var this_x: u16 = 0;
    var location = Location.corner;
    while (this_x < flow_domain_length) : (this_x += longest_edge) {
        points.put(
            Point{
                .x = this_x,
                .y = y - 1,
            },
            PointInfo{ .location = location },
        ) catch unreachable;
        location = Location.perimeter;
    }
    var this_y: u16 = 0;
    location = Location.corner;
    while (this_y < flow_domain_height) : (this_y += longest_edge) {
        points.put(
            Point{
                .x = x - 1,
                .y = this_y,
            },
            PointInfo{ .location = location },
        ) catch unreachable;
        location = Location.perimeter;
    }
    points.put(
        Point{
            .x = x - 1,
            .y = y - 1,
        },
        PointInfo{ .location = .corner },
    ) catch unreachable;
    var bi = body.iterator();
    while (bi.nextPoint()) |point| {
        points.put(
            Point{
                .x = point.x,
                .y = point.y,
            },
            PointInfo{ .location = .body },
        ) catch unreachable;
    }
}

pub fn addEdges(
    points: *std.AutoHashMap(Point, PointInfo),
    edges: *std.AutoHashMap(Edge, [5]?usize),
    allocator: std.mem.Allocator,
) void {
    var unused_points = std.AutoHashMap(Point, void).init(allocator);
    defer unused_points.deinit();
    var point_iter = points.iterator();
    while (point_iter.next()) |entry| {
        unused_points.put(entry.key_ptr.*, {}) catch unreachable;
    }
    point_iter = points.iterator();

    while (point_iter.next()) |p| {
        const point = p.key_ptr.*;
        //std.debug.print("00 point!!!!: {}\n", .{point});
        const point_info = p.value_ptr.*;
        switch (point_info.location) {
            .corner => {
                _ = unused_points.remove(point);

                //p.value_ptr.*[0] = Edge.create(point, closest_point);
                //p.value_ptr.*[1] = Edge.create(point, second_closest_point);
                const closest_points = findClosestNPoints(point, unused_points, 2, allocator);
                defer closest_points.deinit();
                for (closest_points.items) |cp| {
                    edges.put(Edge.create(point, cp), .{null} ** 5) catch unreachable;
                }
            },
            .perimeter => {
                _ = unused_points.remove(point);
                const closest_points = findClosestNPoints(point, unused_points, 3, allocator);
                defer closest_points.deinit();
                for (closest_points.items) |cp| {
                    edges.put(Edge.create(point, cp), .{null} ** 5) catch unreachable;
                }
            },
            .bulk => {},
            .body => {},
        }
    }
}

const PointDist = struct {
    point: Point,
    dist: f64,
};

fn findClosestNPoints(
    point: Point,
    points: std.AutoHashMap(Point, void),
    n: usize,
    allocator: std.mem.Allocator,
) std.ArrayList(Point) {
    var point_dists = std.ArrayList(PointDist).initCapacity(allocator, n) catch unreachable;
    defer point_dists.deinit();
    for (0..n) |_| {
        point_dists.append(PointDist{
            .point = Point{ .x = 0, .y = 0 },
            .dist = @as(f64, @floatFromInt(std.math.maxInt(u16))),
        }) catch unreachable;
    }
    var points_iter = points.iterator();
    while (points_iter.next()) |pi| {
        const test_point = pi.key_ptr.*;
        const dist = utils.distPoints(f64, point, test_point);
        outer_loop: for (point_dists.items, 0..) |pd, i| {
            if (dist < pd.dist) {
                for (i..n) |j| {
                    const k = n - 1 - j;
                    if (k > i) {
                        point_dists.items[k].dist = point_dists.items[k - 1].dist;
                        point_dists.items[k].point = point_dists.items[k - 1].point;
                    } else {
                        point_dists.items[i].point = test_point;
                        point_dists.items[i].dist = dist;
                        break :outer_loop;
                    }
                }
            }
        }
    }
    var result = std.ArrayList(Point).initCapacity(allocator, n) catch unreachable;
    for (point_dists.items) |pd| {
        result.append(pd.point) catch unreachable;
    }
    return result;
}

pub fn addElementPoints(
    points: *std.AutoHashMap(Point, PointInfo),
    body: *const Circle,
    x: u16,
    y: u16,
    longest_edge: u16,
    max_allow_divs: u16,
    char_len: u16,
    domain_width: u16,
    domain_height: u16,
) void {
    const positions: [4]Position = .{
        body.getPositionXY(x, y),
        body.getPositionXY(x + longest_edge, y),
        body.getPositionXY(x + longest_edge, y + longest_edge),
        body.getPositionXY(x, y + longest_edge),
    };

    // TODO: refine this, sets the minimum size of the element grid
    var divisions: [4]?u16 = .{null} ** 4;
    for (positions, 0..) |p, i| {
        switch (p) {
            .Inside => {
                divisions[i] = null;
            },
            .Outside => {
                divisions[i] = char_len / p.Outside + 1;
            },
            else => unreachable,
        }
    }
    var is_entirely_inside = true;
    for (divisions) |division| {
        if (division) |_| {
            is_entirely_inside = false;
        }
    }
    if (is_entirely_inside) return {};

    var steps: u16 = std.math.maxInt(u16);
    for (divisions) |division| {
        if (division) |d| {
            if (d < steps) {
                steps = if (d < max_allow_divs) d else max_allow_divs;
            }
        }
    }

    // TODO: here's where the reference point for what sets the local mesh size is set
    const step_size: u16 = longest_edge / steps;
    for (0..steps) |i| {
        for (0..steps) |j| {
            const this_x = x + i * step_size;
            const this_y = y + j * step_size;
            const this_position = body.getPositionXY(
                @intCast(this_x),
                @intCast(this_y),
            );
            if (this_position == .Outside) {
                const location: Location = if (this_x == 0 or this_x == domain_width)
                    if (this_y == 0 or this_y == domain_height)
                        Location.corner
                    else
                        Location.perimeter
                else if (this_y == 0 or this_y == domain_height)
                    Location.perimeter
                else
                    Location.bulk;

                points.put(
                    Point{
                        .x = @intCast(this_x),
                        .y = @intCast(this_y),
                    },
                    PointInfo{ .location = location },
                ) catch unreachable;
            }
        }
    }
}
